require 'puppet/util/checksums'

Puppet::Type.newtype(:file_concat) do
  @doc = "Gets all the file fragments and puts these into the target file.
    This will mostly be used with exported resources.

    example:
      File_fragment <<| tag == 'unique_tag' |>>

      file_concat { '/tmp/file:
        tag            => 'unique_tag', # Mandatory
        path           => '/tmp/file',  # Optional. If given it overrides the resource name
        owner          => 'root',       # Optional. Default to undef
        group          => 'root',       # Optional. Default to undef
        mode           => '0644',       # Optional. Default to undef
        order          => 'numeric',    # Optional, Default to 'numeric'
        ensure_newline => false,        # Optional, Defaults to false
      }
  "
  ensurable do
    defaultvalues

    defaultto { :present }
  end

  def exists?
    self[:ensure] == :present
  end

  newparam(:name, :namevar => true) do
    desc "Resource name"
  end

  newparam(:tag) do
    desc "Tag reference to collect all file_fragment's with the same tag"
  end

  newparam(:path) do
    desc "The output file"
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:owner) do
    desc "Desired file owner."
  end

  newparam(:group) do
    desc "Desired file group."
  end

  newparam(:mode) do
    desc "Desired file mode."
  end

  newparam(:order) do
    desc "Controls the ordering of fragments. Can be set to alphabetical or numeric."
    defaultto 'numeric'
  end

  newparam(:backup) do
    desc "Controls the filebucketing behavior of the final file and see File type reference for its use."
    defaultto 'puppet'
  end

  newparam(:replace) do
    desc "Whether to replace a file that already exists on the local system."
    defaultto true
  end

  newparam(:validate_cmd) do
    desc "Validates file."
  end

  newparam(:ensure_newline) do
    desc "Whether to ensure there is a newline after each fragment."
    defaultto false
  end

  autorequire(:file) do
    [self[:path]]
  end

  autorequire(:file_fragment) do
    catalog.resources.collect do |r|
      if r.is_a?(Puppet::Type.type(:file_fragment)) && r[:tag] == self[:tag]
        r.name
      end
    end.compact
  end

  def should_content
    return @generated_content if @generated_content
    @generated_content = ""
    content_fragments = []

    resources = catalog.resources.select do |r|
      r.is_a?(Puppet::Type.type(:file_fragment)) && r[:tag] == self[:tag]
    end

    resources.each do |r|
      content_fragments << ["#{r[:order]}___#{r[:name]}", fragment_content(r)]
    end

    if self[:order] == 'numeric'
      sorted = content_fragments.sort do |a, b|
        def decompound(d)
          d.split('___').map { |v| v =~ /^\d+$/ ? v.to_i : v }
        end

        decompound(a[0]) <=> decompound(b[0])
      end
    else
      sorted = content_fragments.sort do |a, b|
        def decompound(d)
          d.split('___').first
        end

        decompound(a[0]) <=> decompound(b[0])
      end
    end

    @generated_content = sorted.map { |cf| cf[1] }.join

    @generated_content
  end

  def fragment_content(r)
    if r[:content].nil? == false
      fragment_content = r[:content]
    elsif r[:source].nil? == false
      @source = nil
      Array(r[:source]).each do |source|
        if Puppet::FileServing::Metadata.indirection.find(source)
          @source = source 
          break
        end
      end
      self.fail "Could not retrieve source(s) #{Array(r[:source]).join(", ")}" unless @source
      tmp = Puppet::FileServing::Content.indirection.find(@source)
      fragment_content = tmp.content unless tmp.nil?
    end

    if self[:ensure_newline]
      fragment_content << "\n" unless fragment_content =~ /\n$/
    end

    fragment_content
  end

  def eval_generate
    content = self.should_content

    file_opts = {}
    file_opts[:ensure] = self[:ensure] == :absent ? :absent : :file
    file_opts[:content] = content if !content.nil? and !content.empty?

    [:path, :owner, :group, :mode, :replace, :backup].each do |param|
      unless self[param].nil?
        file_opts[param] = self[param]
      end
    end

    [Puppet::Type.type(:file).new(file_opts)]
  end
end
