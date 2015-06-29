#see : http://www.perfsonar.net/deploy/security-considerations/
#
# this params class will be the authoritative source both for daemons and firewall configuration 
class perfsonar::params(
  $icmp_types       = '255',
  $traceroute_ports = '33434-33634',
  $owamp_tcp_ports  = '861',
  $owamp_udp_ports  = '8760-9960',
  $bwctl_tcp_ports  = [4823, 6001-6200, 5000-5900],
  $bwctl_udp_ports  = [6001-6200, 5000-5900],
  $http_ports       = [80,443],
  
  #this defines the order that will be used when defining firewall rules. Changing it might allow to reorder your iptable rules.
  #note : if you put leading 0s, this must be a string...
  $firewall_order    = '200',

  #define who will be allowed to access the perfsonar HTTP(s) interfaces
  #by default : OSG monitoring net, and AGLT2 monitoring host
  $http_allow = ['129.79.53.0/24','192.41.231.110/32']
) {

}
