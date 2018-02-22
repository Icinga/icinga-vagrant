$pipelines = [
  {
    'pipeline.id' => 'pipeline_zero',
    'path.config' => '/tmp/pipeline_zero.conf',
  },
  {
    'pipeline.id' => 'pipeline_one',
    'path.config' => '/tmp/pipeline_one.conf',
  },
]

class { 'elastic_stack::repo':
  version    => 6,
  prerelease => true,
}

class { 'logstash':
  manage_repo => true,
  version     => '6.0.0-rc2',
  pipelines   => $pipelines,
}

logstash::configfile { 'pipeline_zero':
  content => 'input { heartbeat{} } output { null {} }',
  path    => '/tmp/pipeline_zero.conf',
}

logstash::configfile { 'pipeline_one':
  content => 'input { tcp { port => 2002 } } output { null {} }',
  path    => '/tmp/pipeline_one.conf',
}
