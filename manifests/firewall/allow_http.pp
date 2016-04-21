#the puppetlabs module does not allow for source param beeing an array, nor does iptables.
#So until we use the new parser with looping, work that around :
#
# $order allow to override the puppetlabs firewall order
# $ip_proto : 4 or 6, for IPv4 or IPv6
define perfsonar::firewall::allow_http(
  $source_array=$name,
  $ipt_allow_order,
  $ip_proto=4,
) {

  $provider = $ip_proto ? {
    6 => 'ip6tables',
    default => undef,
  }

  $rule_suffix = $ip_proto ? {
    6 => 'v6',
    default => 'v4',
  }

  firewall { "${ipt_allow_order} IN allow perfsonar PS web interface access (stateless) from ${name} ${rule_suffix}":
      proto  => 'tcp',
      dport  => $perfsonar::http_ports,
      provider => $provider,
      source => $source_array,
      action => accept,
      chain  => 'INPUT',
  }
}
