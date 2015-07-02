
#####
# This module handles installing of
# java jdk 1.6u45
#####



class jdk::jdk6u45 {
    class { 
        "jdk":
            package => 'jdk-1.6.0_45'
    }
}
