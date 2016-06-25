Puppet::Type.newtype(:file_fragment) do
  @doc = "Create a file fragment to be used by file_concat.
    the `file_fragment` type creates a file fragment to be collected by file_concat based on the tag.
    The example is based on exported resources.

    Example:
    @@file_fragment { \"uniqe_name_${::fqdn}\":
      tag => 'unique_name',
      order => 10, # Optional. Default to 10
      content => 'some content' # OR
      content => template('template.erb') # OR
      source  => 'puppet:///path/to/file'
    }
  "

  newparam(:name, :namevar => true) do
    desc "Unique name"
  end

  newparam(:content) do
    desc "Content"
  end

  newparam(:source) do
    desc "Source"
  end

  newparam(:order) do
    desc "Order"
    defaultto '10'
    validate do |val|
      fail Puppet::ParseError, '$order is not a string or integer.' if !(val.is_a? String or val.is_a? Integer)
      fail Puppet::ParseError, "Order cannot contain '/', ':', or '\n'." if val.to_s =~ /[:\n\/]/
    end
  end

  newparam(:tag) do
    desc "Tag name to be used by file_concat to collect all file_fragments by tag name"
  end

  validate do
    # Check if either source or content is set. raise error if none is set
    fail Puppet::ParseError, "Set either 'source' or 'content'" if self[:source].nil? && self[:content].nil?

    # Check if both are set, if so rais error
    fail Puppet::ParseError, "Can't use 'source' and 'content' at the same time" if !self[:source].nil? && !self[:content].nil?
  end
end
