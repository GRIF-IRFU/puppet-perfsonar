class perfsonar::firewall::ipv6 (
  $ipt_allow_order=$perfsonar::firewall_order
) {

  #
  # ICMP
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific ICMP v6":
      provider => 'ip6tables',
      proto    => 'ipv6-icmp',
      icmp     => $perfsonar::icmp_types,
      chain    => 'INPUT',
      action   => 'accept',
  }

  #
  # TCP dports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP dports (1)(stateless) v6":
      provider => 'ip6tables',
      proto    => 'tcp',
      dport     => $perfsonar::owamp_tcp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific TCP dports (2)(stateless) v6":
      provider => 'ip6tables',
      proto    => 'tcp',
      dport     => concat($perfsonar::bwctl_tcp_ports , $perfsonar::bwctl_test_port , $perfsonar::bwctl_peer_port ),
      chain    => 'INPUT',
      action   => 'accept',
  }

  #need v6 addresses.
  #perfsonar::firewall::allow_http { 'v6': source_array => $perfsonar::http_allow , ip_proto => 6, ipt_allow_order => $ipt_allow_order}

  #
  # UDP dports
  #
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP dports (1)(stateless) v6":
      provider => 'ip6tables',
      proto    => 'udp',
      dport     => $perfsonar::owamp_udp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP dports (2)(stateless) v6":
      provider => 'ip6tables',
      proto    => 'udp',
      dport     => $perfsonar::bwctl_test_port,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {"${ipt_allow_order} IN allow perfsonar PS specific UDP dports (3)(stateless) v6":
      provider => 'ip6tables',
      proto    => 'udp',
      dport     => $perfsonar::traceroute_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }

}
