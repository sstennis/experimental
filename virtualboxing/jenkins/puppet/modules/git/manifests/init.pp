# Class: git
#
# This module manages the git package
#
# Parameters: version
#
# Actions:    Ensures git is installed. Also install some useful configurations.
#             For CentOS, this requires downloading the package.
#
# Requires:   N/A
#
# Sample Usage: include git
#               class { 'git': os => 'centos', version => 'latest', }
#
# [Remember: No empty lines between comments and class definition]
class git (
  $os = '',
  $version = present
) {

  # Unfortunately, the CentOS base being used doens't have a git package, so
  # the package { 'git-core': } doesn't work.
  if $os == 'centos' {
    exec { 'add_git_package':
      command => 'sudo rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm',
      before  => Exec['install_git'],
    }
  
    # This has two prompts for Y/N, and using yum -y option to answer yes to both.
    exec { 'install_git':
      command => 'sudo yum -y install --enablerepo=webtatic git',
      require => Exec['add_git_package'],
      before  => File['/etc/gitconfig'],
    }

    file { '/etc/gitconfig':
      source  => 'puppet:///modules/git/gitconfig',
      require => Exec['install_git'],
    }
  }
  else {
    package { 'git-core':
      ensure => $version,
    }

    file { '/etc/gitconfig':
      source  => 'puppet:///modules/git/gitconfig',
      require => Package['git-core'],
    }
  }
}
