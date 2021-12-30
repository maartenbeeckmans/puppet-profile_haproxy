#
#
#
define profile_haproxy::balancermember (
  String                     $backend_name,
  Array[Stdlib::Fqdn]        $server_names,
  Array[Stdlib::IP::Address] $ipaddresses,
  Array[Stdlib::Port]        $ports,
) {
  haproxy::balancermember { $title:
    listening_service => $backend_name,
    server_names      => $server_names,
    ipaddresses       => $ipaddresses,
    ports             => $ports,
    options           => 'check',
  }
}
