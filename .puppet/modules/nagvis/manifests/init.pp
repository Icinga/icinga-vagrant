class nagvis {
  class{'nagvis::params':} ->
  class{'nagvis::install':} ->
  class{'nagvis::config':} ->
  Class["nagvis"]
}
