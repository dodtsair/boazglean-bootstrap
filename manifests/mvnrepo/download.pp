# == Resource: bootstrap::mvnrepo::download
#
# Download an artifact from a maven style repository
#
# === Parameters
#
# [*version*]
#   What version of the artifact should be downloaded.  This is the only other mandatory
#   parameter per resource definition.  All others have defaults.
#
# [*group_id*]
#   The group_id of the artifact to download.  Research on maven gav or coordinates to under stand this field.
#   e.g. "org.glassfish.samples"
#   Default: $bootstrap::mvnrepo::group_id
#
# [*ensure*]
#   Whether to actually do the download, or remove the downloaded file.  Valid values are absent or present.  But I have
#   not tested absent at all.  So it probably does not work.
#   e.g. "present"
#   Default: $bootstrap::mvnrepo::ensure
#
# [*artifact_id*]
#   The artifact identifier of the artifact to download.  Research on maven, gav, or coordinates to understand this field.
#   Will use the name of the resource unless otherwise specified.  I actually have not tested using a different name
#   and artifact_id.  Might not work.
#   e.g. "classic-profile"
#   Default: $name
#
# [*packaging*]
#   The file format to be downloaded as identified by its extension.
#   e.g. "zip"
#   e.g. "tar"
#   e.g. "tar.bz2"
#   e.g. "tar.gz"
#   Default: $bootstrap::mvnrepo::packaging
#
# [*classifier*]
#   The classifier in terms of GAV coordinates.  Basically for a given group_id:artifact_id:version a project might produce
#   several binaries.  They are either differentiated by packaging or if that is not available classifier.
#   e.g. "project"
#   Default: $bootstrap::mvnrepo::classifier
#
# [*checksum*]
#   Download the checksum for the artifact and on future runs use that checksum to determine if the artifact needs to be
#   Downloaded again.  With this set to false it will download the artifact each time.
#   e.g. "true"
#   Default: $bootstrap::mvnrepo::checksum
#
# [*digest_type*]
#   The checksum extension type to download.  When using checksums to check for updates this will determine which checksum
#   is downloaded and which algorithm is used
#   e.g. "md5"
#   Default: $bootstrap::mvnrepo::digest_type
#
# [*repo*]
#   The base url of the repository from which the artifact will be downloaded.  All maven repositories have a specific
#   path structure under their base url.  This structure is determined by the GAV coordinated.  Given the GAV coordinate
#   and repo url any agent can go to a repo and download an artifact.
#   e.g. "http://repo1.maven.org/maven2/"
#   Default: $bootstrap::mvnrepo::repo
#
# [*timeout*]
#   How long to wait before giving up on the maven repository.  The timeout is specified in number of seconds.
#   e.g. "300"
#   Default: $bootstrap::mvnrepo::timeout
#
# [*download_path*]
#   The folder location to put the downloaded artifact.  The download resource does not create this folder.
#   e.g. "/usr/src/"
#   Default: $bootstrap::mvnrepo::download_path
#
# [*download_name*]
#   The name of the file to download this artifact to.  If not specified this will be calculated based on the GAV
#   coordinate.
#   e.g. "classic-profile-v1.0.0-project.zip"
#
# [*user*]
#   Download and save the file to the file system as and owned by this user.
#   e.g. "root"
#   Default: $bootstrap::mvnrepo::user
#
# === Examples
#
#    bootstrap::mvnrepo::download{"geb-manual":
#        group_id        => 'org.codehaus.geb',
#        version         => '0.7.2',
#        checksum        => false,
#        packaging   => 'zip',
#        download_name  => "geb-manual.zip"
#    }
#
#    bootstrap::mvnrepo::download{"classic-profile":
#        group_id     => 'org.glassfish.samples',
#        version     => '1.2',
#        packaging   => 'zip',
#        download_name  => "classic-profile.zip"
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
define bootstrap::mvnrepo::download (
    $version,
    $group_id           = $bootstrap::mvnrepo::group_id,
    $ensure             = $bootstrap::mvnrepo::ensure,
    $artifact_id        = $name,
    $packaging          = $bootstrap::mvnrepo::packaging,
    $classifier         = $bootstrap::mvnrepo::classifier,
    $checksum           = $bootstrap::mvnrepo::checksum,
    $digest_type        = $bootstrap::mvnrepo::digest_type,
    $repo               = $bootstrap::mvnrepo::repo,
    $timeout            = $bootstrap::mvnrepo::timeout,
    $download_path      = $bootstrap::mvnrepo::download_path,
    $download_name      = undef,
    $user               = $bootstrap::mvnrepo::user,
    ) {

    #Use an inline template to convert the group_id syntax to a path.
    #This avoids an external dependency (stdlib)
    $groups = split($group_id, '[.]')
    $group_path = inline_template("<%=groups.join('/')%>")

    Exec {
        path        => [ '/usr/local/bin', '/usr/bin', '/bin', ],
        cwd         => $download_path,
        provider    => 'shell',
        user        => $user,
        timeout     => $timeout,
    }

    if $classifier {
        $file_name = $download_name ? {
            undef   => "${artifact_id}-${version}-${classifier}.${packaging}",
            default => $download_name,
        }
        $gav = "${group_id}:${artifact_id}:${packaging}:${classifier}:${version}"
        $checksum_gav = "${group_id}:${artifact_id}:${packaging}.$digest_type:${classifier}:${version}"
    }
    else {
        $file_name = $download_name ? {
            undef   => "${artifact_id}-${version}.${packaging}",
            default => $download_name,
        }
        $gav = "${group_id}:${artifact_id}:${packaging}:${version}"
        $checksum_gav = "${group_id}:${artifact_id}:${packaging}.$digest_type:${classifier}:${version}"
    }


    case $checksum {
        true : {
            case $digest_type {
                'md5', 'sha1', 'sha224', 'sha256', 'sha384', 'sha512' : {
                    $checksum_cmd = "${digest_type}sum -c $file_name.${digest_type}"
                }
                default: { fail('Unimplemented digest type') }
            }

            case $ensure {
                present: {
                    exec {"repo digest ${name}: $gav":
                        command     => "mvnget -4 -g $checksum_gav -u $repo -o ${file_name}.${digest_type}",
                        require     => [Package['curl'],File['/usr/local/bin/mvnget']],
                    }
                    exec {"${download_path}$file_name.$digest_type":
                        command     => "sed -i -e 's|$| *$file_name|' $file_name.$digest_type",
                        require     => Exec["repo digest ${name}: $gav"],
                    }
                    #I want the option to extract the artifact and then delete the archive.  Which means I can't compare
                    #The checksum against an empty file.  Instead create a checksum of the checksum.  Download
                    #The archive's checksum and use the checksum of the checksum to see if it has changed.
                    exec {"repo digest check ${name}: $gav":
                        command     => "${digest_type}sum -b $file_name.$digest_type > $file_name.$digest_type.$digest_type",
                        unless      => "${digest_type}sum -c $file_name.$digest_type.$digest_type",
                        require     => Exec["${download_path}$file_name.$digest_type"],
                        notify      => Exec["${download_path}$file_name"],
                    }

                }
                absent: {
                    file{"${download_path}$file_name.$digest_type":
                        ensure => absent,
                        purge  => true,
                        force  => true,
                    }
                }
                default: { fail("Unknown ensure value: '${ensure}'") }
            }
        }
        false :  { notice('No checksum for this archive') }
        default: { fail("Unknown checksum value: '${checksum}'") }
    }

    case $ensure {
        present: {

            $refreshonly = $checksum ? {
                true    => true,
                default => undef,
            }

            #Extract references this exec.  Change the name with caution
            exec {"${download_path}$file_name":
                command     => "mvnget -4 -g $gav -u $repo -o $file_name",
                cwd         => $download_path,
                #only download if the checksum is different
                unless      => $checksum_cmd,
                require     => [Package['curl'],File['/usr/local/bin/mvnget']],
                refreshonly => $refreshonly,
            }
        }
        absent: {
            file {"${download_path}$file_name":
                ensure => absent,
                purge  => true,
                force  => true,
            }
        }
        default: { fail("Unknown ensure value: '${ensure}'") }
    }
}

