## 0.9.0 (2019-08-01)

- Fix problem with missing "/etc/apt/apt.conf.d" directory (#31)
  - **Attention:** This also changes the proxy configuration file from `/etc/apt/apt.conf.d/01proxy`
    to `/etc/apt/apt.conf.d/01_graylog_proxy`. Make sure to remove the old one when upgrading
    this module.
- Run apt-get update after adding repo and before installing server package (#32)

## 0.8.0 (2019-02-14)

- Update for Graylog 3.0.0
- Add capability for installation behind proxy (yum/apt) (#20)
- Don't force `show_diff` to `true` (#24)
- Bump required stdlib version to 4.16 for the length function (#23)

## 0.7.0 (2018-11-30)

- Update for Graylog 2.5.0
- Allow puppetlabs-apt < 7.0.0, puppetlabs-stdlib < 6.0.0 (#27)

## 0.6.0 (2018-02-02)

- Replace deprecated size() with length() (#22, #21)
- Replace deprecated elasticsearch module references (#17)
- Replace deprecated mongodb module references
- Allow puppetlabs/apt module version >3.0.0 (#16)

## 0.5.0 (2017-12-22)

- Update for Graylog 2.4.0

## 0.4.0 (2017-07-26)

- Update for Graylog 2.3.0

## 0.3.0 (2017-03-06)

- Adding a more complex example to README (#11)
- Fix variable scoping (#12, #10)
- Prepare for Graylog 2.2.0
- Fix dependency declaration in metadata.json (#8)
- Replace own custom function with `merge` from stdlib. (#4)
- Make the Vagrant setup work (#3)

## 0.2.0 (2016-09-01)

- Use Graylog 2.1.0 as default version
- Fixed a typo in the README

## 0.1.0 (2016-04-29)

Initial Release
