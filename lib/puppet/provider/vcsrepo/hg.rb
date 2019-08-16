require File.join(File.dirname(__FILE__), '..', 'vcsrepo')

Puppet::Type.type(:vcsrepo).provide(:hg, parent: Puppet::Provider::Vcsrepo) do
  desc 'Supports Mercurial repositories'

  commands hg: 'hg'

  has_features :reference_tracking, :ssh_identity, :user, :basic_auth

  def create
    check_force
    if !@resource.value(:source)
      create_repository(@resource.value(:path))
    else
      clone_repository(@resource.value(:revision))
    end
    update_owner
  end

  def working_copy_exists?
    return false unless File.directory?(@resource.value(:path))
    begin
      hg_wrapper('status', @resource.value(:path))
      return true
    rescue Puppet::ExecutionFailure
      return false
    end
  end

  def exists?
    working_copy_exists?
  end

  def destroy
    FileUtils.rm_rf(@resource.value(:path))
  end

  def latest?
    at_path do
      return revision == latest
    end
  end

  def latest
    at_path do
      begin
        hg_wrapper('incoming', '--branch', '.', '--newest-first', '--limit', '1', remote: true)[%r{^changeset:\s+(?:-?\d+):(\S+)}m, 1]
      rescue Puppet::ExecutionFailure
        # If there are no new changesets, return the current nodeid
        revision
      end
    end
  end

  def revision
    at_path do
      current = hg_wrapper('parents')[%r{^changeset:\s+(?:-?\d+):(\S+)}m, 1]
      desired = @resource.value(:revision)
      if desired
        # Return the tag name if it maps to the current nodeid
        mapped = hg_wrapper('tags')[%r{^#{Regexp.quote(desired)}\s+\d+:(\S+)}m, 1]
        if current == mapped
          desired
        else
          current
        end
      else
        current
      end
    end
  end

  def revision=(desired)
    at_path do
      begin
        hg_wrapper('pull', remote: true)
      rescue StandardError
        next
      end
      begin
        hg_wrapper('merge')
      rescue Puppet::ExecutionFailure
        next
        # If there's nothing to merge, just skip
      end
      hg_wrapper('update', '--clean', '-r', desired)
    end
    update_owner
  end

  def source
    at_path do
      hg_wrapper('paths')[%r{^default = (.*)}, 1]
    end
  end

  def source=(_desired)
    create # recreate
  end

  private

  def create_repository(path)
    hg_wrapper('init', path)
  end

  def clone_repository(revision)
    args = ['clone']
    if revision
      args.push('-u', revision)
    end
    args.push(@resource.value(:source),
              @resource.value(:path))
    args.push(remote: true)
    hg_wrapper(*args)
  end

  def update_owner
    set_ownership if @resource.value(:owner) || @resource.value(:group)
  end

  def sensitive?
    (@resource.parameters.key?(:basic_auth_password) && @resource.parameters[:basic_auth_password].sensitive) ? true : false # Check if there is a sensitive parameter
  end

  def hg_wrapper(*args)
    options = { remote: false }
    if !args.empty? && args[-1].is_a?(Hash)
      options.merge!(args.pop)
    end

    if @resource.value(:basic_auth_username) && @resource.value(:basic_auth_password)
      args += [
        '--config', "auth.x.prefix=#{@resource.value(:source)}",
        '--config', "auth.x.username=#{@resource.value(:basic_auth_username)}",
        '--config', "auth.x.password=#{sensitive? ? @resource.value(:basic_auth_password).unwrap : @resource.value(:basic_auth_password)}",
        '--config', 'auth.x.schemes=http https'
      ]
    end

    if options[:remote] && @resource.value(:identity)
      args += ['--ssh', "ssh -oStrictHostKeyChecking=no -oPasswordAuthentication=no -oKbdInteractiveAuthentication=no -oChallengeResponseAuthentication=no -i #{@resource.value(:identity)}"]
    end

    args.map! { |a| (a =~ %r{\s}) ? "'#{a}'" : a } # Adds quotes to arguments with whitespaces.

    if @resource.value(:user) && @resource.value(:user) != Facter['id'].value
      Puppet::Util::Execution.execute("hg #{args.join(' ')}", uid: @resource.value(:user), failonfail: true, combine: true, sensitive: sensitive?)
    else
      Puppet::Util::Execution.execute("hg #{args.join(' ')}", sensitive: sensitive?)
    end
  end
end
