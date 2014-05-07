class druid (

  $version                = '0.6.105',
  $download_tool          = '/usr/bin/wget -O',
  $install_java           = true,
  $java_package           = 'openjdk-7-jre-headless',
  $druid_user             = 'druid',
  $druid_dir              = '/var/lib/druid',
  $release_repo           = 'http://static.druid.io/artifacts/releases',

  $mysql_host             = 'localhost',
  $mysql_port             = '3306',
  $mysql_db               = 'druid',
  $mysql_user             = 'root',       # druid.db.connector.user
  $mysql_pass             = '',           # druid.db.connector.password
  $use_validation_query   = 'true',       # druid.db.connector.useValidationQuery

  $storage_type           = 's3',         # druid.storage.type
  $storage_bucket         = '',           # druid.storage.bucket
  $storage_base_key       = 'realtime',   # druid.storage.baseKey
  $s3_access_key          = '123',        # druid.s3.accessKey
  $s3_secret_key          = '345',        # druid.s3.secretKey

  $timezone               = 'UTC',        # -Duser.timezone
  $encoding               = 'UTF-8',      # -Dfile.encoding
  $zk_host                = 'localhost',  # druid.zk.service.host
  $zk_compress            = false,        # druid.curator.compress
  $server_max_size        = '100000000',  # druid.server.maxSize
  $http_threads           = '100000000',  # druid.server.http.numThreads

) {

  class { 'druid::config':
    druid_dir   => $druid_dir,
    druid_user  => $druid_user,
  } ->

  class { 'druid::install':
    version        => $version,
    download_tool  => $download_tool,
    druid_dir      => $druid_dir,
    release_repo   => $release_repo,
    druid_user     => $druid_user,
  }

  if $install_java {
    class { 'druid::java':
      java_package => $java_package
    }
  }

}