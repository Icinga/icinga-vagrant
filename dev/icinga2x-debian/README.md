
## Build

```
apt-get -y install gdb vim git cmake make ccache build-essential libssl-dev libboost-all-dev bison flex default-libmysqlclient-dev libpq-dev libyajl-dev libedit-dev

ln -s /usr/bin/ccache /usr/local/bin/g++

groupadd icinga
groupadd icingacmd
useradd -c "icinga" -s /sbin/nologin -G icingacmd -g icinga icinga

git clone https://github.com/icinga/icinga2.git && cd icinga2

mkdir debug release
cd debug
cmake .. -DCMAKE_BUILD_TYPE=Debug -DICINGA2_UNITY_BUILD=OFF -DCMAKE_INSTALL_PREFIX=/usr/local/icinga2 -DICINGA2_PLUGINDIR=/usr/local/sbin
cd ..
make -j2 install -C debug
```


```
cd /usr/local/icinga2
./lib/icinga2/prepare-dirs etc/sysconfig/icinga2
icinga2 api setup
icinga2 daemon
```


## Tests


```
while :; do /usr/lib/nagios/plugins/check_http -H localhost -p 5665 -S -e '401 Unauthorized' -N > /dev/null; done
```

```
watch -n 1 'for pid in $(pidof icinga2); do ps -T -p $pid | grep -F icinga2; done | wc -l'
```
