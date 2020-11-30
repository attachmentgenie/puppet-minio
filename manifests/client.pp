# Class: minio::install
# ===========================
#
# Installs minio, and sets up the directory structure required to run Minio.
#
# Parameters
# ----------
#
# * `package_ensure`
# Decides if the `minio` binary will be installed. Default: 'present'
#
# * `owner`
# The user owning minio and its' files. Default: 'minio'
#
# * `group`
# The group owning minio and its' files. Default: 'minio'
#
# * `base_url`
# Download base URL. Default: Github. Can be used for local mirrors.
#
# * `version`
# Release version to be installed.
#
# * `checksum`
# Checksum for the binary.
#
# * `checksum_type`
# Type of checksum used to verify the binary being installed. Default: 'sha256'
#
# * `configuration_directory`
# Directory holding Minio configuration file. Default: '/etc/minio'
#
# * `installation_directory`
# Target directory to hold the minio installation. Default: '/opt/minio'
#
#
#
class minio::client (
  Enum['present', 'absent'] $package_ensure = $minio::package_ensure,
  String $owner                   = $minio::owner,
  String $group                   = $minio::group,
  String $base_url                = $minio::client_base_url,
  String $version                 = $minio::client_version,
  String $checksum                = $minio::client_checksum,
  String $checksum_type           = $minio::client_checksum_type,
  String $configuration_directory = $minio::client_configuration_directory,
  String $installation_directory  = $minio::installation_directory,
  ) {

  file { $configuration_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  if ($package_ensure) {
    $kernel_down=downcase($::kernel)

    case $::architecture {
      /(x86_64)/: {
        $arch = 'amd64'
      }
      /(x86)/: {
        $arch = '386'
      }
      default: {
        $arch = $::architecture
      }
    }

    $source_url="${base_url}/${kernel_down}-${arch}/archive/mc.${version}"

    archive::download { "${installation_directory}/mc":
      ensure        => present,
      checksum      => true,
      digest_string => $checksum,
      digest_type   => $checksum_type,
      url           => $source_url,
    }
    -> file {"${installation_directory}/mc":
      group => $group,
      mode  => '0744',
      owner => $owner,
    }
  }
}
