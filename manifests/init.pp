# == Class: bootstrap
#
# Defaults common to all module installation implementations.
#
# === Parameters
#
# [*module_path*]
#   Where on the filesystem to install the puppet modules.  This path is not created it is
#   up to the caller.  This should be the folder where puppet looks for installed modules.
#   e.g. "/etc/puppet/modules/"
#   Default: /etc/puppet/modules/
#
# [*repo*]
#   The url for the repository that contains the module. For maven this would be the url to the root folder of the mvn
#   repository.  This repo will be used to search and find the module.
#   e.g. "http://repo1.maven.org/maven2/"
#   Default: http://repo1.maven.org/maven2/
#
# [*timeout*]
#   How long to wait before giving up on the repository.  The timeout is specified in number of seconds.
#   e.g. "300"
#   Default: 120
#
# [*packaging*]
#   The module's archive format identified by its extension.  Determines what program to use to extract the module.
#   e.g. "zip"
#   e.g. "tar"
#   e.g. "tar.bz2"
#   e.g. "tar.gz"
#   Default: tar.gz
#
# [*group_id*]
#   The group or user that created the module.  Used to distinguish one similarly named module from another.
#   e.g. "org.apache.bigtop.itest"
#
# [*classifier*]
#   Used to select the puppet module's archive from a set of files related to that module by the same artifact_id, group_id
#   and version.  Generally only useful for puppet modules retrieved from a maven repo.
#   e.g. "project"
#
# [*no_base*]
#   True or false, if the archive for the puppet module contains a single directory or if the module's files are located
#   at the root of the archive.  True the files are located at the root, false there is one directory that contains all
#   the module's files.  If module_base is provided it overrides this value.
#   e.g. "false"
#   Default: true
#
# [*ensure*]
#   Whether the modules should be installed or removed.  If the value is present the module will be installed.  If the
#   value is absent the module will be removed.  I have not tested absent, it may work, it may not.
#   e.g. "present"
#   Default: present
#
# [*digest_type*]
#   The checksum type to download with the puppet module.  This is used to determine if the module has changed since last
#   download.
#   e.g. "md5"
#   Default: md5
#
# [*checksum*]
#   Whether to download the checksum file and use that for future downloads to see if the module has changed before
#   attempting to download it again.
#   Default: true
#
# [*download_path*]
#   Where on the system to download the archives before installing them to module_path.  This will also be the location
#   the checksum files are stored.
#   e.g. "/usr/src/"
#   Default: /usr/src/
#
# [*remove_src*]
#   Once the source file is extracted should it be removed to free up space on the drive.
#   e.g. "true"
#   Default: true
#
# [*user*]
#   Extract and save the module to the file system as and owned by this user.  If you want different owners for different
#   files in the module you'll need to do that externally
#   e.g. "root"
#   Default: root
#
# [*type*]
#   The type of module repository to use by default.  Right now only mvnrepo is supported.  Hypothetically puppetforge could be
#   added.
#   e.g. "mvnrepo"
#   Default: mvnrepo
#
# === Examples
#
#  class { repo:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Michael Power <mpower@alumni.calpoly.edu>
#
# === Copyright
#
# Copyright 2011 Michael Power, unless otherwise noted.
#
class bootstrap (
    $module_path        ='/etc/puppet/modules/',
    $repo               = 'http://repo1.maven.org/maven2/',
    $timeout            = 120,
    $packaging          = 'tar.gz',
    $group_id           = undef,
    $classifier         = undef,
    $no_base            = true,
    $ensure             = present,
    $digest_type        = 'md5',
    $checksum           = true,
    $download_path      = '/usr/src/',
    $remove_src         = true,
    $user               = 'root',
    $type               = 'mvnrepo',
    ) {
}
