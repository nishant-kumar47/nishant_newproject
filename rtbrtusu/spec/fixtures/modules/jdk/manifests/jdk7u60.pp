#####
# This module handles installing of
# java jdk 1.7u60
#####



class jdk::jdk7u60 {
    class {
        "jdk":
            package => 'jdk-1.7.0_60',
    }
}

