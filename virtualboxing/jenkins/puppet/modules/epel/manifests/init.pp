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
	  exec { 'epel_install':
	    command => 'sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm',
	  }
  }
  else {
    fail("Class['epelinstall']: Unsupported OS family: ${osf}")
  }
}