
define folders::create_folders {
         $folder = $name
         exec { "Creating Folder ${folder}":
           path    =>  ["/usr/bin", "/usr/sbin", "/bin"],
           onlyif  => "test ! -d ${folder}",
           command => "mkdir -p ${folder} && chmod 0777 ${folder}"
         }
}

class nfs (
    $ensure_running     = stopped,
    $ensure_enabled     = false,
    $exports            = $::nfs::exports,
) {
    package { 'nfs-utils':
        ensure => $ensure
    }

    service { 'nfs-server':
        ensure      => $ensure_running,
        enable      => $ensure_enabled,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['nfs-utils']
    }

    $folders = keys($exports)

    folders::create_folders { $folders:; } 
     ~>
    file { '/etc/exports':
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('nfs/exports.erb'),
        notify  => Exec['exportfs']
    }

    exec { 'exportfs':
        command     => '/usr/sbin/exportfs -ra',
        refreshonly => true
    }
}

