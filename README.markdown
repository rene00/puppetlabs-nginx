# NGINX Module

James Fryman <jamison@puppetlabs.com>

This module manages NGINX from within Puppet.

# Quick Start

Install and bootstrap an NGINX instance

<pre>
    node default {
      class { 'nginx': }
    }
</pre>

Setup a new virtual host

<pre>
    node default {
      class { 'mcollective': }
      nginx::resource::vhost { 'www.puppetlabs.com':
        ensure   => present,
        www_root => '/var/www/www.puppetlabs.com',
      }
    }
</pre>

Add a Proxy Server(s)

<pre>
   node default {
     class { 'mcollective': }
     nginx::resource::upstream { 'puppet_rack_app':
       ensure  => present,
       members => [
         'localhost:3000', 
         'localhost:3001',
         'localhost:3002',
       ],
     }

     nginx::resource::vhost { 'rack.puppetlabs.com':
       ensure   => present,
       proxy  => 'http://puppet_rack_app',
     }
   } 
</pre>

Setup a new virtual host with fastcgi

<pre>
    node default {
      class { 'mcollective': }
      nginx::resource::vhost { 'www.puppetlabs.com':
        ensure   => present,
        www_root => '/var/www/www.puppetlabs.com',
        fastcgi => '127.0.0.1:9000',
        fastcgi_script => '/var/www/www.puppetlabs.com$fastcgi_script_name',
		fastcgi_index => 'index.php',
      }
    }
</pre>
