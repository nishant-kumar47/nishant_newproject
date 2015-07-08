
#####
# This module handles installing of
# java jdk 1.6u24
#####



class jdk::jdk6u24 {
    class { 
        "jdk":
            package => 'jdk-1.6.0_24'
    }
}
