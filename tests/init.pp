# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using:
# puppet apply --modulepath ../../ --noop download.pp
# Fully applying the test in a virtual environment:
#vagrant up
#
# Learn more about module testing here: http://docs.puppetlabs.com/guides/tests_smoke.html
#
class {"bootstrap":
    module_path     => '/vargrant/modules/',
}


