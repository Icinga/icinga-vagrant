Facter.add(:vcsrepo_svn_ver) do
  setcode do
    begin
      if Facter.value(:operatingsystem) == 'Darwin' && !File.directory?(Facter::Core::Execution.execute('xcode-select -p'))
        ''
      else
        version = Facter::Core::Execution.execute('svn --version --quiet')
        if Gem::Version.new(version) > Gem::Version.new('0.0.1')
          version
        else
          ''
        end
      end
    rescue StandardError
      ''
    end
  end
end
