# Class: jenkins
# This code was modified from the code posted on GitHub at https://github.com/jcrphx03/vagrant-jenkins
#
# Parameters: None
#
# Actions:    Ensures jenkins dependencies are met and installs jenkins.
#
# Requires:   Sun Java RE, Web Server (e.g.: Apache), Git (for building from repo)
#
# Sample Usage: include jenkins
#               class { 'jenkins': os => 'centos', }
#
# [Remember: No empty lines between comments and class definition]
class jenkins (
  $os = '' 
  ) {
  
  # Use anchors to ensure containment of the class "implementations" within this class.
  # e.g.: contain class { 'jenkins::requirements' } and class { 'jenkins::install' }
  # See http://projects.puppetlabs.com/projects/puppet/wiki/Anchor_Pattern
  anchor { 'jenkins::begin':
    before => Class['jenkins::requirements'],
  }

  # Requirements is chained before install.
  class { 'jenkins::requirements': os => $os, }
  ->
  class { 'jenkins::install': }
  
  anchor { 'jenkins::end':
    require => Class['jenkins::install'],
  }
}

class jenkins::requirements (
  $os = ''
) {
  # These have no dependencies on each other, so no chaining or ordering required.
  # However, it just looks weird in the output to have them randomly run.

  # Note that for icix purposes, git should be installed via shell script as needed,
  # which also then clones the branch or repo holding the provisioning manifests (like
  # this one). This call here then would not be necessary.
  class { 'git': os => $os, }
  ->
  package { 'unzip': }
  ->
  class { 'sunjava': os => $os, }
  ->
  class { 'stdlib': }
  ->  
  class { 'apache': }
  ->
  class { 'apache::mod::proxy': }

  #apache::vhost::proxy { 'jenkins.33.33.33.10.icix.com':
  #  port => '80',
  #  dest => 'http://localhost:8080',
  #}
}

class jenkins::install {
  # install jenkins
  #class { 'jenkins': }

  # configure jenkins jobs
  #jenkins::job { 'test-template':
  #  repository => 'git://github.com/Icix/jenkins-test-template.git',
  #}

  # install jenkins plugins
  #jenkins::plugin { 'ant': }
  #jenkins::plugin { 'external-monitor-job': }
  #jenkins::plugin { 'git': }
  #jenkins::plugin { 'github-api': }
  #jenkins::plugin { 'github': }
  #jenkins::plugin { 'javadoc': }
  #jenkins::plugin { 'scm-sync-configuration: }
  #jenkins::plugin { 'text-finder': }

  # install postfix to make it possible for jenkins to notify via mail
  #package { 'postfix':
  #  ensure => present,
  #}

  #service { 'postfix':
  #  ensure  => running,
  #  require => Package['postfix'],
  #}

  # install apache and add a proxy for jenkins
  #class { 'apache': osfamily => 'RedHat', }
  #class { 'apache::mod::proxy': }

  #apache::mod { 'php5': }
  #apache::mod { 'rewrite': }

  #apache::vhost::proxy { 'jenkins.33.33.33.10.icix.com':
  #  port => '80',
  #  dest => 'http://localhost:8080',
  #}
}
