# A function to parse an Artifactory maven 2 repository URL
Puppet::Functions.create_function(:'archive::parse_artifactory_url') do
  dispatch :parse_artifactory_url do
    param 'Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]', :url
  end

  def parse_artifactory_url(url)
    # Regex is for the 'maven-2-default Repository Layout'
    matchdata = url.match(%r{
             (?<base_url>.*/artifactory)
             /
             (?<repository>[^/]+)
             /
             (?<org_path>.+?)
             /
             (?<module>[^/]+)
             /
             (?<base_rev>[^/]+?)
             (?:-(?<folder_iteg_rev>SNAPSHOT))?
             /
             \k<module>-\k<base_rev>
             (?:-(?<file_iteg_rev>SNAPSHOT|(?:(?:[0-9]{8}.[0-9]{6})-(?:[0-9]+))))?
             (?:-(?<classifier>[^/]+?))?
             \.
             (?<ext>(?:(?!\d))[^\-/]+|7z)
             }x)
    return nil unless matchdata
    Hash[matchdata.names.zip(matchdata.captures)]
  end
end
