class druid::node::broker (

  $listen               = $fqdn,                # druid.host
  $port                 = '8080',               # druid.port

  $processing_buffer    = '134217728',          # druid.processing.buffer.sizeBytes
  $processing_threads   = $processorcount,      # druid.processing.numThreads

) inherits druid {

  $mysql_uri = "jdbc:mysql://${mysql_host}:${mysql_port}/${mysql_db}"

  file { '/etc/druid/broker':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $runprops = "/etc/druid/broker/runtime.properties"

  Concat[$runprops] ~> Supervisor::Program['druid-broker']

  concat{ $runprops:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment { 'druid-broker-header':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/head.runtime.properties.erb'),
    order   => '001',
  }

  concat::fragment { 'druid-broker-props':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/broker.runtime.properties.erb'),
    order   => '100',
  }

  concat::fragment { 'druid-broker-footer':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/foot.runtime.properties.erb'),
    order   => '999',
  }

  supervisor::program { 'druid-broker':
    ensure      => present,
    enable      => true,
    command     => "/usr/bin/java -Xmx$jvm_heap_max -Duser.timezone=$timezone -Dfile.encoding=$encoding -classpath '${druid::druid_dir}/current/*:/etc/druid/broker' io.druid.cli.Main server broker",
    directory   => $druid::druid_dir,
    user        => 'druid',
    group       => 'druid',
  }

}