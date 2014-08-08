################################################################################
# Filename         # errors.inc
# Purpose          # Common error handling functions.
# Description      #
# Copyright        # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#                  # All Rights Reserved.
################################################################################

function check_error_exit()
{
    if [ $? != 0 ]; then
        echo "  ERROR: Something went wrong!"
        exit 2;
    fi
}

# $1 = Filename to create using touch, used in successive steps to test
#      if the previous step was completed.
function check_error()
{
    if [ $? != 0 ]; then
	echo "  ERROR: Something went wrong!"
	exit 2;
    else
	touch $1
    fi
}

# $1 = Package name.
# $2 = command to check for.
function check_package_installed()
{
    which $2 &> /dev/null

    if [ $? != 0 ]; then
       	echo "  ERROR: $1 not installed on this system, install and restart script!"
	exit 2;
    fi
}

function display_no_config_error()
{
cat << 'NOCONFIG_ERR'

  ERROR: No config.inc found.

  1) cp config-master.inc config.inc
  2) Peronalise config.inc for your system
  3) Run this script again

NOCONFIG_ERR
    
    exit 2
}

