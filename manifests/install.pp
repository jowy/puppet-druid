class druid::install (

  $version        = '0.6.105',
  $download_tool  = '/usr/bin/wget -O',
  $druid_user     = 'druid',
  $druid_dir      = '/var/lib/druid',
  $release_repo   = 'http://static.druid.io/artifacts/releases',

) {

  File['druid_release'] ~>
  Exec['download_druid_version'] ~>
  Exec['extract_druid_version'] ->
  File['symlink_current_dir']

  $release_dir  = "${druid_dir}/releases/${version}"
  $release_file = "druid-services-${version}-bin.tar.gz"
  $source_path  = "${druid_dir}/sources/${release_file}"

  file { 'druid_release':
    path   => $release_dir,
    ensure => 'directory',
    owner  => 'druid',
    group  => 'druid',
    mode   => '0750',
  }

  exec { 'download_druid_version':
    command => "${download_tool} ${source_path} ${release_repo}/${release_file} 2> /dev/null",
    creates => $source_path,
    timeout => 300,
    user    => 'druid',
  }

  exec { 'extract_druid_version':
    command     => "/bin/tar zxf ${source_path} -C ${release_dir}/ 2> /dev/null",
    refreshonly => true,
    user        => 'druid',
  }

  file { 'symlink_current_dir':
    path   => "${druid_dir}/current",
    target => "${release_dir}/druid-services-${version}/lib",
    ensure => 'link',
  }

}
