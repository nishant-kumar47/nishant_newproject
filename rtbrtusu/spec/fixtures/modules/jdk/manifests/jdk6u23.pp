
#####
# This module handles installing of
# java jdk 1.6u23
#####



class jdk::jdk6u23 {
    class { 
        "jdk":
            package => 'jdk-1.6.0_23'
    }
}
