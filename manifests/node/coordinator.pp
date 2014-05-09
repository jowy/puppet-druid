class druid::node::coordinator (

  $jvm_heap_max           = '256m',         # -Xmx

  $listen                 = $fqdn,          # druid.host
  $port                   = '8080',         # druid.port

  $period                 = 'PT60S',        # druid.coordinator.period
  $indexing_period        = 'PT1800S',      # druid.coordinator.period.indexingPeriod
  $start_delay            = 'PT30S',        # druid.coordinator.startDelay
  $merge_on               = 'PT300S',       # druid.coordinator.merge.on
  $conversion_on          = 'false',        # druid.coordinator.conversion.on
  $load_timeout           = 'PT15M',        # druid.coordinator.load.timeout

  $segment_poll_duration  = 'PT1M',         # druid.manager.segment.pollDuration
  $rules_poll_duration    = 'PT1M',         # druid.manager.rules.pollDuration
  $rules_default_tier     = '_default',     # druid.manager.rules.defaultTier

  $custom_properties      = {},

) inherits druid {

  $mysql_uri = "jdbc:mysql://${mysql_host}:${mysql_port}/${mysql_db}"

  file { '/etc/druid/coordinator':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $runprops = "/etc/druid/coordinator/runtime.properties"

  Concat[$runprops] ~> Supervisor::Program['druid-coordinator']

  concat{ $runprops:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment { 'druid-coordinator-header':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/head.runtime.properties.erb'),
    order   => '001',
  }

  concat::fragment { 'druid-coordinator-props':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/coordinator.runtime.properties.erb'),
    order   => '100',
  }

  concat::fragment { 'druid-coordinator-footer':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/foot.runtime.properties.erb'),
    order   => '999',
  }

  supervisor::program { 'druid-coordinator':
    ensure      => present,
    enable      => true,
    command     => "/usr/bin/java -classpath '${druid::druid_dir}/current/*:/etc/druid/coordinator' io.druid.cli.Main server coordinator",
    directory   => $druid::druid_dir,
    user        => 'druid',
    group       => 'druid',
  }

}