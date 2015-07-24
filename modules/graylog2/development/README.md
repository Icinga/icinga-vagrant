Graylog Puppet Module Development
=================================

## Generate server-config.defaults

The `server-config-defaults.txt` file can be used to detect new configuration
options for the graylog2-server.

```
java -jar /path/to/graylog2-bootstrap/target/graylog2.jar server \
    -f misc/graylog2.conf --dump-config | \
    grep -v -e '^#' -e '^$' -e 'INFO : ' | \
    sort -u > server-config.defaults'
```

Just diff the newly created file to see any changes to the default config.
