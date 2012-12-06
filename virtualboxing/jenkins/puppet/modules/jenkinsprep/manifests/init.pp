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
  #class { 'sunjava': os => $os, }
  class { 'java': }
  class { 'stdlib': }
  class { 'ant': }

  # Schedule order of ops.
  Anchor['jenkinsprep::requirements::begin']  ->
  Package['unzip']  ->
  Class['git']      ->
  #Class['sunjava']  ->
  Class['java']  ->
  Class['stdlib']   ->
  Class['ant']      ->
  Anchor['jenkinsprep::requirements::end']
}

class jenkinsprep::install {

  anchor { 'jenkinsprep::install::begin': }
  anchor { 'jenkinsprep::install::end': }

  class { 'jenkins': 
    require => Class['jenkinsprep::requirements'],
  }
  
  class { 'jenkinsprep::plugins': }

  # install postfix to make it possible for jenkins to notify via mail
  #package { 'postfix':
  #  ensure => present,
  #}

  #service { 'postfix':
  #  ensure  => running,
  #  require => Package['postfix'],
  #}

  # install apache and add a proxy for jenkins
  #class { 'apache': }
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

class jenkinsprep::secure {
  
  # Enable login security on Jenkins
  # This entails modifying the config.xml file located at /var/lib/jenkins.
  # The default security tags need to be changed/replaced. This may be a task
  # that should remain manual, so as to not need to store user account info
  # in code or other files in the repo.
  # For the basic security setup via the Jenkins web browser interface, see
  # https://wiki.jenkins-ci.org/display/JENKINS/Standard+Security+Setup
#  exec { 'enablesecurity':
#    command => 'su --session-command="sed -f secureconfig.sed /var/lib/jenkins/config.xml > temp.xml"', # need to move temp.xml to replace config.xml
#    require => File['/var/lib/jenkins/congif.xml', '/var/lib/jenkins/secureconfig.sed'],
#  }

  # Need to replace the <useSecurity>, <authorizationStrategy >, <securityRealm > tags
  # to match the following (change the username from POI to whatever is meaningful):
#  <useSecurity>true</useSecurity>
#  <authorizationStrategy class="hudson.security.GlobalMatrixAuthorizationStrategy">
#    <permission>hudson.model.Computer.Configure:POI</permission>
#    <permission>hudson.model.Computer.Connect:POI</permission>
#    <permission>hudson.model.Computer.Create:POI</permission>
#    <permission>hudson.model.Computer.Delete:POI</permission>
#    <permission>hudson.model.Computer.Disconnect:POI</permission>
#    <permission>hudson.model.Hudson.Administer:POI</permission>
#    <permission>hudson.model.Hudson.ConfigureUpdateCenter:POI</permission>
#    <permission>hudson.model.Hudson.Read:POI</permission>
#    <permission>hudson.model.Hudson.RunScripts:POI</permission>
#    <permission>hudson.model.Hudson.UploadPlugins:POI</permission>
#    <permission>hudson.model.Item.Build:POI</permission>
#    <permission>hudson.model.Item.Cancel:POI</permission>
#    <permission>hudson.model.Item.Configure:POI</permission>
#    <permission>hudson.model.Item.Create:POI</permission>
#    <permission>hudson.model.Item.Delete:POI</permission>
#    <permission>hudson.model.Item.Discover:POI</permission>
#    <permission>hudson.model.Item.Read:POI</permission>
#    <permission>hudson.model.Item.Workspace:POI</permission>
#    <permission>hudson.model.Run.Delete:POI</permission>
#    <permission>hudson.model.Run.Update:POI</permission>
#    <permission>hudson.model.View.Configure:POI</permission>
#    <permission>hudson.model.View.Create:POI</permission>
#    <permission>hudson.model.View.Delete:POI</permission>
#    <permission>hudson.model.View.Read:POI</permission>
#    <permission>hudson.scm.SCM.Tag:POI</permission>
#  </authorizationStrategy>
#  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
#    <disableSignup>false</disableSignup>
#    <enableCaptcha>false</enableCaptcha>
#  </securityRealm>

  # The following may need to be added as well:
#  <markupFormatter class="hudson.markup.RawHtmlMarkupFormatter">
#    <disableSyntaxHighlighting>false</disableSyntaxHighlighting>
#  </markupFormatter>

}
