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
	echo "Creating Output Directory $REPOSITORY_DIRECTORY and cloning gitHub repository $REPOSITORY_URL"
	mkdir -p "$REPOSITORY_DIRECTORY" || die "cannot create: $REPOSITORY_DIRECTORY"

	# Move to the Build directory in preparation to clone the repository
	cd "$REPOSITORY_DIRECTORY" || die "cannot switch to: $REPOSITORY_DIRECTORY"

	# Clone the repository
	git clone "$REPOSITORY_URL" "$REPOSITORY_DIRECTORY" || die "cannot clone $REPOSITORY_URL to $REPOSITORY_DIRECTORY"
	
	# Add the submodule repository URLs to .git/config.
	git submodule init
else
	# Move to the Build directory in preparation to update the repository
	cd "$REPOSITORY_DIRECTORY" || die "cannot switch to: $REPOSITORY_DIRECTORY"

	# Update the repository
    #   First revert any changes to the local build repo. This shouldn't effect any changes in user fork, as the build
    #   repo should be located in a different location than the working fork/branch.
    git reset --hard HEAD
	git pull || die "cannot update repository at $REPOSITORY_DIRECTORY"
	
	if ! grep -Fq "[submodule" "$REPOSITORY_DIRECTORY"/.git/config; then
		# Add the submodule repository URLs to .git/config.
		git submodule init
	fi
fi



# Update any submodules (other git repos within our git repo) in the repo
git submodule update



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
