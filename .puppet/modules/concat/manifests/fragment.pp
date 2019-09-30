# @summary
#   Manages a fragment of text to be compiled into a file.
#
# @param content
#   Supplies the content of the fragment. Note: You must supply either a content parameter or a source parameter.
#
# @param order
#   Reorders your fragments within the destination file. Fragments that share the same order number are ordered by name. The string
#   option is recommended.
#
# @param source
#   Specifies a file to read into the content of the fragment. Note: You must supply either a content parameter or a source parameter.
#   Valid options: a string or an array, containing one or more Puppet URLs.
#
# @param target
#   Specifies the destination file of the fragment. Valid options: a string containing the path or title of the parent concat resource.
#
define concat::fragment(
  String                             $target,
  Optional[String]                   $content = undef,
  Optional[Variant[String, Array]]   $source  = undef,
  Variant[String, Integer]           $order   = '10',
) {
  $resource = 'Concat::Fragment'

  if ($order =~ String and $order =~ /[:\n\/]/) {
    fail(translate("%{_resource}['%{_title}']: 'order' cannot contain '/', ':', or '\\n'.", {'_resource' => $resource, '_title' => $title}))
  }

  if ! ($content or $source) {
    crit('No content, source or symlink specified')
  } elsif ($content and $source) {
    fail(translate("%{_resource}['%{_title}']: Can't use 'source' and 'content' at the same time.", {'_resource' => $resource, '_title' => $title}))
  }

  $safe_target_name = regsubst($target, '[\\\\/:~\n\s\+\*\(\)@]', '_', 'GM')

  concat_fragment { $name:
    target  => $target,
    tag     => $safe_target_name,
    order   => $order,
    content => $content,
    source  => $source,
  }
}
