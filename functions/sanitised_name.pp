# == Function: docker::sanitised_name
#
# Function to sanitise container name.
#
# === Parameters
#
# [*name*]
#   Name to sanitise
#
function docker::sanitised_name($name){
  regsubst($name, '[^0-9A-Za-z.\-_]', '-', 'G')
}
