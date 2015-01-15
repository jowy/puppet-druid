class druid::node::overlord (

  $listen                     = $fqdn,              # druid.host
  $port                       = '8080',             # druid.port

  $queue_delay                = 'PT0M',             # druid.indexer.queue.startDelay
  $runner_opts                = '-server -Xmx1g',   # druid.indexer.runner.javaOpts
  $runner_port                = '8081',             # druid.indexer.runner.startPort

  $fork_processing_threads    = $processorcount,    # druid.indexer.fork.property.druid.processing.numThreads
  $fork_processing_buffer     = '134217728',        # druid.indexer.fork.property.druid.computation.buffer.size

  $extensions = [
    "io.druid.extensions:druid-s3-extensions:${druid::version}",
  ],

) inherits druid {

  $mysql_uri = "jdbc:mysql://${mysql_host}:${mysql_port}/${mysql_db}"

  file { '/etc/druid/overlord':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $runprops = "/etc/druid/overlord/runtime.properties"

  Concat[$runprops] ~> Supervisor::Program['druid-overlord']

  concat{ $runprops:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment { 'druid-overlord-header':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/head.runtime.properties.erb'),
    order   => '001',
  }

  concat::fragment { 'druid-overlord-props':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/overlord.runtime.properties.erb'),
    order   => '100',
  }

  concat::fragment { 'druid-overlord-footer':
    ensure  => present,
    target  => $runprops,
    content => template('druid/node/foot.runtime.properties.erb'),
    order   => '999',
  }

  supervisor::program { 'druid-overlord':
    ensure      => present,
    enable      => true,
    command     => "/usr/bin/java -Xss$jvm_thread_stack_size -Xmx$jvm_heap_max  -XX:MaxPermSize=$jvm_max_perm_size -Duser.timezone=$timezone -Dfile.encoding=$encoding -classpath '${druid::druid_dir}/current/*:/etc/druid/overlord' io.druid.cli.Main server overlord",
    directory   => $druid::druid_dir,
    user        => 'druid',
    group       => 'druid',
  }

}