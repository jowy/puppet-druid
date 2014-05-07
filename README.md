##Druid Puppet Module

This is a basic puppet module for managing various [Druid] nodes. Druid is an open-source analytics data store designed for real-time exploratory queries on large-scale event data. Druid provides cost-effective, highly-available real-time data ingestion and arbitrary data exploration.

**Disclaimer:** This is a very rough module and has only been tested so far with Ubuntu 12.04 LTS 64bit, but should work with most Debian based distributions.

***

###Requirements:

* [Puppet stdlib]
* [Puppet supervisor]
* [Puppet concat]
* JRE (*will install `openjdk-7-jre-headless` by default*)
* AmazonS3 account for historical nodes
* Available [ZooKeeper] instance

***

###Todo:

+ **DRY things up**
+ **Better support for hiera**
+ **Dynamic nodes**
+ **Better indexing service support**
+ **Better supervisord handling**
+ Better download handling
+ More validations
+ Pre-configuration to run out of the box
+ Optional S3 (may not need historical)
+ Other platform support
+ Declarative RT node spec configuration

**NOTE:** Using the default *Realtime Node* configuration, you will be required to have a [RabbitMQ] instance available. See the extensions property for Class druid::node::realtime.

***

###Bootstrap

```
  class { 'druid':
    mysql_host        => 'localhost',
    mysql_port        => 3306,
    mysql_db          => 'druid',
    mysql_user        => 'root',
    mysql_pass        => 'root',
    storage_bucket    => 'some_awesome_bucket',
    storage_base_key  => 'some_bucket_base_key',
    s3_access_key     => 'SOME_KEY',
    s3_secret_key     => 'SOME_SECRET',
  }
```

***

###All nodes on single server

```
  # Druid Coordinator (cluster management)
  class { 'druid::node::coordinator':
    port  => 8090,
  }
  
  # Druid Historical (deep storage)
  class { 'druid::node::historical':
    port => 8091,
  }

  # Druid Realtime (event processing)
  class { 'druid::node::realtime':
    port        => 8092,
    spec_hash   => [{ ...my realtime spec... }],
  }

  # Druid Broker (query broker)
  class { 'druid::node::broker':
    port => 8093,
  }

  # Druid Overlord (indexing service)
  class { 'druid::node::overlord':
    port => 8094,
  }
```

***

###License

GNU General Public License v3 (GPL-3)

[Puppet stdlib]:https://forge.puppetlabs.com/puppetlabs/concat
[Puppet supervisor]:https://forge.puppetlabs.com/puppetlabs/concat
[Puppet concat]:https://forge.puppetlabs.com/puppetlabs/concat
[Druid]:http://druid.io/
[ZooKeeper]:http://zookeeper.apache.org/
[RabbitMQ]:https://www.rabbitmq.com/
