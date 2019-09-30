$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require 'puppet/util/mongodb_output'

require 'yaml'
require 'json'
class Puppet::Provider::Mongodb < Puppet::Provider
  # Without initvars commands won't work.
  initvars
  commands mongo: 'mongo'

  # Optional defaults file
  def self.mongorc_file
    "load('#{Facter.value(:root_home)}/.mongorc.js'); " if File.file?("#{Facter.value(:root_home)}/.mongorc.js")
  end

  def mongorc_file
    self.class.mongorc_file
  end

  def self.mongod_conf_file
    if File.exist? '/etc/mongod.conf'
      '/etc/mongod.conf'
    else
      '/etc/mongodb.conf'
    end
  end

  def self.mongo_conf
    config = YAML.load_file(mongod_conf_file) || {}
    {
      'bindip' => config['net.bindIp'],
      'port' => config['net.port'],
      'ipv6' => config['net.ipv6'],
      'allowInvalidHostnames' => config['net.ssl.allowInvalidHostnames'],
      'ssl' => config['net.ssl.mode'],
      'sslcert' => config['net.ssl.PEMKeyFile'],
      'sslca' => config['net.ssl.CAFile'],
      'auth' => config['security.authorization'],
      'shardsvr' => config['sharding.clusterRole'],
      'confsvr' => config['sharding.clusterRole']
    }
  end

  def self.ipv6_is_enabled(config = nil)
    config ||= mongo_conf
    config['ipv6']
  end

  def self.ssl_is_enabled(config = nil)
    config ||= mongo_conf
    ssl_mode = config.fetch('ssl')
    !ssl_mode.nil? && ssl_mode != 'disabled'
  end

  def self.ssl_invalid_hostnames(config = nil)
    config ||= mongo_conf
    config['allowInvalidHostnames']
  end

  def self.mongo_cmd(db, host, cmd)
    config = mongo_conf

    args = [db, '--quiet', '--host', host]
    args.push('--ipv6') if ipv6_is_enabled(config)
    args.push('--sslAllowInvalidHostnames') if ssl_invalid_hostnames(config)

    if ssl_is_enabled(config)
      args.push('--ssl')
      args += ['--sslPEMKeyFile', config['sslcert']]

      ssl_ca = config['sslca']
      args += ['--sslCAFile', ssl_ca] unless ssl_ca.nil?
    end

    args += ['--eval', cmd]
    mongo(args)
  end

  def self.conn_string
    config = mongo_conf
    bindip = config.fetch('bindip')
    if bindip
      first_ip_in_list = bindip.split(',').first
      ip_real = case first_ip_in_list
                when '0.0.0.0'
                  '127.0.0.1'
                when %r{\[?::0\]?}
                  '::1'
                else
                  first_ip_in_list
                end
    end

    port = config.fetch('port')
    shardsvr = config.fetch('shardsvr')
    confsvr = config.fetch('confsvr')
    port_real = if port
                  port
                elsif !port && (confsvr.eql?('configsvr') || confsvr.eql?('true'))
                  27_019
                elsif !port && (shardsvr.eql?('shardsvr') || shardsvr.eql?('true'))
                  27_018
                else
                  27_017
                end

    "#{ip_real}:#{port_real}"
  end

  def self.db_ismaster
    cmd_ismaster = 'db.isMaster().ismaster'
    cmd_ismaster = mongorc_file + cmd_ismaster if mongorc_file
    db = 'admin'
    res = mongo_cmd(db, conn_string, cmd_ismaster).to_s.chomp
    res.eql?('true')
  end

  def db_ismaster
    self.class.db_ismaster
  end

  def self.auth_enabled(config = nil)
    config ||= mongo_conf
    config['auth'] && config['auth'] != 'disabled'
  end

  # Mongo Command Wrapper
  def self.mongo_eval(cmd, db = 'admin', retries = 10, host = nil)
    retry_count = retries
    retry_sleep = 3
    cmd = mongorc_file + cmd if mongorc_file

    out = nil
    begin
      out = if host
              mongo_cmd(db, host, cmd)
            else
              mongo_cmd(db, conn_string, cmd)
            end
    rescue => e
      retry_count -= 1
      if retry_count > 0
        Puppet.debug "Request failed: '#{e.message}' Retry: '#{retries - retry_count}'"
        sleep retry_sleep
        retry
      end
    end

    unless out
      raise Puppet::ExecutionFailure, "Could not evaluate MongoDB shell command: #{cmd}"
    end

    Puppet::Util::MongodbOutput.sanitize(out)
  end

  def mongo_eval(cmd, db = 'admin', retries = 10, host = nil)
    self.class.mongo_eval(cmd, db, retries, host)
  end

  # Mongo Version checker
  def self.mongo_version
    @mongo_version ||= mongo_eval('db.version()')
  end

  def mongo_version
    self.class.mongo_version
  end

  def self.mongo_26?
    v = mongo_version
    !v[%r{^2\.6\.}].nil?
  end

  def mongo_26?
    self.class.mongo_26?
  end
end
