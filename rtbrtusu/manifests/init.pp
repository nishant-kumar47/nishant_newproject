#####
# This module handles installation of
# RTB Silo RealTimeUserStoreUpdater Server (Apollo)
#####

class rtbrtusu::prod::install {
    include jdk::jdk6u29
    Asci_users::Pupuser <| title == rtuserfeed |>

    package {
        "unzip": ensure => present;
    }
}

class rtbrtusu::prod::common {
    File {
        owner   => rtuserfeed,
        group   => rtuserfeed,
        require => Class["jdk"]
    }

    $rtbrtusu_dirs = [
        "/var/rsi/rtb",
        "/var/rsi/rtb/userupdater",
        "/var/rsi/logs/userupdater"
    ]

    file {

        $rtbrtusu_dirs:
            ensure  => directory,
            mode    => 775;

        "/logs/userupdater":
            ensure  => link,
            mode    => 755,
            target  => "/var/rsi/logs/userupdater";
    }
}

class rtbrtusu::prod::config {
    ###
    # NO WAR EXTENSION ON THIS
    ###
    $build = "apollo-userdata-installer-104.0"

    File {
        owner   => rtuserfeed,
        group   => rtuserfeed,
    }

    file {

        "/etc/init.d/userupdater":
            ensure  => link,
            force   => true,
            purge   => true,
            mode    => 755,
            require => File["/var/rsi/rtb/userupdater/$build/bin/realtimeUpdater.sh"],
            target  => "/var/rsi/rtb/userupdater/$build/bin/realtimeUpdater.sh";

        "/var/rsi/rtb/userupdater/${build}/bin/realtimeUpdater.sh":
            mode    => 755,
            require => Exec["deploy_userupdater_build"],
            source  => "puppet://${filehost}/files/product/rtbrtusu/prod/bin/userupdater_init.sh";

        "/var/rsi/rtb/userupdater/${build}.zip":
            notify  => Exec["deploy_userupdater_build"],
            source  => "puppet://${filehost}/files/product/rtbrtusu/prod/code/$build.zip";

        "/var/rsi/rtb/userupdater/latest":
            ensure  => link,
            force   => true,
            purge   => true,
            require => File["/var/rsi/rtb/userupdater/$build.zip"],
            target  => "/var/rsi/rtb/userupdater/$build";

        "/var/rsi/rtb/OverrideConfig.properties":
            mode    => 444,
            content => template("rtbrtusu/OverrideConfig.properties.erb",
                                "rtb/OverrideConfig.properties.zookeeper.erb");

        "/var/rsi/rtb/server.info":
            mode    => 444,
            require => File["/var/rsi/rtb"],
            content => "$build",
            ensure  => present;

        "/var/rsi/run/rtuserfeed":
            mode    => 755,
            force   => true,
            ensure  => directory;

        "/var/rsi/rtb/userupdater/userupdater-extract.sh":
            mode    => 755,
            source  => "puppet://${filehost}/files/product/rtbrtusu/prod/bin/userupdater-extract.sh";

        "/var/rsi/rtb/userupdater/${build}/classes/log4j.properties":
            mode    => 644,
            require => File["/var/rsi/rtb/userupdater/${build}.zip"],
            source  => "puppet://${filehost}/files/product/rtbrtusu/prod/conf/log4j.properties";
    }

   cron {

       rtuserupdater_alert_log_purge:
            command => "/usr/bin/find /var/rsi/logs/userupdater -name 'rtuserupdater-alert.log*.gz' -type f -mtime +7 -exec rm {} \; >/dev/null 2>&1",
            user    => rtuserfeed,
            minute  => 45,
            hour    => 5;
        

        rtuserupdater_alert_logs_archive:
            command => "/usr/bin/find /var/rsi/logs/userupdater -name 'rtuserupdater-alert.log*' -type f -mtime +3 -exec gzip {} \; >/dev/null 2>&1",
            user    => rtuserfeed,
            minute  => 30,
            hour    => 4;


    rtuserupdater_stdout_logs_archive:
            command => "/usr/bin/find /var/rsi/logs/userupdater -name 'rtuserupdater-stdout.log*' -type f -mtime +3 -exec gzip {} \; >/dev/null 2>&1",
            user    => rtuserfeed,
            minute  => 30,
            hour    => 5;

        rtuserupdater_stdout_purge:
            command => "/usr/bin/find /var/rsi/logs/userupdater -name 'rtuserupdater-stdout.log*.gz' -type f -mtime +7 -exec rm {} \; >/dev/null 2>&1",
            user    => rtuserfeed,
            minute  => 15,
            hour    => 4;
  

    }
    exec {

        "deploy_userupdater_build":
            command     => "/var/rsi/rtb/userupdater/userupdater-extract.sh $build",
            refreshonly => true,
            require     => File["/var/rsi/rtb/userupdater/userupdater-extract.sh","/var/rsi/rtb/userupdater/$build.zip"];

    }

}

class rtbrtusu::prod::service {

    service {

        "userupdater":
            ensure      => running,
            require     => Class["rtbrtusu::prod::config"],
            enable      => true,
            hasstatus   => true;

    }
}

class rtbrtusu {
    include rtbrtusu::prod::install,
            rtbrtusu::prod::common,
            rtbrtusu::prod::service,
            rtbrtusu::prod::config
}

