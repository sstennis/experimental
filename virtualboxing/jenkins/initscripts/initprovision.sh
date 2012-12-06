# Version history

# Version	| Date		| Author		| Notes
# 1			| 11/29/2012| Scot Stennis  | Initial

#!/bin/bash
#
#	Install sufficient resources to launch puppet provisioning, and
#	launch puppet provisioning. As much as possible, all sources are
#	stored in GitHub, so this script needs to ensure git is installed
#	and then clone the GitHub repo where the provisioning scripts are
#	located. From there, the puppet install script can be accessed
#	and run, then puppet launched to initiate the provisioning process.
#


# Usage description
PROGRAM=`basename $0`
usage() {
    cat << _USAGE_ >&2
usage:
    $PROGRAM repository repository_directory

    Repository is the GitHub repository user name, which is the unique value within the icix Git repos:
        Icix 		- master branch that most releng builds should be run from by default
        GKeighley
        guohuang
        sstennnis
        hollandck

	Repository directory is the directory in which the repository root is located.
 
	EXAMPLE:  $PROGRAM Icix /home/jenkins/repos
   
_USAGE_
    exit 1
}



# Helpers
#_______________________________

die() {
    echo "$*" >&2
    usage
}



# Validate the args
#_______________________________

# Validate the number of args
if [ $# -lt 2 ]
then
   usage
fi 


# Get the args
REPOSITORY=$1
shift
REPOSITORY_DIRECTORY=$1/$REPOSITORY
shift


# Validate repository arg
# Note: may disable this check once provisioning is more mature and
#	we are stabilized. Alternatively, may check in production only
#	for Icix as valid, and in Dev as below for developers too.
case $REPOSITORY in
	"Icix") 			echo "Valid repository";;
	"Icix-Server") 		echo "Valid repository";;
	"GKeighley") 		echo "Valid repository";;
	"guohuang") 		echo "Valid repository";;
	"sstennis") 		echo "Valid repository";;
	"hollandck") 		echo "Valid repository";;
	"prernasingh") 		echo "Valid repository";;
	"omullarney")		echo "Valid repository";;
	"abrittis-icix")	echo "Valid repository";;
	*) 					echo "Invalid repository"
						usage;;
esac



# Get the repository
#_______________________________

# Check that Git is installed
git --version 2>&1 >/dev/null # improvement by tripleee
GIT_IS_AVAILABLE=$?
if [ ! $GIT_IS_AVAILABLE -eq 0 ]; then
	echo "Warning: Git does not appear to be installed"
	echo "Attempting git install..."
	
	# Note that password entry may be required to run these commands.
	sudo rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm
	sudo yum -y install --enablerepo=webtatic git
	
	if [ ! $? -eq 0 ]; then
		die "Error: failed to install git."
	fi
fi


# Set environment variables
# TODO: update the repo URL to the appropriate icix repo when ready.
REPOSITORY_URL="https://github.com/sstennis/experimental.git"


# If the repo doesn't exist locally, clone it, otherwise update it.
if [ ! -d "$REPOSITORY_DIRECTORY" ]; then
	echo "Creating Output Directory $REPOSITORY_DIRECTORY"
	mkdir -p "$REPOSITORY_DIRECTORY" || die "cannot create: $REPOSITORY_DIRECTORY"

	# Move to the Build directory in preparation to clone the repository
	pushd "$REPOSITORY_DIRECTORY" || die "cannot switch to: $REPOSITORY_DIRECTORY"

	# Clone the repository
	echo "Cloning gitHub repository $REPOSITORY_URL"
	echo "git clone $REPOSITORY_URL $REPOSITORY_DIRECTORY"
	git clone "$REPOSITORY_URL" "$REPOSITORY_DIRECTORY" || die "cannot clone $REPOSITORY_URL to $REPOSITORY_DIRECTORY"
	
else
	# Move to the Build directory in preparation to update the repository
	pushd "$REPOSITORY_DIRECTORY" || die "cannot switch to: $REPOSITORY_DIRECTORY"

	# Update the repository
    #   First revert any changes to the local build repo. This shouldn't effect any changes in user fork, as the build
    #   repo should be located in a different location than the working fork/branch.
    git reset --hard HEAD
	git pull || die "cannot update repository at $REPOSITORY_DIRECTORY"
fi



# Add the submodule repository URLs to .git/config. From testing, if any new modules are
# added to the .gitmodules file, failing to call git submodule init will prevent them from
# getting into the .git/config file, and thus the git submodule update command won't include
# them. Thus, looks like this (submodule init) needs to be done every time.
git submodule init



# Update any submodules (other git repos within our git repo) in the repo
git submodule update



# Move back to origin dir.
popd



# Check that puppet is installed
puppet --version 2>&1 >/dev/null # improvement by tripleee
PUPPET_IS_AVAILABLE=$?
if [ ! $PUPPET_IS_AVAILABLE -eq 0 ]; then
 	echo "Warning: Puppet does not appear to be installed"
 	echo "Attempting puppet install..."
 
	sudo $REPOSITORY_DIRECTORY/virtualboxing/jenkins/initscripts/installpuppet.sh
	if [ ! $? -eq 0 ]; then
		die "Error: failed to install puppet."
	fi
fi


# Now that puppet is installed, the various manifests and modules need to be copied to
# the location puppet expects them to be in, or it won't find them.
# This location is typically /etc/puppet/manifests and /etc/puppet/modules
# Because of this, it is essential to use unique names for manifests in the root
# manifest dir and modules in the modules dir.
sudo rm /etc/puppet/modules/ant
sudo rm /etc/puppet/modules/epel
sudo rm /etc/puppet/modules/firewall
sudo rm /etc/puppet/modules/git
sudo rm /etc/puppet/modules/java
sudo rm /etc/puppet/modules/jenkins
sudo rm /etc/puppet/modules/jenkinsprep
sudo rm /etc/puppet/modules/sunjava
sudo rm /etc/puppet/modules/wget

sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/ant /etc/puppet/modules/ant
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/epel /etc/puppet/modules/epel
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/firewall /etc/puppet/modules/firewall
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/git /etc/puppet/modules/git
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/java /etc/puppet/modules/java
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/jenkins /etc/puppet/modules/jenkins
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/jenkinsprep /etc/puppet/modules/jenkinsprep
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/sunjava /etc/puppet/modules/sunjava
sudo ln -s $REPOSITORY_DIRECTORY/provisioning/jenkins/puppet/modules/wget /etc/puppet/modules/wget




# Now provision Jenkins using puppet manifests.
sudo $REPOSITORY_DIRECTORY/virtualboxing/jenkins/initscripts/provisionjenkins.sh
