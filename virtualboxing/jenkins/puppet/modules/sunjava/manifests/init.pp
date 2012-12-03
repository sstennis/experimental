# Class: sunjava
#
# This module manages the Sun Java runtime package
#
# Parameters: None
#
# Actions:    Downloads the Sun JRE package, does an uninstall of any existing java package, 
#             and installs the Sun JRE package.
#
# Requires:   N/A
#
# Sample Usage: include sunjava
#               class { 'sunjava': os => 'centos', }
#
# [Remember: No empty lines between comments and class definition]
class sunjava (
  $os = undef 
  ) {

  # Download and install Sun java.
  # Purported to be necessary because CentOS comes with a Java implementation that is not
  # compatible with Jenkins.
  if $os == 'centos' {

	  # Create a directory for rpms first if it doesn't exist already.
	  exec { 'mkdir_rpms':
	    command => 'su --session-command="mkdir /usr/share/rpms"',
	    path    => ['/usr/bin', '/bin'],
	    creates => '/usr/share/rpms/',
	  }

	  # Download the Sun JRE rpm package for CentOS.
	  # The default timeout is overridden with a larger value as the download can take a while.
	  exec { 'download_java':
	    command => 'su --session-command="wget -O jre-linux-x64.rpm -c http://javadl.sun.com/webapps/download/AutoDL?BundleId=69466"',
	    path    => '/usr/bin',
	    cwd     => '/usr/share/rpms',
	    creates => '/usr/share/rpms/jre-linux-x64.rpm',
	    timeout => '600',
	  }
	
	  # Uninstall the default Java implementation that comes with CentOS.
	  # Necessary because CentOS comes with a Java implementation that is not compatible
	  # with Jenkins.
	  exec { 'uninstall_defaultjava':
	    command => 'su --session-command="yum remove java"',
	    path => '/usr/bin',
	  }
	  
	  # Run the package installer for the downloaded jre package.
	  # Purported to be necessary because CentOS comes with a Java implementation that is not compatible
	  # with Jenkins, although my experience with the puppet centos vagrant package is that it doesn't
	  # come with a jre at all. Running package { 'jre': } installs the openJDK RE, then produces an error
	  # that the package couldn't be found.
	  exec { 'install_java':
	    command => 'su --session-command="rpm -ivh /usr/share/rpms/jre-linux-x64.rpm"',
	    path => ["/usr/bin", "/bin"],
	  }
	
	  # Order of operations.
	  # The nifty aspect of chaining here is that if any of the items fail, all the others following
	  # are skipped as being dependent on the success of that which preceeds.
	  Exec['mkdir_rpms']              -> 
	  Exec['download_java']           -> 
	  Exec['uninstall_defaultjava']   -> 
	  Exec['install_java']
  }
  else {
    # Note sure what to do for other OS. Might be same if linux, but not use yum for example.
    # Also, the correct package might be available on other OS.
    #
    
	  # This will install the openJDK RE.
	  #package { 'jre':
	  #  ensure => 'latest',
	  #}
	  #package { 'java':
	  #  ensure => 'latest',
	  #  name   => 'jdk',
	  #}
	  #exec { 'install-java':
	  #  command => 'su --session-command="yum install java-1.6.0-openjdk"',
	  #  path => '/usr/bin',
	  #}
  }
}
