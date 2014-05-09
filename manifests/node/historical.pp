class druid::node::historical (

  $jvm_heap_max           = '256m',                 # -Xmx

  $listen                 = $fqdn,                  # druid.host
  $port                   = '8080',                 # druid.port

  $processing_buffer      = '10000000',             # druid.processing.buffer.sizeBytes
  $processing_threads     = $processorcount * 2,    # druid.processing.numThreads

  $segment_cache_max_size = '',                     # druid.segmentCache.locations

  $extensions = [
    "io.druid.extensions:druid-s3-extensions:${druid::version}"
  ],

) inherits druid {

  $mysql_uri = "jdbc:mysql://${mysql_host}:${mysql_port}/${mysql_db}"

  file { '/etc/druid/historical':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $segment_cache_dir = "${druid::druid_dir}/db/historical"

  file { $segment_cache_dir:
    ensure => 'directory',
    mode   => '0744',
    owner  => 'druid',
    group  => 'druid',
  }

  $runprops = "/etc/druid/historical/runtime.properties"

  Concat[$runprops] ~> Supervisor::Program['druid-historical']

  concat{ $runprops:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment { 'druid-historical-header':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/head.runtime.properties.erb'),
    order   => '001',
  }

  concat::fragment { 'druid-historical-props':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/historical.runtime.properties.erb'),
    order   => '100',
  }

  concat::fragment { 'druid-historical-footer':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/foot.runtime.properties.erb'),
    order   => '999',
  }

  supervisor::program { 'druid-historical':
    ensure      => present,
    enable      => true,
    command     => "/usr/bin/java -classpath '${druid::druid_dir}/current/*:/etc/druid/historical' io.druid.cli.Main server historical",
    directory   => $druid::druid_dir,
    user        => 'druid',
    group       => 'druid',
  }

}