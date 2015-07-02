
#####
# This module handles installing of
# java jdk 1.6u29
#####



class jdk::jdk6u29 {
    class { 
        "jdk":
            package => 'jdk-1.6.0_29'
    }
}
