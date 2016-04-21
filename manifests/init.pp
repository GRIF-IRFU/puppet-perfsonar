#
# Perfsonar PS base node.
#
# This is based on the netinstall kickstart :
# e.g :
# http://anonsvn.internet2.edu/svn/nptoolkit/trunk/kickstarts/centos6-netinstall.cfg
# link seen here
# http://code.google.com/p/esnet-perfsonar/wiki/CentOS6ToolkitBuilding
#
# or
# http://mirror.chpc.utah.edu/pub/perfsonar-toolkit/3.3/centos6-netinstall.cfg
#
# NO more support for 3.4-
class perfsonar(
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
  $site_projects = [],
  $administrator_email,
  $city,
  $state,
  $country,#This *MUST* be a ISO 3166 country code.
  $zipcode,
  $latitude,
  $longitude,

  #firewall related params. Can be changed either in hiera or as class params
  $icmp_types         = $perfsonar::params::icmp_types       ,
  $traceroute_ports   = $perfsonar::params::traceroute_ports ,
  $owamp_tcp_ports    = $perfsonar::params::owamp_tcp_ports  ,
  $owamp_udp_ports    = $perfsonar::params::owamp_udp_ports  ,
  $bwctl_peer_port    = $perfsonar::params::bwctl_peer_port  ,
  $bwctl_test_port    = $perfsonar::params::bwctl_test_port  ,
  $bwctl_nuttcp_port  = $perfsonar::params::bwctl_nuttcp_port,
  $bwctl_iperf_port   = $perfsonar::params::bwctl_iperf_port ,
  $bwctl_owamp_port   = $perfsonar::params::bwctl_owamp_port ,
  $bwctl_tcp_ports    = $perfsonar::params::bwctl_tcp_ports  ,
  $http_ports         = $perfsonar::params::http_ports       ,
  $firewall_order     = $perfsonar::params::firewall_order   ,
  $http_allow         = $perfsonar::params::http_allow       ,

  #select what kind of perfsonar package to install.
  # see : http://docs.perfsonar.net/install_options.html
  $ps_bundle='perfsonar-toolkit'
) inherits perfsonar::params {

  validate_bool($enable_repos, $enable_web100, $manage_ipv4_firewall, $manage_ipv6_firewall)
  validate_array($site_projects)

  if($enable_repos) { class { perfsonar::repos: enable_web100=>$enable_web100 } }

  #validate the target ps_package. See :
  #http://docs.perfsonar.net/install_options.html
  if($ps_bundle !~ /^perfsonar-(|tools|testpoint|core|toolkit|centralmanagement)$/) {
    fail("This perfsonar bundle ($ps_bundle) is not yet supported")
  }

  #packages list
  $iperf   = [ 'iperf3','iperf3-devel' ]
  $pkglist = [ 'web100_userland','owamp-client','owamp-server','bwctl-client','bwctl-server','ndt','npad','nuttcp',$ps_bundle,]


  #
  # install *latest* web100 kernel :
  # This is tricky, because OS kernels may be of higher version, and thus the "package" puppet type has issues
  #

  if $enable_web100 {
    exec { 'get-web100-kernel':
      path        => ['/usr/bin','/usr/sbin','/bin','/sbin',],
      command     => "yum upgrade \"kernel-2.6*web100.i686\"",
      refreshonly => true,
    }

    #kernel grub config - NEEDS REWORKING (yum list output not on a single line, running kernel is a PAE one...)
    $web100k='web100_kernel_update.sh'
    file { "/root/$web100k":
      source =>"puppet:///modules/perfsonar/${web100k}",
      ensure => present,
      mode   => '0755',
    }
    ->
    exec { 'make-web100-kern-default':
      command => "/root/${web100k}",
      refreshonly=>true,
      subscribe=>Exec['get-web100-kernel'],
    }
  }


  # install dependencies, as specified in the reference KS, then install perfsonar.
  #See, for each service :
  #http://psps.perfsonar.net/services.html
  package {
    ['libgomp','httpd','php','php-gd','php-xml','php-snmp','mysql','mysql-devel','perl-DBI','perl-DBD-MySQL']: ensure => present;
    $iperf: ensure => latest
  }
  ->
  package { $pkglist:
    ensure => present,
  }
  ~>
  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  #firewall
  if $manage_ipv4_firewall { include perfsonar::firewall::ipv4 }
  if $manage_ipv6_firewall { include perfsonar::firewall::ipv6 }


  #ps-PS 3.3+case
  file { "/etc/perfsonar/meshconfig-agent.conf" :
    ensure  => present,
    mode    => '0644',
    content => template("perfsonar/mesh_conf.3.3.erb"),
    owner   => perfsonar,group=>perfsonar,
    require => Package[$ps_bundle],
  }

  #
  # perfsonar webinterface user definition (root disallowed now)
  #
  user { $web_login:
    ensure   => present,
    shell    => '/bin/false',
    gid      => $web_login,
    groups   => 'psadmin',
    password => $web_pass,
  }
  group { 'psadmin':
    ensure  => present,
    require => Package[$ps_bundle],
  }
  group { $web_login:
    ensure  => present,
  }

  #
  # Some services
  #
  $ps_services={
    'perfsonar-lscachedaemon'         => {'pattern' => 'lscachedaemon.pl'},
    'perfsonar-lsregistrationdaemon'  => {'pattern' => 'lsregistrationdaemon'},
    'perfsonar-configdaemon'          => {'pattern' => 'config_daemon'},
    'cassandra'                       => {'hasstatus' => true },
  }

  create_resources('service' , $ps_services ,{hasstatus => false, hasrestart => true, require => Package[$ps_bundle], before => Service['httpd']})


  #administrative info setup

  #make sure the contry code matches an  ISO3166-like code
  if $country !~  /^[A-Z]{2}$/ {
    fail("The given perfsonar coutry code is invalid/not ISO3166 compliant : ${country}")
  }

  #the httpd lens changes space separated values into arrays : not easy to manage with that... replace spaces.
  $escaped_admin_name = regsubst($admin_name,' ','_','G' )
  $escaped_city       = regsubst($city,' ','_','G' )
  $escaped_site_name  = regsubst($site_name,' ','_','G' )

  augeas { "lsregistration config":
    lens    => 'Httpd.lns',
    incl    => '/etc/perfsonar/lsregistrationdaemon.conf',
    context => '/files/etc/perfsonar/lsregistrationdaemon.conf',
    changes => [
      "set directive[.='longitude'] 'longitude'",
      "set directive[.='longitude']/arg '${longitude}'",
      "set directive[.='latitude'] 'latitude'",
      "set directive[.='latitude']/arg '${latitude}'",
      "set directive[.='city'] 'city'",
      "set directive[.='city']/arg '${escaped_city}'",
      "set directive[.='site_name'] 'site_name'",
      "set directive[.='site_name']/arg '${escaped_site_name}'",
      "set directive[.='country'] 'country'",
      "set directive[.='country']/arg '${country}'",
      "set directive[.='zipcode'] 'zipcode'",
      "set directive[.='zipcode']/arg '${zipcode}'",
      #"touch administrator", #only for puppet4.
      "set administrator/directive[.='name'] 'name'",
      "set administrator/directive[.='name']/arg '${escaped_admin_name}'",
      "set administrator/directive[.='email'] 'email'",
      "set administrator/directive[.='email']/arg '$administrator_email'",
    ],
    require => Package[$ps_bundle], #otherwise, file can be created before RPM !
  }
  ~>
  Service['perfsonar-lsregistrationdaemon']

  #make sure bwctl ports are correct.
  #Note : since selection of the running daemons is done using the web interface, we must resort to not managing the service and using exec.
  exec {"refresh_bw":
      path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
      logoutput => true,
      command => "bash -c 'if pgrep bwctld >/dev/null ; then /sbin/service bwctld restart ; fi'", #make bwctl is restarted when config changes (condrestart)
      user => root,
      refreshonly => true,

  }

  #new location in 3.5+
  $bwctl_conf='/etc/bwctl-server/bwctl-server.conf'

  file_line { "peer_port": line => "peer_port ${perfsonar::bwctl_peer_port}", match => '^peer_port ' , path=>$bwctl_conf, notify => Exec['refresh_bw'] , require => Package[$ps_bundle] }
  file_line { "test_port": line => "test_port ${perfsonar::bwctl_test_port}", match => '^test_port ' , path=>$bwctl_conf, notify => Exec['refresh_bw'] , require => Package[$ps_bundle] }
  file_line { "nuttcp_port": line => "nuttcp_port ${perfsonar::bwctl_nuttcp_port}", match => '^nuttcp_port ' , path=>$bwctl_conf, notify => Exec['refresh_bw'] , require => Package[$ps_bundle] }
  file_line { "iperf_port": line => "iperf_port ${perfsonar::bwctl_iperf_port}", match => '^iperf_port ' , path=>$bwctl_conf, notify => Exec['refresh_bw'] , require => Package[$ps_bundle] }
  file_line { "owamp_port": line => "owamp_port ${perfsonar::bwctl_owamp_port}", match => '^owamp_port ' , path=>$bwctl_conf, notify => Exec['refresh_bw'] , require => Package[$ps_bundle] }

  #disable perfsonar sudo/root tempering
  #file_line { "perfsonar_adminuser": path => '/root/.bashrc', line => '#deleted psadmin_user directive', match => '.*psadmin_user --auto.*' , ensure=> present }
  #file_line { "perfsonar_sudouser": path => '/root/.bashrc', line => '#deleted pssudo_user directive', match => '.*pssudo_user --auto.*' , ensure=> present }
  exec { 'cleanup_sudo_psadmin':
    path    => ['/usr/bin','/usr/sbin','/bin','/sbin',],
    command => 'sed -i -re \'/^[^#]/s/(.*(psadmin|pssudo)_user.*)/#\1/\' /root/.bashrc',
    onlyif  => 'egrep -q "^[^#].*(psadmin|pssudo)_user.*" /root/.bashrc'
  }
}
