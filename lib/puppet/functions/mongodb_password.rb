require_relative File.join('..', 'util', 'mongodb_md5er')

# Get the mongodb password hash from the clear text password.
Puppet::Functions.create_function(:mongodb_password) do
  dispatch :mongodb_password do
    param 'String[1]', :username
    param 'String[1]', :password
    return_type 'String'
  end

  def mongodb_password(username, password)
    Puppet::Util::MongodbMd5er.md5(username, password)
  end
end
