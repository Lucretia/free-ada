################################################################################
# Filename    # download.sh
# Purpose     # Downloads the source required to build the toolchains
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################
#!/bin/bash

# Cannot put this into config.inc.
export TOP=`pwd`
export INC=$TOP/includes

# Incudes with common function declarations
source $INC/version.inc
source $INC/errors.inc

VERSION="download.sh ($VERSION_DATE)"

usage="\
$VERSION
$COPYRIGHT

Automatically download the toolchain source.

Usage: $0

Options:

     --help         Display this help and exit
     --version      Display version info and exit
"

################################################################################
# Commandline parameters
################################################################################

while test $# -ne 0; do

	case "$1" in
        # Version
        --version|-v)
            echo -e "$VERSION\n\n$COPYRIGHT"
            exit $?
            ;;

        # Help
        --help|-h)
            echo "$usage"
            exit $?
            ;;

        # Invalid
        -*)
            echo "$0: invalid option: $1" >&2
            exit 1
            ;;

        # Default
        *) break ;;
	esac

done

clear

cat <<START

  You are about to download the compiler toolchain source code.
  For basic usage information, please run:

  ./download.sh --help

  THIS SOFTWARE IS PROVIDED BY THE  COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY  EXPRESS OR IMPLIED WARRANTIES,  INCLUDING, BUT NOT LIMITED  TO, THE
  IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR  A PARTICULAR PURPOSE
  ARE  DISCLAIMED. IN  NO EVENT  SHALL  THE COPYRIGHT  HOLDER OR  CONTRIBUTORS
  BE  LIABLE FOR  ANY  DIRECT, INDIRECT,  INCIDENTAL,  SPECIAL, EXEMPLARY,  OR
  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED  TO,  PROCUREMENT  OF
  SUBSTITUTE GOODS  OR SERVICES; LOSS  OF USE,  DATA, OR PROFITS;  OR BUSINESS
  INTERRUPTION)  HOWEVER CAUSED  AND ON  ANY THEORY  OF LIABILITY,  WHETHER IN
  CONTRACT,  STRICT LIABILITY,  OR  TORT (INCLUDING  NEGLIGENCE OR  OTHERWISE)
  ARISING IN ANY WAY  OUT OF THE USE OF THIS SOFTWARE, EVEN  IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  $COPYRIGHT

  Press ENTER to continue...
START

read x

################################################################################
# Enforce a personalised configuration
################################################################################

if [ ! -f ./config.inc ]; then
	display_no_config_error
else
	source ./config.inc
fi

source $INC/bootstrap.inc

function check_for_spark()
{
	if [ ! -f $SPARK_FILE ]; then

cat << SPARK_ERR

  NOTICE: Spark was not found in the downloads directory.

  1) Go to http://libre.adacore.com/libre/download/
  2) Download $SPARK_FILE
  3) Place the archive in the downloads directory
  4) Re-run this script

SPARK_ERR

        exit 2;
	fi
}

# Prepare Directories ##########################################################

#DIRS="source archives"
DIRS="$SRC $ARC"
for d in $DIRS; do
	if [ ! -d $d ]; then
		mkdir -p $d
	fi
done

# Utility functions ############################################################

# $1 - Package macro prefix (in upper case)
function download_package()
{
    local PKG="$1_TARBALL"
    local PKG_MIRROR="$1_MIRROR"
    
    if [ ! -f ${!PKG} ]; then
        echo "  >> Downloading ${!PKG}..."
        wget -c ${!PKG_MIRROR}/${!PKG}

        check_error_exit
    else
        echo "  (x) Already have ${!PKG}"
    fi
}

# $1 - Package macro prefix (in upper case)
function download_git_package()
{
    local PKG_DIR="$1_DIR"
    local PKG_MIRROR="$1_MIRROR"
    
    if [ ! -d ${!PKG_DIR} ]; then
        echo "  >> Downloading ${!PKG_DIR}..."

        git clone ${!PKG_MIRROR} ${!PKG_DIR}

        check_error_exit
    else
        echo "  (x) Already have ${!PKG_DIR}"
    fi
}

# $1 - Package macro prefix (in upper case)
# $2 - Compression letter for tar
function download_unpack_package()
{
    local PKG="$1_TARBALL"
    local PKG_DIR="$1_DIR"
    
    if [ ! -d ${!PKG_DIR} ]; then
        echo "  >> Unpacking ${!PKG}..."
        
        tar -x${2}pf $ARC/${!PKG}

        check_error_exit
    fi
}

