# This functions converts the Boolean values of a Hash to Integers,
# either '0' or '1'.  It does this recursively, decending as far as the
# language implemenation will allow.  Note that Structs and Arrays will
# be ignored, even if they contain Hashes.
#
# @private
#
# @param arg [Hash] The hash on which to operate
# @return [Hash]
#
# @example Usage
#
#   ```puppet
#   Hash $foo = {
#     bar => { 'a' => true, 'b' => 'b' },
#     baz => false,
#     qux => [{ 'c' => true }, { 'd' => false }],
#   }
#
#   yum::bool2num_hash_recursive($foo)
#   ```
#
#   The above would return:
#
#   ```puppet
#   {
#     bar => { 'a' => 1, 'b' => 'b' },
#     baz => 0,
#     qux => [{ 'c' => true }, { 'd' => false }],
#   }
#   ```
#
function yum::bool2num_hash_recursive($arg) {
  assert_type(Hash, $arg)
  $arg.map |$key, $value| {
    $return_value = $value ? {
      Boolean => bool2num($value),
      Hash    => yum::bool2num_hash_recursive($value),
      default => $value,
    }
    Hash({ $key => $return_value })
  }.reduce |$attrs_memo, $kv| {
    merge($attrs_memo, $kv)
  }
}
