class perfsonar::firewall::ipv6 inherits perfsonar::params {
  
  #
  # ICMP
  #
  firewall {"200 IN allow perfsonar PS specific ICMP v6":
      provider => 'ip6tables', 
      proto => 'ipv6-icmp',
      icmp => $icmp_types,
      chain => 'INPUT',
      action  => 'accept',
  }
  
  #
  # TCP ports
  #
  firewall {"200 IN allow perfsonar PS specific TCP ports (1)(stateless) v6":
      provider => 'ip6tables', 
      proto => 'tcp',
      port => $owamp_tcp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific TCP ports (2)(stateless) v6": 
      provider => 'ip6tables',
      proto => 'tcp',
      port => $bwctl_tcp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  
  #
  # UDP ports
  #
  firewall {"200 IN allow perfsonar PS specific UDP ports (1)(stateless) v6": 
      provider => 'ip6tables',
      proto => 'udp',
      port => $owamp_udp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific UDP ports (2)(stateless) v6": 
      provider => 'ip6tables',
      proto => 'udp',
      port => $bwctl_udp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific UDP ports (3)(stateless) v6": 
      provider => 'ip6tables',
      proto => 'udp',
      port => $traceroute_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  
}
