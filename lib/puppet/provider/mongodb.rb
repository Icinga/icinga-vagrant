require 'yaml'
class Puppet::Provider::Mongodb < Puppet::Provider

  # Without initvars commands won't work.
  initvars
  commands :mongo => 'mongo'

  # Optional defaults file
  def self.mongorc_file
    if File.file?("#{Facter.value(:root_home)}/.mongorc.js")
      "load('#{Facter.value(:root_home)}/.mongorc.js'); "
    else
      nil
    end
  end

  def mongorc_file
    self.class.mongorc_file
  end

  def self.get_mongod_conf_file
    if File.exists? '/etc/mongod.conf'
      file = '/etc/mongod.conf'
    else
      file = '/etc/mongodb.conf'
    end
    file
  end

  def self.get_conn_string
    file = get_mongod_conf_file
    # The mongo conf is probably a key-value store, even though 2.6 is
    # supposed to use YAML, because the config template is applied
    # based on $::mongodb::globals::version which is the user will not
    # necessarily set. This attempts to get the port from both types of
    # config files.
    config = YAML.load_file(file)
    if config.kind_of?(Hash) # Using a valid YAML file for mongo 2.6
      bindip = config['net.bindIp']
      port = config['net.port']
      shardsvr = config['sharding.clusterRole']
      confsvr = config['sharding.clusterRole']
    else # It has to be a key-value config file
      config = {}
      File.readlines(file).collect do |line|
         k,v = line.split('=')
         config[k.rstrip] = v.lstrip.chomp if k and v
      end
      bindip = config['bind_ip']
      port = config['port']
      shardsvr = config['shardsvr']
      confsvr = config['confsvr']
    end

    if bindip
      first_ip_in_list = bindip.split(',').first
      if first_ip_in_list.eql? '0.0.0.0'
        ip_real = '127.0.0.1'
      else
        ip_real = first_ip_in_list
      end
    end

    if port
      port_real = port
    elsif !port and (confsvr.eql? 'configsvr' or confsvr.eql? 'true')
      port_real = 27019
    elsif !port and (shardsvr.eql? 'shardsvr' or shardsvr.eql? 'true')
      port_real = 27018
    else
      port_real = 27017
    end

    "#{ip_real}:#{port_real}"
  end

  # Mongo Command Wrapper
  def self.mongo_eval(cmd, db = 'admin')
    if mongorc_file
        cmd = mongorc_file + cmd
    end

    out = mongo([db, '--quiet', '--host', get_conn_string, '--eval', cmd])

    out.gsub!(/ObjectId\(([^)]*)\)/, '\1')
    out
  end

  def mongo_eval(cmd, db = 'admin')
    self.class.mongo_eval(cmd, db)
  end

  # Mongo Version checker
  def self.mongo_version
    @@mongo_version ||= self.mongo_eval('db.version()')
  end

  def mongo_version
    self.class.mongo_version
  end

  def self.mongo_24?
    v = self.mongo_version
    ! v[/^2\.4\./].nil?
  end

  def mongo_24?
    self.class.mongo_24?
  end

end
