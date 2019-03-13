# == Function get_sub_paths
#
# This function receives an input path as an input parameter, and
# returns an array of the subpaths in the input, excluding the input
# path itself. The function will attempt to ignore any extra slashes
# in the path given.
#
# This function will only work on UNIX paths with forward slashes (/).
#
# Examples:
# input = '/var/lib/grafana/dashboards'
# output = [ '/var', '/var/lib', '/var/lib/grafana'/ ]
#
# input = '/opt'
# output = []
#
# input = '/first/second/'
# output = [ '/first' ]
Puppet::Functions.create_function(:'grafana::get_sub_paths') do
  dispatch :get_sub_paths do
    param 'String', :inputpath
    return_type 'Array'
  end

  def get_sub_paths(inputpath)
    ip = inputpath.gsub(%r{/+}, '/')
    allsubs = []
    parts = ip.split('/')
    parts.each_with_index do |value, index|
      next if index.zero? || index == (parts.length - 1)
      allsubs << if index == 1
                   '/' + value
                 else
                   allsubs[index - 2] + '/' + value
                 end
    end
    allsubs
  end
end
