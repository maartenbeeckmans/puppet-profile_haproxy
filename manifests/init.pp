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
}
