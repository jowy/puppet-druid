class druid::java (

  $java_package = 'openjdk-7-jre-headless',

) {

  if!defined(Package[$java_package]) {
    package { $java_package:
      ensure => present
    }
  }

}