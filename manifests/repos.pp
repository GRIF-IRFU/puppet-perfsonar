/*
 * The non mirrored internet2 repos. *This is RHEL ONLY !*
 */
class perfsonar::repos($enable_web100=false) {
  
  #first, put the gpg repo file in place.
  $gpgpath='/etc/pki/rpm-gpg' #where to store the gpg file
  $gpgfile='RPM-GPG-KEY-Internet2'
  
  file { $gpgfile:
    source=>"puppet:///modules/perfsonar/${gpgfile}",
    path=>"${gpgpath}/${gpgfile}",
    ensure => present,
    #notify => Exec['OS gpgfiles import'],
  }
  
  ->
  
  yumrepo { "Internet2":
    baseurl => "http://software.internet2.edu/rpms/el${::operatingsystemmajrelease}/\$basearch/main",
    gpgkey => "file://${gpgpath}/${gpgfile}",
    descr => "Internet2 RPM Repository - software.internet2.edu",
    enabled => 1,
    gpgcheck => 1,
  }
  ->
  file {'/etc/yum.repos.d/Internet2.repo': ensure => present} #this is here in case the yum repos.d dir is purged by your manifests
  
  if($enable_web100) { 
    
    yumrepo { "Internet2-web100":
      baseurl => "http://software.internet2.edu/web100_kernel/rpms/el${::operatingsystemmajrelease}/\$basearch/main",
      gpgkey => "file://${gpgpath}/${gpgfile}",
      descr => "Internet2 web100 Kernel RPM Repository - software.internet2.edu",
      enabled => 1,
      gpgcheck => 1,
      }
  }
  
}
