class common {

	file { "/etc/apt/sources.list.d/ondrej.list":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/ondrej.list",
		mode => "0644",
		notify => Exec["apt-update"]
	}

	exec { "apt-update":
		command => "/usr/bin/apt update",
		subscribe => File["/etc/apt/sources.list.d/ondrej.list"],
		refreshonly => true,
	}

	file { "/etc/systemd/system.conf": 
		ensure => file,
		owner  => "root",
		group  => "root",
		source => "/root/puppet/modules/common/files/system.conf",
		mode   => "0644"
	}

	file { "/etc/security/limits.conf":
		ensure => file,
		owner  => "root",
		group  => "root",
		source => "/root/puppet/modules/common/files/limits.conf",
		mode   => "0644"
	}

	exec { "sysctl-p":
		command => "/sbin/sysctl -p",
		subscribe => File["/etc/sysctl.conf"],
		refreshonly => true,
	}

	file { "/etc/sysctl.conf":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/sysctl.conf",
		mode => "0644",
		notify => Exec["sysctl-p"]
	}
	
	$packageList  = [
		"curl",
		"htop",
		"ntp",
		"ntpdate",
		"git",
		"awscli",
		"nginx",
		"composer",
		"php8.1",
		"php8.1-fpm",
		"php8.1-common",
		"php8.1-mysql",
		"php8.1-xml",
		"php8.1-xmlrpc",
		"php8.1-curl",
		"php8.1-gd",
		"php-imagick",
		"php8.1-cli",
		"php8.1-dev",
		"php8.1-imap",
		"php8.1-mbstring",
		"php8.1-opcache",
		"php8.1-soap",
		"php8.1-zip",
		"php8.1-intl",
		"php-amqp",
		"python2.7",
		]

	package { $packageList:
		ensure => installed
	}
		
	file { "/etc/nginx/nginx.conf":
		ensure => file,
		owner  => "root",
		group  => "root",
		source => "/root/puppet/modules/common/files/nginx/nginx.conf",
		mode   => "0644",
		notify => Service["nginx"],
		require => Package["nginx"]
	}

	file { "/etc/nginx/sites-enabled/default":
		ensure => absent,
		notify => Service["nginx"],
		require => Package["nginx"]
	}

	service { "nginx": 
		name => "nginx",
		ensure => "running",
		hasrestart => true,
		hasstatus => true,
		require => Package["nginx"]
	}

	service { "php8.1-fpm":
		name => "php8.1-fpm",
		ensure => "running",
		hasrestart => true,
		hasstatus => true,
		require => Package["php8.1-fpm"]
	}

	file { "/etc/php/8.1/fpm/php.ini": 
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/php/php.ini",
		mode => "0644",
		notify => Service["php8.1-fpm"],
		require => [Package["php8.1-fpm"],File["/var/log/php"]]
	}

	file { "/etc/php/8.1/fpm/pool.d/www.conf":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/php/www.conf",
		mode => "0644",
		notify => Service["php8.1-fpm"],
		require => [Package["php8.1-fpm"],File["/var/log/php"]]
	}

	file { "/var/log/nginx": 
		ensure => directory,
		owner => "root",
		group => "root",
		mode => "0777"
	}
	file { "/var/log/php":
		ensure => directory,
		owner => "www-data",
		group => "www-data",
		mode => "0644",
	}

	cron { 'puppet':
		command => '/root/puppet/run.sh 2>&1 > /tmp/puppet.log',
		user    => 'root',
		minute  => '*/5',
	}

	cron { 'puppetreboot':
		command => '/root/puppet/run.sh 2>&1 > /tmp/puppet.log',
		user    => 'root',
		special  => 'reboot',
	}
}