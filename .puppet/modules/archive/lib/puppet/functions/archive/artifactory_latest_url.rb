require 'json'
require 'puppet_x/bodeco/util'

Puppet::Functions.create_function(:'archive::artifactory_latest_url') do
  dispatch :artifactory_latest_url do
    param 'Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]', :url
    param 'Hash', :maven_data
  end

  def artifactory_latest_url(url, maven_data)
    # Turn provided artifactory URL into the fileinfo API endpoint of the parent directory
    uri = URI(url.sub('/artifactory/', '/artifactory/api/storage/')[%r{^(.*)/.*$}, 1])

    response = PuppetX::Bodeco::Util.content(uri)
    content  = JSON.parse(response)

    uris = if maven_data['classifier']
             content['children'].select do |child|
               child['uri'] =~ %r{^/#{maven_data['module']}-#{maven_data['base_rev']}-(SNAPSHOT|(?:(?:[0-9]{8}.[0-9]{6})-(?:[0-9]+)))-#{maven_data['classifier']}\.#{maven_data['ext']}$} && !child['folder']
             end
           else
             content['children'].select do |child|
               child['uri'] =~ %r{^/#{maven_data['module']}-#{maven_data['base_rev']}-(SNAPSHOT|(?:(?:[0-9]{8}.[0-9]{6})-(?:[0-9]+)))\.#{maven_data['ext']}$} && !child['folder']
             end
           end

    raise("Couldn't find any Artifactory artifacts") if uris.empty?

    latest = uris.sort_by { |x| x['uri'] }.last['uri']
    Puppet.debug("Latest artifact found for #{url} was #{latest}")

    # Now GET the fileinfo endpoint of the resolved latest version file
    uri = URI("#{content['uri']}#{latest}")
    response = PuppetX::Bodeco::Util.content(uri)
    content  = JSON.parse(response)

    url  = content['downloadUri']
    sha1 = content['checksums'] && content['checksums']['sha1']

    {
      'url'  => url,
      'sha1' => sha1
    }
  end
end
