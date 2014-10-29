class perfsonar::firewall::ipv4 inherits perfsonar::params {
  
  #the puppetlabs module does not allow for source param beeing an array, nor does iptables.
  #So until we use the new parser with looping, work that around :
  define allow_http() {
    firewall { "200 IN allow perfsonar PS web interface access (stateless) from ${name}":
        proto       => 'tcp',
        dport       => $perfsonar::params::http_ports,
        source      => $name,
        action      => accept,
        chain => 'INPUT',
    }
  } 
  
  #
  # ICMP
  #
  firewall {"200 IN allow perfsonar PS specific ICMP": 
      proto => 'icmp',
      icmp => $icmp_types,
      chain => 'INPUT',
      action  => 'accept',
  }
  
  #
  # TCP ports
  #
  firewall {"200 IN allow perfsonar PS specific TCP ports (1)(stateless)": 
      proto => 'tcp',
      port => $owamp_tcp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific TCP ports (2)(stateless)": 
      proto => 'tcp',
      port => $bwctl_tcp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  allow_http {$http_allow:}
  
  
  
  
  #
  # UDP ports
  #
  firewall {"200 IN allow perfsonar PS specific UDP ports (1)(stateless)": 
      proto => 'udp',
      port => $owamp_udp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific UDP ports (2)(stateless)": 
      proto => 'udp',
      port => $bwctl_udp_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  firewall {"200 IN allow perfsonar PS specific UDP ports (3)(stateless)": 
      proto => 'udp',
      port => $traceroute_ports,
      chain => 'INPUT',
      action  => 'accept',
  }
  
  
  #not in the FAQ:
#  firewall {"202 IN allow perfsonar PS specific ports (3)(stateless)": 
#      proto => 'tcp',
#      port => [7],
#      chain => 'INPUT',
#      action  => 'accept',
#  }
}
