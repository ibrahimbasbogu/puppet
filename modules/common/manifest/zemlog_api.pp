class common::zemlog_api inherits common {
	vcsrepo { "/var/www/zemlog_api":
		ensure => latest,
		provider => git,
		source => 'git@github.com:ibrahimbasbogu/zemlog-api.git',
		revision => 'master',
		user => 'root',
		notify => Exec["zemlog_composerup_api"]
	}

	exec { "zemlog_composerup_api":
		command => "/usr/bin/composer install",
		environment => "COMPOSER_HOME='root/.config/composer'",
		subscribe => Vcsrepo["/var/www/zemlog_api"],
		refreshonly => true,
		cwd => "/var/www/zemlog_api"
	}

	file { "/var/www/zemlog_api/.env.local":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/project/zemlog_api.env",
		mode => "0644",
		require => Exec["zemlog_composerup_api"]
	}

	file { "/etc/nginx/conf.d/zemlog_api.conf":
		ensure => file,
		owner  => "root",
		group  => "root",
		source => "/root/puppet/modules/common/files/nginx/zemlog_api.conf",
		mode   => "0644",
		notify => Service["nginx"],
		require => Package["nginx"]
	}

	file { "/var/www/zemlog_api/config/jwt":
		ensure => directory,
		owner  => "root",
		group  => "root",
		require => Vcsrepo["/var/www/zemlog_api"]
	}

	file { "/var/www/zemlog_api/config/jwt/public.pem":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/project/jwt/public.pem",
		mode => "0644",
		require => File["/var/www/zemlog_api/config/jwt"]
	}

	file { "/var/www/zemlog_api/config/jwt/private.pem":
		ensure => file,
		owner => "root",
		group => "root",
		source => "/root/puppet/modules/common/files/project/jwt/private.pem",
		mode => "0644",
		require => File["/var/www/zemlog_api/config/jwt"]
	}
}
