class repo {

        file {

            '/etc/yum.repos.d/asci.repo':
                mode   => '0644',
                owner  => root,
                group  => root,
                source => "puppet:///modules/${module_name}/asci.repo";
        }
}
