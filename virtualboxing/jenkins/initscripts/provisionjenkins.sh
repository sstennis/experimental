#!/bin/bash
#
#	Provision for Jenkins via puppet
#

THIS_DIRECTORY="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $THIS_DIRECTORY/../puppet/manifests
sudo puppet apply baseCentOS56.pp
popd
