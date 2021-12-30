#
#
#
class profile_haproxy::certificate {
  include openssl

  file { '/etc/ssl/certs/haproxy/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  openssl::certificate::x509 { 'self_signed_certificate':
    country      => 'BE',
    state        => 'East-Flanders',
    locality     => 'Ghent',
    commonname   => $facts['networking']['domain'],
    organization => $facts['networking']['domain'],
    days         => 365,
  }

  concat { '/etc/ssl/certs/haproxy/self_signed_certificate.pem':
    ensure  => present,
    require => [
      Openssl::Certificate::X509['self_signed_certificate'],
      File['/etc/ssl/certs/haproxy/'],
    ],
    notify  => Service['haproxy'],
  }

  concat::fragment { 'self_signed_certificate_cert':
    target  => '/etc/ssl/certs/haproxy/self_signed_certificate.pem',
    source  => '/etc/ssl/certs/self_signed_certificate.crt',
    order   => '01',
    require => Openssl::Certificate::X509['self_signed_certificate'],
  }

  concat::fragment { 'self_signed_certificate_key':
    target  => '/etc/ssl/certs/haproxy/self_signed_certificate.pem',
    source  => '/etc/ssl/certs/self_signed_certificate.key',
    order   => '02',
    require => Openssl::Certificate::X509['self_signed_certificate'],
  }
}
