# filesystem_helpers.rb
module FilesystemHelpers
  def expect_chdir(path = resource.value(:path))
    expect(Dir).to receive(:chdir).with(path).at_least(:once).and_yield
  end

  def expect_mkdir(path = resource.value(:path))
    expect(Dir).to receive(:mkdir).with(path).once
  end

  def expect_rm_rf(path = resource.value(:path))
    expect(FileUtils).to receive(:rm_rf).with(path)
  end

  def expect_directory?(returns = true, path = resource.value(:path))
    expect(File).to receive(:directory?).with(path).and_return(returns)
  end
end
