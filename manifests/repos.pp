/*
 * The non mirrored internet2 repos. *This is RHEL ONLY !*
 */
class perfsonar::repos( $enable_web100 = false ) {

  #first, put the gpg repo file in place.

  #where to store the gpg file
  $gpgpath = '/etc/pki/rpm-gpg'
  $gpgfile = 'RPM-GPG-KEY-Internet2'

  file { $gpgfile:
    ensure => present,
    source => "puppet:///modules/perfsonar/${gpgfile}",
    path   => "${gpgpath}/${gpgfile}",
    #notify => Exec['OS gpgfiles import'],
  }

  yumrepo { 'Internet2':
    baseurl  => "http://software.internet2.edu/rpms/el${::operatingsystemmajrelease}/\$basearch/main",
    gpgkey   => "file://${gpgpath}/${gpgfile}",
    descr    => 'Internet2 RPM Repository - software.internet2.edu - main',
    enabled  => 1,
    gpgcheck => 1,
    require  => File[$gpgfile],
  }->
  #this is here in case the yum repos.d dir is purged by your manifests
  file { '/etc/yum.repos.d/Internet2.repo':
    ensure => present,
  }

  if($enable_web100) {
    yumrepo { 'Internet2-web100':
      baseurl  => "http://software.internet2.edu/web100_kernel/rpms/el${::operatingsystemmajrelease}/\$basearch/main",
      gpgkey   => "file://${gpgpath}/${gpgfile}",
      descr    => 'Internet2 web100 Kernel RPM Repository - software.internet2.edu - main',
      enabled  => 1,
      gpgcheck => 1,
      require  => File[$gpgfile],
    }
  }

}
