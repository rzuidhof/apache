# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include apache
# Parameters:
# @param username
# The username of the user that will own the home page file.
#
class apache (
  String $username,
) {
  package { 'httpd':
    ensure => present,
  }

  file_line { 'listen-port':
    ensure  => present,
    path    => '/etc/httpd/conf/httpd.conf',
    line    => 'Listen 8080',
    match   => '^Listen\ 80',
    require => Package['httpd'],
  }

  firewalld_port { 'Open port 8080 in the public zone':
    ensure   => present,
    zone     => 'public',
    port     => 9000,
    protocol => 'tcp',
  }

  service { 'httpd':
    ensure    => running,
    enable    => true,
    subscribe => File_line['listen-port'],
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => epp('apache/home-page.epp', { username => $username }),
    require => Package['httpd'],
  }
}
