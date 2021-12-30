#
#
#
class profile_haproxy (
  String $collect_tag,
  Hash   $services,
  Hash   $service_defaults,
) {
  include ::haproxy

  include profile_haproxy::certificate

  Profile_haproxy::Service <<| tag == $collect_tag |>>

  create_resources(profile_haproxy::service, $services, $service_defaults)

  profile_haproxy::service {
    'matrix':
      public_name => 'matrix.beeckmans.cloud';
    'element':
      public_name => 'element.beeckmans.cloud';
    'gitea':
      public_name => 'gitea.beeckmans.cloud';
    'gitlab-dev':
      public_name => 'gitlab-dev.beeckmans.cloud';
    'idp':
      public_name => 'idp.beeckmans.cloud';
    'nomad':
      public_name  => 'service.beeckmans.cloud',
      match_type   => 'end',
      backend_name => 'nomad',
      server_names => ['nomad01', 'nomad02', 'nomad03'],
      ipaddresses  => ['192.168.101.1', '192.168.101.2', '192.168.101.3'],
  }

  profile_haproxy::service { 'gitea-ssh':
    frontend_name    => 'gitea_ssh',
    listen_tcp_ports => [2222],
    backend_name     => 'gitea.beeckmans.cloud-ssh',
    mode             => 'tcp';
  }
}
