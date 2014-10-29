#the puppetlabs module does not allow for source param beeing an array, nor does iptables.
#So until we use the new parser with looping, work that around :
define perfsonar::firewall::allow_http() {

  include perfsonar::params

  firewall { "200 IN allow perfsonar PS web interface access (stateless) from ${name}":
      proto  => 'tcp',
      dport  => $perfsonar::params::http_ports,
      source => $name,
      action => accept,
      chain  => 'INPUT',
  }
}
