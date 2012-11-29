# Class: git
#
# This module manages the git package
#
# Parameters: os
#             version
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
  $os = undef,
  $version = present
) {

  # Unfortunately, the CentOS base doens't have a git package.
  # However, if the epel class is used or epel is otherwise installed on the vm,
  # then a git package is available.
  if $os == 'centos' {
	  
	  package { 'git':
	    ensure => $version,
	  }

#    exec { 'add_git_package':
#      command => 'sudo rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm',
#      before  => Exec['install_git'],
#    }
#  
#    # This has two prompts for Y/N, and using yum -y option to answer yes to both.
#    exec { 'install_git':
#      command => 'sudo yum -y install --enablerepo=webtatic git',
#      require => Exec['add_git_package'],
#      before  => File['/etc/gitconfig'],
#    }

    file { '/etc/gitconfig':
      source  => 'puppet:///modules/git/gitconfig',
      #require => Exec['install_git'],
      require => Package['git'],
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
