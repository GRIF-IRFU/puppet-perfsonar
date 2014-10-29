/*
 * Perfsonar PS base node.
 * 
 * This is based on the netinstall kickstart :
 * e.g :
 * http://anonsvn.internet2.edu/svn/nptoolkit/trunk/kickstarts/centos6-netinstall.cfg
 * link seen here
 * http://code.google.com/p/esnet-perfsonar/wiki/CentOS6ToolkitBuilding 
 * 
 * or
 * http://mirror.chpc.utah.edu/pub/perfsonar-toolkit/3.3/centos6-netinstall.cfg
 * 
 */
class perfsonar(
  #perfsonar release to use : 3.4 by default
  $release='3.4',
  
  #the perfsonar 3.3+ mesh url list
  $meshlist=[], 
  
  #web interface login. That user will be member of the psadmin group, and will not be allowed to login.
  $web_login='admin',
  $web_pass, #no default : mandatory argument. Corresponds to what returns openssl passwd -1 -salt <your salt> <your password>
  
  #options
  $enable_repos=true,
  $enable_web100=false,
  $manage_ipv4_firewall=true,
  $manage_ipv6_firewall=true,
  
  #administrative information
  $admin_name,
  $site_name,
  $site_location,
  $administrator_email,
  $city,
  $state,
  $country, #This *MUST* be a ISO 3166 country code.
  $zipcode,
  $latitude,
  $longitude,
  
) inherits perfsonar::params {
  
  if($enable_repos) { class { perfsonar::repos: enable_web100=>$enable_web100 } }
  
  /*
   * iperf case :
   */

   case $release {
     /^3.2/ : {
       $iperf='iperf'
       $pkglist=[  web100_userland,owamp-client,owamp-server,bwctl-client,bwctl-server,ndt,npad,nuttcp,perl-perfSONAR_PS-LSRegistrationDaemon,perl-perfSONAR_PS-LSCacheDaemon,perl-perfSONAR_PS-LookupService,perl-perfSONAR_PS-SNMPMA,perl-perfSONAR_PS-PingER-server,perl-perfSONAR_PS-perfSONARBUOY-client,perl-perfSONAR_PS-perfSONARBUOY-server,perl-perfSONAR_PS-perfSONARBUOY-config,perl-perfSONAR_PS-TracerouteMA-config,perl-perfSONAR_PS-TracerouteMA-client,perl-perfSONAR_PS-TracerouteMA-server,perl-perfSONAR_PS-Toolkit,perl-perfSONAR_PS-Toolkit-SystemEnvironment,kmod-sk98lin]
     }
     /^3.3/ :{
       $iperf='iperf3'
       $pkglist=[  web100_userland,owamp-client,owamp-server,bwctl-client,bwctl-server,ndt,npad,nuttcp,perl-perfSONAR_PS-Toolkit,perl-perfSONAR_PS-Toolkit-SystemEnvironment,perl-perfSONAR_PS-LSCacheDaemon,perl-perfSONAR_PS-LSRegistrationDaemon,perl-perfSONAR_PS-MeshConfig-Agent,perl-perfSONAR_PS-PingER-server,perl-perfSONAR_PS-SimpleLS-BootStrap-client,perl-perfSONAR_PS-SNMPMA,perl-perfSONAR_PS-TracerouteMA-client,perl-perfSONAR_PS-TracerouteMA-config,perl-perfSONAR_PS-TracerouteMA-server,perl-perfSONAR_PS-perfSONARBUOY-client,perl-perfSONAR_PS-perfSONARBUOY-config,perl-perfSONAR_PS-perfSONARBUOY-server,kmod-sk98lin,tcptrace,xplot-tcptrace,tcpdump,]
     }
     #3.4+
     default :{
       $iperf='iperf3'
       $pkglist=[  web100_userland,owamp-client,owamp-server,bwctl-client,bwctl-server,ndt,npad,nuttcp,perl-perfSONAR_PS-Toolkit,perl-perfSONAR_PS-Toolkit-SystemEnvironment,perl-perfSONAR_PS-LSCacheDaemon,perl-perfSONAR_PS-LSRegistrationDaemon,perl-perfSONAR_PS-MeshConfig-Agent,perl-perfSONAR_PS-PingER-server,perl-perfSONAR_PS-SimpleLS-BootStrap-client,perl-perfSONAR_PS-SNMPMA,perl-perfSONAR_PS-TracerouteMA-client,perl-perfSONAR_PS-TracerouteMA-config,perl-perfSONAR_PS-TracerouteMA-server,perl-perfSONAR_PS-perfSONARBUOY-client,perl-perfSONAR_PS-perfSONARBUOY-config,perl-perfSONAR_PS-perfSONARBUOY-server,tcptrace,xplot-tcptrace,tcpdump,perl-Try-Tiny]
     }
   }
  
  /*
   * install *latest* web100 kernel :
   * This is tricky, because OS kernels may be of higher version, and thus the "package" puppet type has issues
   */
  
   if($enable_web100) {
     exec { 'get-web100-kernel':
      path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
      command => "yum upgrade \"kernel-2.6*web100.i686\"",
      refreshonly=>true,
      subscribe=>Exec[os_updates_os], #only run web100 upgrade after OS upgrade, so that kernel remains default grub kernel (if both are updated)    
    }
    
    #kernel grub config - NEEDS REWORKING (yum list output not on a single line, running kernel is a PAE one...) 
    $web100k='web100_kernel_update.sh'
    file { "/root/$web100k":
      source=>"puppet:///modules/perfsonar/${web100k}",
      ensure=> present,
      mode=> 0755,
    }
    ->
    exec { 'make-web100-kern-default':
      command => "/root/${web100k}",
      refreshonly=>true,
      subscribe=>Exec['get-web100-kernel'],
    }
  }
  
  
  #
  # Install packages now.
  #
  #install *UN*specified dependencies :
  package {
    [ perl-Params-Validate,
      perl-Class-Accessor, 
    ]: ensure=>present
  }
  ->
  # install dependencies, as specified in the reference KS, then install perfsonar.
  #See, for each service :
  #http://psps.perfsonar.net/services.html
  package {
    [libgomp,httpd,php,php-gd,php-xml,php-snmp,mysql,mysql-devel,perl-DBI,perl-DBD-MySQL,$iperf]: ensure=>present 
  }
  ->
  package {
    $pkglist:
    ensure=>present,
  }
  ~>
  service {
    'httpd': ensure=>running,
      enable => true,
      hasrestart => true,
      hasstatus => true,
  }
  
  
  #configure sudo for perfsonar :
  #is it still necessary ?
  sudo::conf { 'wheel':
      content  => "%wheel        ALL=(ALL)       ALL",
  }
  
  #firewall
  if ($manage_ipv4_firewall) { include perfsonar::firewall::ipv4 }
  if ($manage_ipv6_firewall) { include perfsonar::firewall::ipv6 }
  
  
  #ps-PS 3.3+case
  file { "/opt/perfsonar_ps/mesh_config/etc/agent_configuration.conf" :
    ensure=>present,
    mode=>750,
    content => template("perfsonar/mesh_conf.3.3.erb"),
    owner=>perfsonar,group=>perfsonar,
    require => Package[perl-perfSONAR_PS-MeshConfig-Agent],
  }
 
  #
  # perfsonar webinterface user definition (root disallowed now)
  #
  user { $web_login:
    ensure=>present,
    shell=>'/bin/false',
    gid=>$web_login,
    groups => 'psadmin',
    password=>$web_pass
  }
  group { 'psadmin': ensure=>present , require => Package[perl-perfSONAR_PS-Toolkit]}

  #
  # Some services
  #
  service {
    'ls_cache_daemon': 
      ensure=>running,
      hasstatus=>false,
      hasrestart=>true,
      require=>Package[perl-perfSONAR_PS-LSRegistrationDaemon]
    ;
    'ls_registration_daemon' : 
      ensure=>running,
      hasstatus=>false,
      hasrestart=>true,
      require=>Package[perl-perfSONAR_PS-LSCacheDaemon]
    ;
    'cassandra' : 
      ensure=>running,
      hasstatus=>true,
      hasrestart=>true,
      require=>Package[perl-perfSONAR_PS-Toolkit], #cassandra required by esmond, itself required by this one
    ;
    'config_daemon' : 
      ensure=>running,
      hasstatus=>false,
      hasrestart=>true,
      require=>Package[perl-perfSONAR_PS-Toolkit]
    ;
  }
  -> Service[httpd]
  
  
  #administrative info setup
  
  #make sure the contry code matches an  ISO3166-like code
  if ($country =~  /^[A-Z]{2}$/) {
    $countrycode=$country
    }
  else {
    $countrycode=''
    err("The given perfsonar coutry code is invalid/not ISO3166 compliant : ${country}")
  }
  
  $admin_cfg='/opt/perfsonar_ps/toolkit/etc/administrative_info'
  Package[perl-perfSONAR_PS-Toolkit]
  ->
  file_line {
    "admin_name": line => "full_name=${admin_name}", match=>'^full_name', path => $admin_cfg;
    "site_name": line=> "site_name=${site_name}", match =>'^site_name', path => $admin_cfg;
    "site_location": line=> "site_location=${site_location}", match =>'^site_location', path => $admin_cfg;
    "administrator_email": line=> "administrator_email=${administrator_email}", match =>'^administrator_email', path => $admin_cfg;
    "city": line=> "city=${city}", match =>'^city', path => $admin_cfg;
    "state": line=> "state=${state}", match =>'^state', path => $admin_cfg;
    "country": line=> "country=${country}", match =>'^country', path => $admin_cfg;
    "zipcode": line=> "zipcode=${zipcode}", match =>'^zipcode', path => $admin_cfg;
    "latitude": line=> "latitude=${latitude}", match =>'^latitude', path => $admin_cfg;
    "longitude": line=> "longitude=${longitude}", match =>'^longitude', path => $admin_cfg;
  }
  ~>
  exec { '/opt/perfsonar_ps/toolkit/scripts/update_administrative_info.pl':
    refreshonly => true,
    require => Package[perl-perfSONAR_PS-Toolkit]
  }
}
