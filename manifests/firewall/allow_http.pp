#the puppetlabs module does not allow for source param beeing an array, nor does iptables.
#So until we use the new parser with looping, work that around :
#
# $order allow to override the puppetlabs firewall order
define perfsonar::firewall::allow_http(
  $ipt_allow_order=$perfsonar::params::firewall_order
) {

  include perfsonar::params

  firewall { "${ipt_allow_order} IN allow perfsonar PS web interface access (stateless) from ${name}":
      proto  => 'tcp',
      dport  => $perfsonar::params::http_ports,
      source => $name,
      action => accept,
      chain  => 'INPUT',
  }
}
