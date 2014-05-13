class druid::node::realtime (

  $listen                 = $fqdn,                  # druid.host
  $port                   = '8080',                 # druid.port

  $processing_buffer      = '134217728',            # druid.processing.buffer.sizeBytes
  $processing_threads     = $processorcount,        # druid.processing.numThreads

  $publish_type           = 'db',

                                                    # todo: support many
  $segment_cache_max_size = '524288000',            # druid.segmentCache.locations => [0].maxSize

  $spec_hash              = {},

  $extensions = [
    "io.druid.extensions:druid-s3-extensions:${druid::version}",
    "io.druid.extensions:druid-rabbitmq:${druid::version}",
  ]

) inherits druid {

  $mysql_uri = "jdbc:mysql://${mysql_host}:${mysql_port}/${mysql_db}"

  file { '/etc/druid/realtime':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $segment_cache_dir = "${druid::druid_dir}/db/realtime"

  file { $segment_cache_dir:
    ensure => 'directory',
    mode   => '0744',
    owner  => 'druid',
    group  => 'druid',
  }

  $runprops = "/etc/druid/realtime/runtime.properties"

  Concat[$runprops] ~> Supervisor::Program['druid-realtime']

  concat{ $runprops:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment { 'druid-realtime-header':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/head.runtime.properties.erb'),
    order   => '001',
  }

  concat::fragment { 'druid-realtime-props':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/realtime.runtime.properties.erb'),
    order   => '100',
  }

  concat::fragment { 'druid-realtime-footer':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/foot.runtime.properties.erb'),
    order   => '999',
  }

  $spec_hash_json = sorted_json($spec_hash) 

  file { '/etc/druid/realtime/realtime.spec':
    ensure  => 'file',
    content => template('druid/node/realtime.spec.erb'),
    notify  => Supervisor::Program['druid-realtime'],
  }

  supervisor::program { 'druid-realtime':
    ensure      => present,
    enable      => true,
    command     => "/usr/bin/java -classpath '${druid::druid_dir}/current/*:/etc/druid/realtime' io.druid.cli.Main server realtime",
    directory   => $druid::druid_dir,
    user        => 'druid',
    group       => 'druid',
  }

}
