type Prometheus::Uri = Variant[
  Stdlib::HTTPUrl,
  Stdlib::HTTPSUrl,
  Prometheus::S3Uri,
]
