
#####
# This module handles installing of
# java jdk 1.6u13
#####



class jdk::jdk6u13 {
    class { 
        "jdk":
            package => 'jdk-1.6.0_13'
    }
}