cd $ARC

# Begin Downloading ############################################################

echo "  >> Downloading archives, this may take quite a while..."

# Base packages ################################################################

bootstrap_download

download_package "BINUTILS"
download_package "GDB"

if [ $GCC_RELEASE == "y" ]; then
    download_package "GCC"
fi

# Prerequisite Libraries ###########################################################

download_package "GMP"
download_package "MPC"
download_package "MPFR"
download_package "ISL"
download_package "PYTHON"

# AdaCore Libraries/Tools ###########################################################

#~ if [ $XMLADA_GIT = "y" ]; then
    #~ echo "  >> Downloading XMLAda..."

    #~ cd $SRC

    #~ if [ ! -d xmlada ]; then
	#~ git clone $XMLADA_REPO
    #~ else
	#~ cd xmlada
	#~ git pull
	#~ cd ..
    #~ fi

    #~ cd $ARC
#~ else
    #~ if [ ! -f $XMLADA_VERSION.tar.gz ]; then
	#~ echo "  >> Downloading $XMLADA_VERSION..."
	#~ wget -c -O $XMLADA_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$XMLADA_HASH
    #~ else
	#~ echo "  (x) Already have $XMLADA_VERSION"
    #~ fi
#~ fi

#~ if [ $GPRBUILD_GIT = "y" ]; then
    #~ echo "  >> Downloading GPRBuild..."

    #~ cd $SRC

    #~ if [ ! -d gprbuild ]; then
	#~ git clone $GPRBUILD_REPO
    #~ else
	#~ cd gprbuild
	#~ git pull
	#~ cd ..
    #~ fi

    #~ cd $ARC
#~ else
    #~ if [ ! -f $GPRBUILD_VERSION.tar.gz ]; then
	#~ echo "  >> Downloading $GPRBUILD_VERSION..."
	#~ wget -c -O $GPRBUILD_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$GPRBUILD_HASH
    #~ else
	#~ echo "  (x) Already have $GPRBUILD_VERSION"
    #~ fi
#~ fi

#~ if [ ! -f $ASIS_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading $ASIS_VERSION..."
    #~ wget -c -O $ASIS_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$ASIS_HASH
#~ else
	#~ echo "  (x) Already have $ASIS_VERSION"
#~ fi

#~ if [ ! -f $GNATMEM_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading $GNATMEM_VERSION..."
    #~ wget -c -O $GNATMEM_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$GNATMEM_HASH
#~ else
	#~ echo "  (x) Already have $GNATMEM_VERSION"
#~ fi

#~ if [ ! -f $AUNIT_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading $AUNIT_VERSION..."
    #~ wget -c -O $AUNIT_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$AUNIT_HASH
#~ else
	#~ echo "  (x) Already have $AUNIT_VERSION"
#~ fi

#~ if [ $GNATCOLL_GIT = "y" ]; then
    #~ echo "  >> Downloading GNATColl..."

    #~ cd $SRC

    #~ if [ ! -d gnatcoll ]; then
	#~ git clone $GNATCOLL_REPO
    #~ else
	#~ cd gnatcoll
	#~ git pull
	#~ cd ..
    #~ fi

    #~ cd $ARC
#~ else
    #~ if [ ! -f $GNATCOLL_VERSION.tar.gz ]; then
	#~ echo "  >> Downloading $GNATCOLL_VERSION..."
	#~ wget -c -O $GNATCOLL_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$GNATCOLL_HASH
    #~ else
	#~ echo "  (x) Already have $GNATCOLL_VERSION"
    #~ fi
#~ fi

#~ if [ ! -f $POLYORB_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading $POLYORB_VERSION..."
    #~ wget -c -O $POLYORB_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$POLYORB_HASH
#~ else
	#~ echo "  (x) Already have $POLYORB_VERSION"
#~ fi

#~ if [ ! -f $FLORIST_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading $FLORIST_VERSION..."
    #~ wget -c -O $FLORIST_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$FLORIST_HASH
#~ else
	#~ echo "  (x) Already have $FLORIST_VERSION"
#~ fi

