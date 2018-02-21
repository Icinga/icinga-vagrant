export ASSUME_ALWAYS_YES=YES
pkg bootstrap
pkg update -f
pkg install -y puppet4
