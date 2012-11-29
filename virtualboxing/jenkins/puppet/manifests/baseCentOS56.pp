# basic site manifest
# This code was modified from the code posted on GitHub at https://github.com/jcrphx03/vagrant-jenkins

# Define global paths and file ownership.
Exec { path => '/usr/sbin/:/sbin:/usr/bin:/bin' }

# Specify the default parameter value for file resources.
# Note: ID 0 == 'root'
File { owner => 'root', group => 'root', mode => 0644 }

stage { 'base_bootstrap': before => Stage['main'] }

# Set the osfamily at the global level to support modules that rely on 'redhat'.
# Yeah, this stinks, but I really don't want to modify someone else's puppet module
# if I can avoid it.
if $::operatingsystem == 'centos' {
  $osfamily = 'redhat'
}

class base::bootstrap {

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
 
  # Install the extra packages for linux. CentOS comes with very little.
  class { 'epel':
    osf => $::osfamily,
  }

  # CentOS has no puppet package by default, but if epel is installed it does.
  # Note that the 'latest' may not be the latest you need.
  package { 'puppet':
    ensure  => 'latest',
    require => Class['epel'],
  }
 
  # Get the latest version of puppet. e.g.: the apache module fails with an
  # error on unable to resolve a2mod without version 2.7.8 of puppet.
  # CentOS has no puppet package.
#  if ( $operatingsystem == 'centos') {
#	  exec { 'install-puppet':
#	    command => 'sudo rpm -Uvh http://yum.puppetlabs.com/el/5/products/x86_64/puppetlabs-release-5-6.noarch.rpm',
#      path => ['/usr/bin', '/bin'],
#	  }
#  }
#  else {
#	  package { 'puppet':
#	    ensure => 'latest',
#	  }
#  }

  #Ordering of ops.
#  Anchor['base::bootstrap::begin']    ->
#  Notify['base_bootstrap_start_msg']  ->
#  Group['puppet_group']               ->
#  Class['epel']                       ->
#  Package['puppet']                   ->
#  Anchor['base::bootstrap::end']
}

class { 'base::bootstrap': 
  stage => 'base_bootstrap'
}

# This will run in stage main.
class { 'jenkinsprep':
  os  => $::operatingsystem,
}
