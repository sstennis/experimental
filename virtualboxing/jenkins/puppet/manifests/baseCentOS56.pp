# basic site manifest
# This code was modified from the code posted on GitHub at https://github.com/jcrphx03/vagrant-jenkins

# Define global paths and file ownership.
Exec { path => '/usr/sbin/:/sbin:/usr/bin:/bin' }

# Specify the default parameter value for file resources.
# Note: ID 0 == 'root'
File { owner => 'root', group => 'root', mode => 0644 }

stage { 'base_bootstrap': before => Stage['main'] }

# Set the osfamily at the global level to support modules that rely on 'redhat'.
# This is needed when using vagrant and virtualbox, but causes an error when run
# on in-house VMs.
# Yeah, this stinks, but I really don't want to modify someone else's puppet module
# if I can avoid it.
if $::operatingsystem == 'centos' {
  $osfamily = 'redhat'
}
  

node default {

	class { 'basebootstrap': 
	  stage => 'base_bootstrap'
	}
	
	# This will run in stage main.
	class { 'jenkinsprep':
	  os  => $::operatingsystem,
	}
}
