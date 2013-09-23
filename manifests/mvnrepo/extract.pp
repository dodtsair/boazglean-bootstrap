# == Resource: bootstrap::mvnrepo::extract
#
# Extract a maven artifact on the file system.  See bootstrap::mvnrepo::download to first download the artifact to the
# filesystem.
#
# === Parameters
#
# [*version*]
#   What version of the artifact should be extracted.  Besides artifact_id this is the only other mandatory
#   parameter per resource definition.  All others have defaults.
#   e.g. "0.6.0"
#
# [*artifact_id*]
#   The artifact identifier of the artifact to extract.  Research on maven, gav, or coordinates to understand this field.
#   Will use the name of the resource unless otherwise specified.  I actually have not tested using a different name
#   and artifact_id.  Might not work.
#   e.g. "bigtop-smokes"
#   Default: $name
#
# [*artifact_base*]
#   Within the archive usually there is one folder that contains all the other folders.  This is the name of that folder.
#   Should ensure => absent actually work this will be used to determine what directory to remove.  Unless no_base is
#   set to true, this will be automatically calculated based on the GAV of this artifact.
#   e.g. "bigtop-smokes-0.6.0"
#
# [*no_base*]
#   Whether within the archive there is a root folder that contains all the files or not.  If the artifact has no base
#   then when ensure => absent the extract_path and all children are removed.
#   e.g. "false"
#   Default: $bootstrap::mvnrepo::no_base
#
# [*group_id*]
#   The group_id of the artifact to extract.  Research on maven gav or coordinates to under stand this field.
#   e.g. "org.apache.bigtop.itest"
#   Default: $bootstrap::mvnrepo::group_id
#
# [*packaging*]
#   The file format to be extracted as identified by its extension.  Determined what program to use to extract the archive
#   e.g. "zip"
#   e.g. "tar"
#   e.g. "tar.bz2"
#   e.g. "tar.gz"
#   Default: $bootstrap::mvnrepo::packaging
#
# [*classifier*]
#   The classifier in terms of GAV coordinates.  Basically for a given group_id:artifact_id:version a project might produce
#   several binaries.  They are either differentiated by packaging or if that is not available, classifier.
#   e.g. "project"
#   Default: $bootstrap::mvnrepo::classifier
#
# [*src_path*]
#   The path of the folder that contains the archive to be extracted.  This does not include the name of the archive
#   itself.
#   e.g. "/usr/src/"
#   Default: $bootstrap::mvnrepo::download_path
#
# [*src_name*]
#   The file name of the archive to extract.  This should be found in the src_path directory.  If this is not provided
#   it is calculated based on the GAV coordinate.
#   e.g. "bigtop-smokes-0.6.0-project.tar.gz"
#
# [*ensure*]
#   Whether to actually do the extract, or remove the extracted folder.  Valid values are absent or present.  But I have
#   not tested absent at all.  So it probably does not work.
#   e.g. "present"
#   Default: $bootstrap::mvnrepo::ensure
#
# [*timeout*]
#   How long to wait before giving up on the extraction.  The timeout is specified in number of seconds.
#   e.g. "300"
#   Default: $bootstrap::mvnrepo::timeout
#
# [*extract_path*]
#   The folder that the archive will be extracted into.  If the archive has no base then all the files will be dumped
#   into this folder.
#   e.g. "/etc/puppet/modules/"
#   Default: $bootstrap::mvnrepo::extract_path
#
# [*remove_src*]
#   Once the source file is extracted should it be removed to free up space on the drive.
#   e.g. "true"
#   Default: $bootstrap::mvnrepo::remove_src
#
# [*user*]
#   Extract and save the files to the file system as and owned by this user.  If you want different owners you'll need to
#   do that externally
#   e.g. "root"
#   Default: $bootstrap::mvnrepo::user
##
# === Examples
#
#    bootstrap::mvnrepo::extract{"bigtop-smokes":
#        group_id        => 'org.apache.bigtop.itest',
#        version         => '0.6.0',
#        classifier      => 'project',
#        artifact_base   => 'bigtop-smokes-0.6.0',
#        require         => Bootstrap::Mvnrepo::Download["bigtop-smokes"],
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
define bootstrap::mvnrepo::extract (
    $version,

    $artifact_id            = $name,
    $artifact_base          = undef,
    $no_base                = $bootstrap::mvnrepo::no_base,
    $group_id               = $bootstrap::mvnrepo::groupId,
    $packaging              = $bootstrap::mvnrepo::packaging,
    $classifier             = $bootstrap::mvnrepo::classifier,
    $src_path               = $bootstrap::mvnrepo::download_path,
    $src_name               = undef,
    $ensure                 = $bootstrap::mvnrepo::ensure,
    $timeout                = $bootstrap::mvnrepo::timeout,
    $extract_path           = $bootstrap::mvnrepo::extract_path,
    $remove_src             = $bootstrap::mvnrepo::remove_src,
    $user                   = $bootstrap::mvnrepo::user,
    ) {

    Exec {
        path => [ '/usr/local/bin', '/usr/bin', '/bin', ],
        cwd         => $extract_path,
        provider    => 'shell',
        user        => $user,
        timeout     => $timeout,
    }

    if $classifier {
        $file_name = $src_name ? {
            undef   => "${artifact_id}-${version}-${classifier}.${packaging}",
            default => $src_name,
        }
        $gav = "${group_d}:${artifact_id}:${packaging}:${classifier}:${version}"
        if $artifact_base == undef and ! $no_base {
            $archive_created_path = "${extract_path}${artifact_id}-${version}-${classifier}/"
        }
    }
    else {
        $file_name = $src_name ? {
            undef   => "${artifact_id}-${version}.${packaging}",
            default => $src_name,
        }
        $gav = "${group_id}:${artifact_id}:${packaging}:${version}"
        if $artifact_base == undef and ! $no_base {
            $archive_created_path = "${extract_path}${artifact_id}-${version}/"
        }
    }

    if $no_base {
        $archive_created_path = "${extract_path}"
    }
    elsif $artifact_base != undef {
        $archive_created_path = "${extract_path}${artifact_base}/"
    }

    case $ensure {
        present: {

            $unpack_command = $packaging ? {
                /(zip|jar|war|ear|hpi|jpi)/ => "unzip -o ${src_path}$file_name -d $extract_path",
                /(tar.gz|tgz)/              => "tar --no-same-owner -xzf ${src_path}$file_name -C $extract_path",
                /(tar.xz|txz)/              => "tar --no-same-owner -xJf ${src_path}$file_name -C $extract_path",
                /(tar.bz2|tbz|tbz2)/        => "tar --no-same-owner -xjf ${src_path}$file_name -C $extract_path",
                /(tar)/                     => "tar --no-same-owner -xf ${src_path}$file_name -C $extract_path",
                default                     => 'UNKNOWN',
            }

            if $unpack_command == 'UNKNOWN' {
                fail("Unknown packaging value $packaging")
            }

            exec {$archive_created_path:
                command => $unpack_command,
                cwd     => $extract_path,
                timeout => $timeout,
                refreshonly => true,
                subscribe   => Exec["${src_path}$file_name"],
            }
            if $remove_src {
                file {"${src_path}$file_name":
                    ensure  => absent,
                    require     => Exec[$archive_created_path],
                }
            }
        }
        absent: {
            file {$archive_created_path:
                ensure  => absent,
                recurse => true,
                purge   => true,
                force   => true,
            }
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }
}