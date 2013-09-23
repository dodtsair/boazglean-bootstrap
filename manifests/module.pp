# == Resource: bootstrap::module
#
# Identifies a puppet module to be downloaded and installed into the puppet module location.  Since I built maven
# repository integration first then I used maven terms to identify the artifact.  In puppet modules are uniquely
# by three identifies.
# 1) The module's name (artifact_id)
# 2) The module owner's username (group_id)
# 3) The module's version (version)
#
# Maven has additional identifiers that may be used to uniquely identify an artifact.  If you are using maven repositories
# then these identifiers can be used to locate the puppet module.  If you are using some other source these identifiers
# may have no meaning.
# 1) classifier
# 2) packaging
#
# === Parameters
#
# [*version*]
#   What version of the module should be downloaded.  This is the only other mandatory
#   parameter per resource definition.  All others have defaults.
#   e.g. "0.6.0"
#
# [*artifact_id*]
#   The puppet module name.  Excluding the user name.  This will also be the name of the module in the puppet modules directory after installed
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# [*module_base*]
#   The folder name in the archive where are the files are stored.  Puppet modules are stored in some sort of archive.
#   Best practices for archives in general is that all files within the archive are in one folder.  In this way if the
#   archive is extracted into a directory rather then dumping all sorts of files into that directory only one folder
#   is dumped.  Thus if the extraction location was a mistake, it is easy to fix.  If this name does not match the
#   artifact_id then when extracted it will be changed to the artifact_id.  Puppet modules are installed into the puppet
#   using a directory that matches just their name.  It excludes the username or version.
#   e.g. "bigtop-smokes-0.6.0"
#
# [*no_base*]
#   True or false, if the archive for this puppet module contains a single directory or if the module's files are located
#   at the root of the archive.  True the files are located at the root, false there is one directory that contains all
#   the module's files.  If module_base is provided it overrides this value.
#   e.g. "false"
#   Default: $bootstrap::no_base
#
# [*packaging*]
#   The module's archive format identified by its extension.  Determines what program to use to extract the module.
#   e.g. "zip"
#   e.g. "tar"
#   e.g. "tar.bz2"
#   e.g. "tar.gz"
#   Default: $bootstrap::packaging
#
# [*group_id*]
#   The group or user that created the module.  Used to distinguish one similarly named module from another.
#   e.g. "org.apache.bigtop.itest"
#   Default: $bootstrap::group_id
#
# [*classifier*]
#   Used to select the puppet module's archive from a set of files related to that module by the same artifact_id, group_id
#   and version.  Generally only useful for puppet modules retrieved from a maven repo.
#   e.g. "project"
#   Default: $bootstrap::classifier
#
# [*ensure*]
#   Whether the modules should be installed or removed.  If the value is present the module will be installed.  If the
#   value is absent the module will be removed.  I have not tested absent, it may work, it may not.
#   e.g. "present"
#   Default: $bootstrap::ensure
#
# [*checksum*]
#   Whether to download the checksum file and use that for future downloads to see if the module has changed before
#   attempting to download it again.
#   Default: $bootstrap::checksum
#
# [*digest_type*]
#   The checksum type to download with the puppet module.  This is used to determine if the module has changed since last
#   download.
#   e.g. "md5"
#   Default: $bootstrap::digest_type
#
# [*module_path*]
#   Where on the filesystem to install the puppet module.  Module resource does not bother to create module path it is
#   up to the caller.  This should be the folder where puppet looks for installed modules.
#   e.g. "/etc/puppet/modules/"
#   Default: $bootstrap::module_path
#
# [*download_path*]
#   Where on the system to download the archives before installing them to module_path.  This will also be the location
#   the checksum files are stored.
#   e.g. "/usr/src/"
#   Default: $bootstrap::download_path
#
# [*repo*]
#   The url for the repository that contains the module. For maven this would be the url to the root folder of the mvn
#   repository.  This repo will be used to search and find the module.
#   e.g. "http://repo1.maven.org/maven2/"
#   Default: $bootstrap::repo
#
# [*type*]
#   The type of module source for this module.  Right now only mvnrepo is supported.  Hypothetically puppetforge could be
#   added.
#   e.g. "mvnrepo"
#   Default: $bootstrap::type
#
# === Examples
#
#    bootstrap::module{"bigtop-smokes":
#        group_id     => 'org.apache.bigtop.itest',
#        version     => '0.6.0',
#        classifier   => 'project',
#        module_base => 'bigtop-smokes-0.6.0',
#    }
#
# === Authors
#
# Michael Power <mpower@alumni.calpoly.edu>
#
# === Copyright
#
# Copyright 2011 Michael Power, unless otherwise noted.
#
define bootstrap::module (
    $version,

    $artifact_id        = $name,
    $module_base        = undef,
    $no_base            = $bootstrap::no_base,
    $packaging          = $bootstrap::packaging,
    $group_id           = $bootstrap::group_id,
    $classifier         = $bootstrap::classifier,
    $ensure             = $bootstrap::ensure,
    $checksum           = $bootstrap::checksum,
    $digest_type        = $bootstrap::digest_type,
    $module_path        = $bootstrap::module_path,
    $download_path      = $bootstrap::download_path,
    $repo               = $bootstrap::repo,
    $type               = $bootstrap::type,
    ) {

    Exec {
        path => [ '/usr/local/bin', '/usr/bin', '/bin', ],
        provider    => 'shell',
        user        => $user,
        timeout     => $timeout,
    }

    case $type {
        mvnrepo : {
            if ! $no_base or ! $module_base {
                if ! $module_base {
                    $mvn_module_base = "${artifact_id}"
                }
                else {
                    $mvn_module_base = $module_base
                }
            }
            if $no_base {
                $mvn_extract_path = "${module_path}${artifact_id}/"

                file{$mvn_extract_path:
                    ensure      => directory,
                }
            }
            elsif $mvn_module_base != $artifact_id {
                $mvn_extract_path = $module_path

                exec {"${module_path}${artifact_id}/":
                    command => "mv ${mvn_module_base} ${artifact_id}",
                    cwd     => $module_path,
                    timeout => $timeout,
                    refreshonly => true,
                    subscribe   => Exec["${module_path}${mvn_module_base}/"],
                }
            }
            else {
                $mvn_extract_path = $module_path
            }
            bootstrap::mvnrepo::download{$artifact_id:
                ensure              => $ensure,
                group_id            => $group_id,
                version             => $version,
                classifier          => $classifier,
                packaging           => $packaging,
                checksum            => $checksum,
                digest_type         => $digest_type,
                repo                => $repo,
                timeout             => $timeout,
                download_path       => $download_path,
            }

            bootstrap::mvnrepo::extract{$artifact_id:
                ensure              => $ensure,
                group_id            => $group_id,
                classifier          => $classifier,
                version             => $version,
                packaging           => $packaging,
                artifact_base       => $mvn_module_base,
                no_base             => $no_base,
                extract_path        => $mvn_extract_path,
                src_path            => $download_path,
                timeout             => $timeout,
                require             => Bootstrap::Mvnrepo::Download[$artifact_id],
            }
        }
        forge: {
            #But imagine if it wasn't, basically we would have to steal the entire puppet-module module
            fail("Unknown module source type value: '${type}'")
        }
        default: { fail("Unknown module source type value: '${type}'") }
    }
}
