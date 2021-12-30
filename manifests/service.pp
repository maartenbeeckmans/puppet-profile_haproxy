#
#
#
define profile_haproxy::service (
  Optional[Stdlib::Fqdn]                    $public_name          = undef,
  Enum['string','begin','end', 'substring'] $match_type           = 'string',
  Array[Stdlib::Fqdn]                       $public_aliases       = [],
  String                                    $frontend_name        = 'http_in',
  Array[Stdlib::IP::Address::V4]            $listen_addresses_v4  = ['0.0.0.0'],
  Array[Stdlib::IP::Address::V6]            $listen_addresses_v6  = ['::'],
  Array[Stdlib::Port]                       $listen_http_ports    = [80],
  Array[String]                             $listen_http_options  = [],
  Array[Stdlib::Port]                       $listen_https_ports   = [443],
  Array[String]                             $listen_https_options = ['ssl', 'crt', '/etc/ssl/certs/haproxy/self_signed_certificate.pem', 'ssl', 'crt', '/etc/ssl/certs/haproxy/', 'no-sslv3', 'no-tlsv10', 'no-tlsv11'], #lint:ignore:140chars
  Array[Stdlib::Port]                       $listen_tcp_ports     = [],
  Array[String]                             $listen_tcp_options   = [],
  String                                    $backend_name         = $public_name,
  Array[Stdlib::Fqdn]                       $server_names         = [$facts['networking']['fqdn']],
  Array[Stdlib::IP::Address]                $ipaddresses          = [$facts['networking']['ip']],
  Array[Stdlib::Port]                       $ports                = [80],
  Enum['http','tcp']                        $mode                 = 'http',
  Boolean                                   $ssl                  = true,
  Boolean                                   $force_ssl            = true,
) {
  ensure_resource('profile_haproxy::frontend', $frontend_name, {
    listen_addresses_v4 => $listen_addresses_v4,
    listen_addresses_v6 => $listen_addresses_v6,
    http_ports          => $listen_http_ports,
    http_options        => $listen_http_options,
    https_ports         => $listen_https_ports,
    https_options       => $listen_https_options,
    tcp_ports           => $listen_tcp_ports,
    tcp_options         => $listen_tcp_options,
    mode                => $mode,
  })

  ensure_resource('profile_haproxy::backend', $backend_name, {
    mode => $mode,
  })

  profile_haproxy::balancermember { $title:
    backend_name => $backend_name,
    server_names => $server_names,
    ipaddresses  => $ipaddresses,
    ports        => $ports,
  }

  if $mode == 'http' {
    if ! $public_name {
      fail('public_name should be specified when using http mode')
    }

    $_host_condition = $match_type ? {
      'string'     => 'req.hdr(host) -m str -i',
      'begin'      => 'req.hdr(host) -m beg -i',
      'end'        => 'req.hdr(host) -m end -i',
      'substring'  => 'req.hdr(host) -m sub -i',
    }

    $_force_ssl = ($ssl and $force_ssl) ? {
      true  => "  redirect scheme https code 301 if !{ ssl_fc } !{ path -m beg -i /.well-known/acme-challenge/ } { ${_host_condition} ${public_name} ${join($public_aliases, ' ')} }\n", #lint:ignore:140chars
      false => '',
    }

    ensure_resource('concat::fragment', $backend_name, {
      order    => "15-${frontend_name}-20",
      target   => $::haproxy::config_file,
      content  => "${_force_ssl}  use_backend ${backend_name} if { ${_host_condition} ${public_name} ${join($public_aliases, ' ')} }\n",
    })
  } else {
    ensure_resource('concat::fragment', $backend_name, {
      order    => "15-${frontend_name}-20",
      target   => $::haproxy::config_file,
      content  => "  default_backend ${backend_name}\n",
    })

  }
}