#~ if [ $GPS_GIT = "y" ]; then
    #~ echo "  >> Downloading GPS..."

    #~ if [ ! -d gps ]; then
	#~ git clone $GPS_REPO
    #~ else
	#~ cd gps
	#~ git pull
	#~ cd ..
    #~ fi

    #~ cd $ARC
#~ fi

# Other Libraries/Tools ###########################################################

#~ if [ ! -f matreshka-$MATRESHKA_VERSION.tar.gz ]; then
    #~ echo "  >> Downloading matreshka-$MATRESHKA_VERSION..."
    #~ wget -c $MATRESHKA_MIRROR/matreshka-$MATRESHKA_VERSION.tar.gz
#~ else
	#~ echo "  (x) Already have matreshka-$MATRESHKA_VERSION"
#~ fi

#################################################################################
# Unpack the downloaded archives.
#################################################################################

#bootstrap_install

cd $SRC

download_unpack_package "BINUTILS" "j"
download_unpack_package "GSB" "J"
download_unpack_package "GCC" "J"

# Apply any patches

#~ cd gcc-$GCC_VERSION

#~ if [ -d $FILES/gcc-$GCC_VERSION ]; then
    #~ if [ "$(ls -A $FILES/gcc-$GCC_VERSION/*)" ] && [ ! -f .patched ]; then
        #~ echo "  >> Patching gcc-$GCC_VERSION..."

        #~ for f in $FILES/gcc-$GCC_VERSION/*; do
            #~ patch -p1 < $f
            #~ check_error_exit
            #~ check_error .patched
        #~ done
    #~ fi
#~ fi

#~ cd $SRC

download_unpack_package "GMP" "J"
download_unpack_package "MPC" "z"
download_unpack_package "MPFR" "J"

cd mpfr-$MPFR_VERSION

if [ ! -v $MPFR_PATCHES ] && [ ! -f .patched ]; then
	echo "  >> Downloading mpfr-$MPFR_VERSION patches..."
	wget -c $MPFR_PATCHES
	check_error_exit

	mv allpatches ../mpfr-$MPFR_VERSION.patch
	check_error_exit

	echo "  >> Applying mpfr-$MPFR_VERSION patches..."
	# Patch, ignoring patches already applied
	# Work silently unless an error occurs
	patch -s -N -p1 < ../mpfr-$MPFR_VERSION.patch
	check_error_exit
	check_error .patched
fi

cd $SRC

# if [ ! -d newlib-$NEWLIB_VERSION ]; then
# 	echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
# 	tar -xzpf $ARC/newlib-$NEWLIB_VERSION.tar.gz
# 	check_error_exit
# fi

cd $GCC_DIR
if [ ! -f .patched ]; then
    cd gcc/ada
    patch -p0 < $FILES/$GCC_DIR/finalization_size.patch
fi
cd $SRC


download_unpack_package "ISL" "j"

download_unpack_package "PYTHON" "J"

# if [ ! -d gcc ]; then
# 	echo "  >> Downloading GCC sources from GitHub, may take a while..."
# 	git clone $GCC_REPO gcc
# 	check_error_exit
# else
# 	echo "  >> Pulling latest GCC sources from GitHub..."
# 	cd gcc
# 	git pull
# fi

#~ cd $SRC

download_git_package "GPRBUILD"
download_git_package "XMLADA"
download_git_package "GNATCOLL"
download_git_package "GTKADA"
download_git_package "LANGKIT"
download_git_package "LIBADALANG"
download_git_package "GPS"

#~ if [ $GPRBUILD_GIT = "y" ]; then
    #~ if [ -d gprbuild ] && [ ! -f .patched ]; then
	#~ cd gprbuild

	#~ exists=`git show-ref refs/heads/$GPRBUILD_GIT_BRANCH`

	#~ if [ -n "$exists" ]; then
	    #~ # Just make sure this is the right branch.
	    #~ git co $GPRBUILD_GIT_BRANCH
	#~ else
	    #~ # Make the branch and patch it.
	    #~ echo "  >> Patching GPRBuild for GCC-$GCC_VERSION..."
	    #~ git co -b $GPRBUILD_GIT_BRANCH $GPRBUILD_GIT_REMOTE_BRANCH

	    #~ for f in $FILES/gprbuild/$GCC_VERSION/*; do
		#~ #git apply -p 1 $f
		#~ git am $f
		#~ check_error_exit
	    #~ done

	    #~ check_error .patched
	#~ fi

	#~ cd ..
    #~ fi
#~ fi


