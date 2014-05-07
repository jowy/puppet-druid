class druid::config (

  $druid_user = $druid_user,

  $druid_dir  = $druid_dir,

) {

  User['druid'] -> File['druid_lib_home'] -> Exec['druid_lib_dirs']

  user { 'druid':
    shell  => '/bin/sh',
    home   => $druid_dir,
    ensure => 'present',
  }

  exec { 'druid_lib_dirs':
    command => "/bin/mkdir -p ${druid_dir}/sources ${druid_dir}/releases ${druid_dir}/db",
    creates => $sources_dir,
    user    => $druid_user,
  }

  file { 'druid_lib_home':
    path    => $druid_dir,
    ensure  => 'directory',
    mode    => '0750',
    owner   => $druid_user,
    group   => $druid_user,
    recurse => true,
    recurselimit => 1,
  }

  file { '/etc/druid':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

}