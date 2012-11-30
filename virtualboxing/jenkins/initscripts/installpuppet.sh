#!/bin/bash
#
# Copied from http://awaseroot.wordpress.com/2012/09/01/new-script-install-puppet-on-centos/
#

sudo sh -c \
'sudo cat > /etc/yum.repos.d/puppet.repo << EOF
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/\$releasever/products/\$basearch/
enabled=1
gpgcheck=1
gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
EOF'

sudo sh -c \
'sudo cat > /etc/yum.repos.d/ruby.repo << EOF
[ruby]
name=ruby
#baseurl=http://repo.premiumhelp.eu/ruby/
baseurl=http://rubyworks.rubyforge.org/redhat/RPMS/\$basearch/
gpgcheck=0
enabled=0
EOF'

sudo sh -c \
'sudo cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 5 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/5/\$basearch
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=\$basearch
failovermethod=priority
enabled=0
gpgcheck=0

[epel-puppet]
name=epel puppet
baseurl=http://tmz.fedorapeople.org/repo/puppet/epel/5/\$basearch/
enabled=0
gpgcheck=0
EOF'

sudo yum remove -y ruby ruby-libs ruby-irb ruby-rdoc
#sudo yum install -y ruby ruby-libs ruby-irb ruby-rdoc
sudo yum --enablerepo="ruby" install -y ruby ruby-libs ruby-irb ruby-rdoc

#sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/\$basearch/epel-release-5-4.noarch.rpm
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/\$basearch/epel-release-6-7.noarch.rpm
#sudo yum update

sudo yum --enablerepo=epel,epel-puppet install -y puppet

#yum --enablerepo=epel,epel-puppet install -y puppet-server
#sudo yum install -y puppet-server

sudo sh -c 'echo "    server = master.local" >> /etc/puppet/puppet.conf'
sudo /sbin/service puppet restart
sudo /sbin/chkconfig puppet on