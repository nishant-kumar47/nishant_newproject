#####
# This module handles installing of
# java jdk
# 
# by default we install latest jdk
# otherwise we accept specific versions
#####

class jdk($package='jdk') {

## install ##
    package {
        "${package}":
            ensure => present
    }


## config ##
    File {
        owner => root,
        group => root
    }

    file {

        "/var/lib/java":
            ensure => directory,
            mode   => 755;

        "/etc/bashrc.d/":
            ensure => directory,
            mode   => 755;

        "/var/lib/java/dumps":
            ensure => directory,
            mode   => 1777;

        "/usr/bin/java16":
            ensure  => link,
            target  => "/usr/java/latest/jre/bin/java",
            require => Package["${package}"];

#        "/usr/java/latest/jre/lib/security/cacerts":
#            mode    => 444,
#            source  => "puppet://${filehost}/files/common/java/jdk/security/cacerts",
#            require => Package["${package}"];

        "/etc/bashrc.d/jdk.bashrc":
            mode   => 444,
            source => "puppet://${filehost}/files/common/java/jdk/etc/bashrc.d/jdk.bashrc";
    } 

if $hostname =~ /^dc[0-9]{1,2}-nettools[0-9]{1,}.*$/ {

        file {	"/usr/java/latest/jre/lib/security/cacerts":
            mode    => 444,
            source  => "puppet://${filehost}/files/common/java/jdk/security/cacerts_latest",
            require => Package["${package}"];
            }

}
elsif $hostname =~ /^dc[0-9]{1,2}-rtbsatweb[0-9]{2}$/ {
        file {  "/usr/java/latest/jre/lib/security/cacerts":
            mode    => 444,
            source  => "puppet://${filehost}/files/common/java/jdk/security/cacerts_latest",
            require => Package["${package}"];
            }

}
else
{
        file {	"/usr/java/latest/jre/lib/security/cacerts":
            mode    => 444,
            source  => "puppet://${filehost}/files/common/java/jdk/security/cacerts",
            require => Package["${package}"];
            }

}      
}
