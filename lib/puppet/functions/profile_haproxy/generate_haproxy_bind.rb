Puppet::Functions.create_function(:'profile_haproxy::generate_haproxy_bind') do
  dispatch :generate_haproxy_bind do
    param 'Array', :listen_addresses
    param 'Array', :http_ports
    param 'Array', :http_options
    param 'Array', :https_ports
    param 'Array', :https_options
    param 'Array', :tcp_ports
    param 'Array', :tcp_options
    return_type 'Hash'
  end

  # Expects the following input paramters:
  # - listen_address:
  #     example ['0.0.0.0']
  # - http_ports:
  #     example: [80]
  # - http_options:
  #     example: []
  # - https_ports:
  #     example: [443]
  # - https_options:
  #     example: [ 'ssl', 'crt', '/etc/ssl/private/self_signed_certificate.pem', 'ssl', 'crt', '/etc/ssl/haproxy/', 'no-sslv3', 'no-tlsv10', 'no-tlsv11' ],
  # - tcp_ports:
  #     example: []
  # - tcp_options:
  #     example: []
  #
  # Into the following hash:
  #
  # {
  #   '0.0.0.0:80'  => [],
  #   '0.0.0.0:443' => [ 'ssl', 'crt', '/etc/ssl/private/self_signed_certificate.pem', 'ssl', 'crt', '/etc/ssl/haproxy/', 'no-sslv3', 'no-tlsv10', 'no-tlsv11' ],
  # }
  #
  def generate_haproxy_bind(listen_addresses, http_ports, http_options, https_ports, https_options, tcp_ports, tcp_options)
    bind = Hash.new
    listen_addresses.each do |listen_address|
      http_ports.each do |http_port|
        bind["#{listen_address}:#{http_port}"] = http_options
      end
      https_ports.each do |https_port|
        bind["#{listen_address}:#{https_port}"] = https_options
      end
      tcp_ports.each do |tcp_port|
        bind["#{listen_address}:#{tcp_port}"] = tcp_options
      end
    end
    return bind
  end
end
