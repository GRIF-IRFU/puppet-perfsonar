class perfsonar::firewall::ipv4(
  $ipt_allow_order=$perfsonar::firewall_order
) {
  #
  # ICMP
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific ICMP":
      proto  => 'icmp',
      icmp   => $perfsonar::icmp_types,
      chain  => 'INPUT',
      action => 'accept',
  }

  #
  # TCP ports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP ports (1)(stateless)":
      proto  => 'tcp',
      dport   => $perfsonar::owamp_tcp_ports ,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP ports (2)(stateless)":
      proto  => 'tcp',
      dport   => concat($perfsonar::bwctl_tcp_ports , $perfsonar::bwctl_test_port , $perfsonar::bwctl_peer_port ),
      chain  => 'INPUT',
      action => 'accept',
  }

  perfsonar::firewall::allow_http {$perfsonar::http_allow: ipt_allow_order => $ipt_allow_order}

  #
  # UDP ports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (1)(stateless)":
      proto  => 'udp',
      dport   => $perfsonar::owamp_udp_ports,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (2)(stateless)":
      proto  => 'udp',
      dport   => $perfsonar::bwctl_test_port,
      chain  => 'INPUT',
      action => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP ports (3)(stateless)":
      proto  => 'udp',
      dport   => $perfsonar::traceroute_ports,
      chain  => 'INPUT',
      action => 'accept',
  }


  #not in the FAQ:
#  firewall {"202 IN allow perfsonar PS specific ports (3)(stateless)":
#      proto => 'tcp',
#      dport => [7],
#      chain => 'INPUT',
#      action  => 'accept',
#  }
}
