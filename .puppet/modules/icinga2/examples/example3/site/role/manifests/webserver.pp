class role::webserver inherits role::monitorednode {
    contain profile::php
    contain profile::nginx
}
