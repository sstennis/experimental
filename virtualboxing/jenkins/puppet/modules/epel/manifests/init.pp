# Class: epel
#
# This module manages the epel package
# epel = 'Extra Packages for Enterprise Linux'
#
# Parameters: osf - the os family (e.g.: redhat includes centos, etc.)
#
# Actions:    Ensures epel is installed.
#
# Requires:   N/A
#
# Sample Usage: include epel
#               class { 'epel': os => $::osfamily, }
#
# [Remember: No empty lines between comments and class definition]
class epel (
  $osf = undef
) {
  
  if $osf == 'redhat' {
    yumrepo { 'epel':
	    descr          => 'Extra Packages for Enterprise Linux 5 - \$basearch',
	    mirrorlist     =>  'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=\$basearch',
	    failovermethod => 'priority',
	    enabled        => 1,
	    gpgcheck       => 0,
    }
    ->
    #package { 'epel': }
    exec { 'epel_install':
      command => 'su --session-command="yum install -y epel"',
    }

	  #exec { 'epel_install':
	  #  command => 'su --session-command="rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-7.noarch.rpm"',
	  #}
  }
  else {
    fail("Class['epelinstall']: Unsupported OS family: ${osf}")
  }
}
