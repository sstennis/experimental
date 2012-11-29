# Class: jenkinsprep
# This code was modified from the code posted on GitHub at https://github.com/jcrphx03/vagrant-jenkins
#
# Parameters: None
#
# Actions:    Ensures jenkins dependencies are met and installs jenkins.
#
# Requires:   Sun Java RE, Web Server (e.g.: Apache), Git (for building from repo)
#             See https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+RedHat+distributions
#             for additional info.
#
# Sample Usage: include jenkinsprep
#               class { 'jenkinsprep': os => 'centos', }
#
# [Remember: No empty lines between comments and class definition]
class jenkinsprep (
  $os = '' 
  ) {
   
  # Use anchors to ensure containment of the class "implementations" within this class.
  # e.g.: contain class { 'jenkinsprep::requirements' } and class { 'jenkinsprep::install' }
  # See http://projects.puppetlabs.com/projects/puppet/wiki/Anchor_Pattern
  # Note there are a few ways to use the anchors:
  #   1. declare them then set each op with require and before, OR
  #   2. declare them to surround/contain the ops and have the anchors set the 
  #      require and before.
  #   3. see below

  anchor { 'jenkinsprep::begin': }
  anchor { 'jenkinsprep::end': }

  # Requirements is chained before install.
  class { 'jenkinsprep::requirements': os => $os, }
  class { 'jenkinsprep::install': }
  
  # Schedule order of ops.
  Anchor['jenkinsprep::begin']        ->
  Class['jenkinsprep::requirements']  ->
  Class['jenkinsprep::install']       ->
  Anchor['jenkinsprep::end']
}

class jenkinsprep::requirements (
  $os = undef
) {
  # These have no dependencies on each other, so no chaining or ordering required.
  # However, it just looks weird in the output to have them randomly run.

  # Note that for our purposes, git should be installed via shell script as needed,
  # which also then clones the branch or repo holding the provisioning manifests (like
  # the repo containing this manifest). This call here then would not be necessary.

  anchor { 'jenkinsprep::requirements::begin': }
  anchor { 'jenkinsprep::requirements::end': }

  package { 'unzip': }
  class { 'git': os => $os, version => 'latest', }
  class { 'sunjava': os => $os, }
  class { 'stdlib': }

  #class { 'apache': }
  #class { 'apache::mod::proxy': }

  #apache::vhost::proxy { 'jenkins.33.33.33.10.icix.com':
  #  port => '80',
  #  dest => 'http://localhost:8080',
  #}

  # Schedule order of ops.
  Anchor['jenkinsprep::requirements::begin']  ->
  Package['unzip']  ->
  Class['git']      ->
  Class['sunjava']  ->
  Class['stdlib']   ->
  Anchor['jenkinsprep::requirements::end']
}

class jenkinsprep::install {

  anchor { 'jenkinsprep::install::begin': }
  anchor { 'jenkinsprep::install::end': }

  class { 'jenkins': 
    require => Class['jenkinsprep::requirements'],
  }
  
  class { 'jenkinsprep::plugins': }

  # configure jenkins jobs
  #jenkins::job { 'test-template':
  #  repository => 'git://github.com/Icix/jenkins-test-template.git',
  #}

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
  
  # Schedule order of ops.
  Anchor['jenkinsprep::install::begin'] ->
  Class['jenkins']                      -> 
  Class['jenkinsprep::plugins']         ->
  Anchor['jenkinsprep::install::end']
}

class jenkinsprep::plugins {
  # install jenkins plugins
  jenkins::plugin { 'ant': }
  jenkins::plugin { 'external-monitor-job': }
  jenkins::plugin { 'git': }
  jenkins::plugin { 'github-api': }
  jenkins::plugin { 'github': }
  jenkins::plugin { 'javadoc': }
  jenkins::plugin { 'scm-sync-configuration': }
  jenkins::plugin { 'text-finder': }
}
