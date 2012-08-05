# define: nginx::resource::site_enabled
#
# This definition creates a virtual host
#
# Parameters:
#   [*ensure*]           - Enables or disables the specified vhost (present|absent)
#   [*listen_ip*]        - Default IP Address for NGINX to listen with this vHost on. Defaults to all interfaces (*)
#   [*listen_port*]      - Default IP Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*ipv6_enable*]      - BOOL value to enable/disable IPv6 support (false|true). Module will check to see if IPv6
#                          support exists on your system before enabling.
#   [*ipv6_listen_ip*]   - Default IPv6 Address for NGINX to listen with this vHost on. Defaults to all interfaces (::)
#   [*ipv6_listen_port*] - Default IPv6 Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*index_files*]      -  Default index files for NGINX to read when traversing a directory
#   [*proxy*]            - Proxy server(s) for a location to connect to. Accepts a single value, can be used in conjunction
#   [*proxy_read_timeout*] - Override the default the proxy read timeout value of 90 seconds
#                          with nginx::resource::upstream
#   [*fastcgi*]          - location of fastcgi (host:port)
#   [*fastcgi_params*]   - optional alternative fastcgi_params file to use
#   [*fastcgi_script*]   - optional SCRIPT_FILE parameter
#   [*fastcgi_index*]    - fastcgi index file
#   [*fastcgi_location*] - fastcgi location files
#   [*ssl*]              - Indicates whether to setup SSL bindings for this location.
#   [*ssl_cert*]         - Pre-generated SSL Certificate file to reference for SSL Support. This is not generated by this module.
#   [*ssl_key*]          - Pre-generated SSL Key file to reference for SSL Support. This is not generated by this module.
#   [*ssl_ca*]          - The SSL CA certificate in the PEM format used for client certificate verification. This is not generated by this module.
#   [*www_root*]         - Specifies the location on disk for files to be read from. Cannot be set in conjunction with $proxy
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::site_enabled { 'www.example.com':
#    ensure   => present,
#    www_root => '/var/www/nginx-default',
#    ssl      => 'true',
#    ssl_cert => '/tmp/server.crt',
#    ssl_key  => '/tmp/server.pem',
#  }
define nginx::resource::site_enabled(
  $ensure           = 'enable',
  $listen_ip        = '*',
  $listen_port      = '80',
  $ipv6_enable      = false,
  $ipv6_listen_ip   = '::',
  $ipv6_listen_port = '80',
  $ssl              = false,
  $ssl_cert         = undef,
  $ssl_key          = undef,
  $ssl_ca           = undef,
  $proxy            = undef,
  $proxy_read_timeout = $nginx::params::nx_proxy_read_timeout,
  $site_enabled_template   = $nginx::params::site_enabled,
  $fastcgi          = undef,
  $fastcgi_params   = '/etc/nginx/fastcgi_params',
  $fastcgi_script   = undef,
  $fastcgi_index    = 'index.php',
  $fastcgi_location = '~ \.php$',
  $index_files      = ['index.html', 'index.htm', 'index.php'],
  $www_root         = undef
) {

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Add IPv6 Logic Check - Nginx service will not start if ipv6 is enabled
  # and support does not exist for it in the kernel.
  if ($ipv6_enable == 'true') and ($ipaddress6)  {
    warning('nginx: IPv6 support is not enabled or configured properly')
  }

  # Check to see if SSL Certificates are properly defined.
  if ($ssl == 'true') {
    if ($ssl_cert == undef) or ($ssl_key == undef) {
      fail('nginx: SSL certificate/key (ssl_cert/ssl_cert) and/or SSL Private must be defined and exist on the target system(s)')
    }
  }

  # Use the File Fragment Pattern to construct the configuration files.
  # Create the base configuration file reference.
  file { "${nginx::config::nx_conf_dir}/sites-enabled/${name}":
    ensure  => $ensure ? {
      'absent' => absent,
      default  => 'file',
    },
    content => template($site_enabled_template),
    notify => Class['nginx::service'],
  }
}