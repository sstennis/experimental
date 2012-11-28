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

  # Messages
  notify { 'base_bootstrap_start_msg':
    message   => "baseCentOS56 bootstrap starting...",
    withpath  => false,
    before    => Group['puppet_group'],
  }
  
  # Create the file system group 'puppet' if not present.
  # Note: I really don't know why this is needed, but it was in the example
  # that came with the default vagrant file after vagrant init.
  group { 'puppet_group':
    ensure  => "present",
    before  => Class['jenkins'],
  }

  if $::osfamily == 'redhat' {
    class { 'jenkins': os => $::operatingsystem }
  }
}

class { 'base::bootstrap': 
  stage => 'base_bootstrap'
}
