# == Function: deep_find_and_remove
#
# This function takes a hash as input, along with a string
# (key). Additionally, the optional removekey (defaults to
# 'puppetsource') is a parameter.
#
# The purpose of this function is to extract the 'options' subhash
# from the array of hashes given to provision dashboards. This options
# subhash may contain a path and source which puppet will use for
# provisioning: creating the path and applying the files from the
# source.
#
# Additionally, if the key 'puppetsource' exists in the sub-hash, it
# will be deleted from the structure. Thus the output of this function
# may be used in yaml format for grafana's provisioning
# configuration file for dashboards.
Puppet::Functions.create_function(:'grafana::deep_find_and_remove') do
  dispatch :deep_find_and_remove do
    param 'String', :key
    param 'Hash', :object
    optional_param 'String', :removekey
    return_type 'Array'
  end

  def deep_find_and_remove(key, object, removekey = 'puppetsource')
    foundpaths = []
    if object.respond_to?(:key?) && object.key?(key)
      foundpaths << object[key].dup
      object[key].delete(removekey)
    end
    if object.is_a? Enumerable
      foundpaths << object.map { |*a| deep_find_and_remove(key, a.last) }
    end
    foundpaths.flatten.compact
    foundpaths
  end
end
