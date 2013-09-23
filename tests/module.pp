# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using:
# puppet apply --modulepath ../../:`pwd`/../../../bom/target/modules --noop module.pp
# Fully applying the test in a virtual environment:
#vagrant up
#
# Learn more about module testing here: http://docs.puppetlabs.com/guides/tests_smoke.html
#
class {"bootstrap":
    module_path     => '/vagrant/modules/',
}
class {"bootstrap::mvnrepo":
}
bootstrap::module{"javadb-core":
    group_id     => 'javadb',
    version     => '10.9.1.0',
    packaging   => 'zip',
}

bootstrap::module{"bigtop-smokes":
    group_id     => 'org.apache.bigtop.itest',
    version     => '0.6.0',
    classifier   => 'project',
    module_base => 'bigtop-smokes-0.6.0',
}

bootstrap::module{"bp-project":
    group_id     => 'org.glassfish.samples',
    version     => '1.2',
    packaging   => 'zip',
    no_base     => false,

}


