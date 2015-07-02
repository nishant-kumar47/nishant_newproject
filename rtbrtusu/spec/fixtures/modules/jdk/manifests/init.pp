#####
# This module handles installing of
# java jdk
# 
# by default we install latest jdk
# otherwise we accept specific versions
#####

class jdk($package='jdk') {

## install ##
#    package {
#        "${package}":

#ensure => present
#    }


## config ##
    File {
        owner => root,
        group => root
    }

    file {

        "/var/lib/java":
            ensure => directory,
            mode   => 755;
}   
    $java_dirs = [
       "/usr/java",
       "/usr/java/latest",
       "/usr/java/latest/jre",
       "/usr/java/latest/jre/bin",
       "/usr/java/latest/jre/lib",
        "/usr/java/latest/jre/lib/security"
        
    ]

    file {

        $java_dirs:
            ensure  => directory,
            mode    => 775;
	
	
	"/usr/java/latest/jre/bin/java":
	   ensure => directory,
	   mode => 755;

        "/etc/bashrc.d/":
            ensure => directory,
            mode   => 755;

        "/var/lib/java/dumps":
            ensure => directory,
            mode   => 1777;

        "/usr/bin/java16":
            ensure  => link,
            target  => "/usr/java/latest/jre/bin/java";
#            require => Package["${package}"];

#        "/usr/java/latest/jre/lib/security/cacerts":
#            mode    => 444,
#            source  => "puppet://modules/jdk/cacerts",
#            require => Package["${package}"];

        "/etc/bashrc.d/jdk.bashrc":
            mode   => 444,
            source => "puppet:///modules/jdk/jdk.bashrc";
    } 

        file {	"/usr/java/latest/jre/lib/security/cacerts":
            mode    => 444,
            source  => "puppet:///modules/jdk/cacerts",
#            require => Package["${package}"];
            }

}      
