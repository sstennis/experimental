#!/bin/bash
#
#	Provision for Jenkins via puppet
#

THIS_DIRECTORY="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo puppet apply $THIS_DIRECTORY/../puppet/manifests/baseCentOS56.pp
