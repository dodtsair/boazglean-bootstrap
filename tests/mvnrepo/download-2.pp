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
bootstrap::mvnrepo::download{"geb-manual":
    group_id        => 'org.codehaus.geb',
    version         => '0.7.2',
    checksum        => false,
    packaging   => 'zip',
    download_name  => "geb-manual.zip"
}

bootstrap::mvnrepo::download{"classic-profile":
    group_id     => 'org.glassfish.samples',
    version     => '1.2',
    packaging   => 'zip',
    download_name  => "classic-profile.zip"
}

