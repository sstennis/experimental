# Class: basebootstrap
#
# This class ensures basic packages needed for the Jenkins provision are available.
#
# Parameters: osf - the os family (e.g.: redhat includes centos, etc.)
#
# Actions:    Ensures latest puppet and epel are installed.
#
# Requires:   N/A
#
# Sample Usage: include epel
#               class { 'epel': os => $::osfamily, }
#
# [Remember: No empty lines between comments and class definition]
class basebootstrap {

  anchor { 'base::bootstrap::begin': }
  anchor { 'base::bootstrap::end': }

  # Messages
  notify { 'base_bootstrap_start_msg':
    message   => "baseCentOS56 bootstrap starting...",
    withpath  => false,
    before    => [Group['puppet_group'], Class['epel'], Package['puppet']],
  }
  
  # Create the file system group 'puppet' if not present.
  # Note: I really don't know why this is needed, but it was in the example
  # that came with the default vagrant file after vagrant init.
  group { 'puppet_group':
    ensure  => "present",
  }
 
  # Install the extra packages for linux if not present. CentOS comes with very little.
  class { 'epel':
    osf => $::osfamily,
  }

  # CentOS has no puppet package by default, but if epel is installed it does.
  # Note that the 'latest' may not be the latest you need.
  package { 'puppet':
    ensure  => 'latest',
    require => Class['epel'],
  }
 
  #Ordering of ops.
  Anchor['base::bootstrap::begin']    ->
  Notify['base_bootstrap_start_msg']  ->
  Group['puppet_group']               ->
  Class['epel']                       ->
  Package['puppet']                   ->
  Anchor['base::bootstrap::end']
}
