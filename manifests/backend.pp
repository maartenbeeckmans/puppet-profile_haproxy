#
#
#
define profile_haproxy::backend (
  Enum['http','tcp'] $mode         = 'http',
  String             $balance      = 'leastconn',
  String             $option       = 'forwardfor',
  String             $http_request = 'set-header X-Forwarded-Proto https if { ssl_fc }',
) {
  case $mode {
    'http': {
      haproxy::backend { $title:
        mode             => 'http',
        options          => [
          { 'balance'      => $balance, },
          { 'option'       => $option, },
          { 'http-request' => $http_request, },
        ],
        collect_exported => false;
      }
    }
    'tcp': {
      haproxy::backend { $title:
        mode             => 'tcp',
        options          => [
          { 'balance'      => $balance, },
          { 'option'       => $option, },
        ],
        collect_exported => false;
      }
    }
    default: {
      fail('mode should be http or tcp')
    }
  }
}
