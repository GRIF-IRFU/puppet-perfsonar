class perfsonar::firewall::ipv4(
  $ipt_allow_order=$perfsonar::params::firewall_order
) inherits perfsonar::params {
  #
  # ICMP
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific ICMP":
      proto  => 'icmp',
      icmp   => $perfsonar::params::icmp_types,
      chain  => 'INPUT',
      action => 'accept',
  }
  
  #
  # TCP ports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP ports (1)(stateless)":
      proto  => 'tcp',
      port   => $perfsonar::params::owamp_tcp_ports,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP ports (2)(stateless)":
      proto  => 'tcp',
      port   => $perfsonar::params::bwctl_tcp_ports,
      chain  => 'INPUT',
      action => 'accept',
  }

  perfsonar::firewall::allow_http {$perfsonar::params::http_allow:}

  #
  # UDP ports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (1)(stateless)":
      proto  => 'udp',
      port   => $perfsonar::params::owamp_udp_ports,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (2)(stateless)":
      proto  => 'udp',
      port   => $perfsonar::params::bwctl_udp_ports,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (3)(stateless)":
      proto  => 'udp',
      port   => $perfsonar::params::traceroute_ports,
      chain  => 'INPUT',
      action => 'accept',
  }
  
  
  #not in the FAQ:
#  firewall {"202 IN allow perfsonar PS specific ports (3)(stateless)":
#      proto => 'tcp',
#      port => [7],
#      chain => 'INPUT',
#      action  => 'accept',
#  }
}
