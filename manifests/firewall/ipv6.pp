class perfsonar::firewall::ipv6 inherits perfsonar::params {
  
  #
  # ICMP
  #
  firewall {'200 IN allow perfsonar PS specific ICMP v6':
      provider => 'ip6tables',
      proto    => 'ipv6-icmp',
      icmp     => $perfsonar::params::icmp_types,
      chain    => 'INPUT',
      action   => 'accept',
  }
  
  #
  # TCP ports
  #
  firewall {'200 IN allow perfsonar PS specific TCP ports (1)(stateless) v6':
      provider => 'ip6tables',
      proto    => 'tcp',
      port     => $perfsonar::params::owamp_tcp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {'200 IN allow perfsonar PS specific TCP ports (2)(stateless) v6':
      provider => 'ip6tables',
      proto    => 'tcp',
      port     => $perfsonar::params::bwctl_tcp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  
  #
  # UDP ports
  #
  firewall {'200 IN allow perfsonar PS specific UDP ports (1)(stateless) v6':
      provider => 'ip6tables',
      proto    => 'udp',
      port     => $perfsonar::params::owamp_udp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {'200 IN allow perfsonar PS specific UDP ports (2)(stateless) v6':
      provider => 'ip6tables',
      proto    => 'udp',
      port     => $perfsonar::params::bwctl_udp_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  firewall {'200 IN allow perfsonar PS specific UDP ports (3)(stateless) v6':
      provider => 'ip6tables',
      proto    => 'udp',
      port     => $perfsonar::params::traceroute_ports,
      chain    => 'INPUT',
      action   => 'accept',
  }
  
}
