# == Class: bootstrap::mvnrepo
#
# Mvnrepo provides for the opportunity to change the defaults used by all bootstrap::mvnrepo:: resources.
#
# === Parameters
#
# [*packaging*]
#   The file format to be downloaded/extracted as identified by its extension.
#   e.g. "zip"
#   e.g. "tar"
#   e.g. "tar.bz2"
#   e.g. "tar.gz"
#   Default: $bootstrap::packaging
#
# [*group_id*]
#   The group_id of the artifact to download/extract.  Research on maven gav or coordinates to under stand this field.
#   e.g. "org.glassfish.samples"
#   Default: $bootstrap::group_id
#
# [*classifier*]
#   The classifier in terms of GAV coordinates.  Basically for a given group_id:artifact_id:version a project might produce
#   several binaries.  They are either differentiated by packaging or if that is not available classifier.
#   e.g. "project"
#   Default: $bootstrap::classifier
#
# [*ensure*]
#   Whether to be downloading/extracting or deleting
#   e.g. "present"
#   Default: $bootstrap::ensure
#
# [*digest_type*]
#   The checksum extension type to download.  When using checksums to check for updates this will determine which checksum
#   is downloaded and which algorithm is used
#   e.g. "md5"
#   Default: $bootstrap::digest_type
#
# [*timeout*]
#   How long to wait before giving up on the maven repository.  The timeout is specified in number of seconds.
#   e.g. "300"
#   Default: $bootstrap::timeout
#
# [*repo*]
#   The base url of the repository from which the artifact will be downloaded.  All maven repositories have a specific
#   path structure under their base url.  This structure is determined by the GAV coordinated.  Given the GAV coordinate
#   and repo url any agent can go to a repo and download an artifact.
#   e.g. "http://repo1.maven.org/maven2/"
#   Default: $bootstrap::repo
#
# [*checksum*]
#   Download the checksum for the artifact and on future runs use that checksum to determine if the artifact needs to be
#   Downloaded again.  With this set to false it will download the artifact each time.
#   e.g. "true"
#   Default: $bootstrap::checksum
#
# [*download_path*]
#   The folder location to put the downloaded artifact.  The download resource does not create this folder.
#   e.g. "/usr/src/"
#   Default: $bootstrap::download_path
#
# [*extract_path*]
#   The folder that the archive will be extracted into.  If the archive has no base then all the files will be dumped
#   into this folder.
#   e.g. "/etc/puppet/modules/"
#   Default: $bootstrap::module_path
#
# [*no_base*]
#   Whether within the archive there is a root folder that contains all the files or not.  If the artifact has no base
#   then when ensure => absent the extract_path and all children are removed.
#   e.g. "false"
#   Default: $bootstrap::no_base
#
# [*remove_src*]
#   Once the source file is extracted should it be removed to free up space on the drive.
#   e.g. "true"
#   Default: $bootstrap::remove_src
#
# [*user*]
#   Extract and save the files to the file system as and owned by this user.  If you want different owners you'll need to
#   do that externally
#   e.g. "root"
#   Default: $bootstrap::user
#
# === Examples
#
#    class {"bootstrap::mvnrepo":
#        repo   => "file:///home/${id}/.m2/repository/",
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
class bootstrap::mvnrepo (
    $packaging          = $bootstrap::packaging,
    $group_id           = $bootstrap::group_id,
    $classifier         = undef,
    $ensure             = $bootstrap::ensure,
    $digest_type        = $bootstrap::digest_type,
    $timeout            = $bootstrap::timeout,
    $repo               = $bootstrap::repo,
    $checksum           = $bootstrap::checksum,
    $download_path      = $bootstrap::download_path,
    $extract_path       = $bootstrap::module_path,
    $no_base            = $bootstrap::no_base,
    $remove_src         = $bootstrap::remove_src,
    $user               = $bootstrap::user,
    ) inherits bootstrap {


    if !defined(Package['curl']) {
        package{'curl': ensure => present }
    }

    file {'/usr/local/bin/mvnget':
        ensure      => present,
        source      => 'puppet:///modules/bootstrap/mvnrepo/mvnget',
        mode        => '755',
        owner       => 'root',
        group       => 'root',
    }
}
