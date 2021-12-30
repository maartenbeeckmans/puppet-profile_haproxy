#
#
#
define profile_haproxy::frontend (
  Array[Stdlib::IP::Address::V4] $listen_addresses_v4 = ['0.0.0.0'],
  Array[Stdlib::IP::Address::V6] $listen_addresses_v6 = ['::'],
  Array[Stdlib::Port]            $http_ports          = [80],
  Array[String]                  $http_options        = [],
  Array[Stdlib::Port]            $https_ports         = [443],
  Array[String]                  $https_options       = ['ssl', 'crt', '/etc/ssl/certs/haproxy/self_signed_certificate.pem', 'ssl', 'crt', '/etc/ssl/certs/haproxy/', 'no-sslv3', 'no-tlsv10', 'no-tlsv11'], #lint:ignore:140chars
  Array[Stdlib::Port]            $tcp_ports           = [],
  Array[String]                  $tcp_options         = [],
  Enum['http','tcp']             $mode                = 'http',
) {
  if size($listen_addresses_v4) == 0 and size($listen_addresses_v6) == 0 {
    fail('There should be at least one listen address')
  }

  if size($listen_addresses_v4) != 0 {
    profile_base::firewall::rule { "allow_ipv4_haproxy_frontent_${title}":
      daddr => $listen_addresses_v4,
      dport => concat($http_ports,$https_ports,$tcp_ports),
    }
  }

  if size($listen_addresses_v6) != 0 {
    profile_base::firewall::rule { "allow_ipv6_haproxy_frontent_${title}":
      daddr    => $listen_addresses_v6,
      dport    => concat($http_ports,$https_ports,$tcp_ports),
      set_type => 'ip6',
    }
  }

  case $mode {
    'http': {
      haproxy::frontend { $title:
        bind             => profile_haproxy::generate_haproxy_bind(
          concat($listen_addresses_v4, $listen_addresses_v6),
          $http_ports, $http_options,
          $https_ports, $https_options,
          [], [],
        ),
        options          => {
          'option' => ['forwardfor except 127.0.0.1'],
        },
        mode             => 'http',
        collect_exported => false;
      }
    }
    'tcp': {
      haproxy::frontend { $title:
        bind             => profile_haproxy::generate_haproxy_bind(
          concat($listen_addresses_v4, $listen_addresses_v6),
          [], [],
          [], [],
          $tcp_ports, $tcp_options,
        ),
        options          => {},
        mode             => 'tcp',
        collect_exported => false;
      }
    }
    default: {
      fail('mode should be http or tcp')
    }
  }
}
