# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using:
# puppet apply --modulepath ../../:`pwd`/../../../bom/target/modules --noop download.pp
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

bootstrap::mvnrepo::download{"javadb-core":
    group_id    => 'javadb',
    packaging   => 'zip',
    version     => '10.9.1.0',
}

file{"${bootstrap::mvnrepo::extract_path}javadb-core/":
    ensure      => directory,
}

bootstrap::mvnrepo::extract{"javadb-core":
    group_id            => 'javadb',
    version             => '10.9.1.0',
    packaging           => 'zip',
    no_base             => true,
    extract_path        => "${bootstrap::mvnrepo::extract_path}javadb-core/",
    require             => Bootstrap::Mvnrepo::Download["javadb-core"],
}

bootstrap::mvnrepo::download{"bigtop-smokes":
    group_id            => 'org.apache.bigtop.itest',
    version             => '0.6.0',
    classifier          => 'project',
}

bootstrap::mvnrepo::extract{"bigtop-smokes":
    group_id        => 'org.apache.bigtop.itest',
    version         => '0.6.0',
    classifier      => 'project',
    artifact_base   => 'bigtop-smokes-0.6.0',
    require         => Bootstrap::Mvnrepo::Download["bigtop-smokes"],
}
