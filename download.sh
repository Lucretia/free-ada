################################################################################
# Filename    # download.sh
# Purpose     # Downloads the source required to build the toolchains
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################
#!/bin/bash

VERSION="download.sh (16/06/2014)"
COPYRIGHT="Copyright (C) 2011-2014 Luke A. Guest, David Rees. All Rights Reserved."

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
	--version) echo "$VERSION
$COPYRIGHT
"; exit $?;;

	# Help
	--help) echo "$usage"; exit $?;;

	# Invalid
	-*)	echo "$0: invalid option: $1" >&2 ;	exit 1;;

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

# Cannot put this into config.inc.
export TOP=`pwd`
export INC=$TOP/includes

# Incudes with common function declarations
source $INC/errors.inc

################################################################################
# Enforce a personalised configuration
################################################################################

if [ ! -f ./config.inc ]; then
	display_no_config_error
else
	source ./config.inc
fi

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

#cd $TOP/archives
cd $ARC

# Begin Downloading ############################################################

echo "  >> Downloading archives, this may take quite a while..."

# Binutils #####################################################################

if [ ! -f binutils-$BINUTILS_VERSION.tar.bz2 ]; then
	echo "  >> Downloading binutils-$BINUTILS_VERSION..."
	wget -c $BINUTILS_TARBALL

	check_error_exit
else
	echo "  (x) Already have binutils-$BINUTILS_VERSION"
fi

# GDB Tarballs #####################################################################

if [ ! -f gdb-$GDB_VERSION.tar.xz ]; then
	echo "  >> Downloading gdb-$GDB_VERSION..."
	wget -c $GDB_TARBALL

	check_error_exit
else
	echo "  (x) Already have gdb-$GDB_VERSION"
fi

# GCC Tarballs #####################################################################

if [ $GCC_RELEASE == "y" ]; then
    if [ ! -f gcc-$GCC_VERSION.tar.bz2 ]; then
	echo "  >> Downloading gcc-$GCC_VERSION..."
	wget -c $GCC_TARBALL

	check_error_exit
    else
	echo "  (x) Already have gcc-$GCC_VERSION"
    fi
fi

# Prerequisite Libraries ###########################################################

if [ ! -f gmp-$GMP_VERSION.tar.bz2 ]; then
	echo "  >> Downloading gmp-$GMP_VERSION..."
	wget -c $GMP_MIRROR/gmp-$GMP_VERSION.tar.bz2
	check_error_exit
else
	echo "  (x) Already have gmp-$GMP_VERSION"
fi

if [ ! -f isl-$ISL_VERSION.tar.bz2 ]; then
	echo "  >> Downloading isl-$ISL_VERSION..."
	wget -c $ISL_MIRROR/isl-$ISL_VERSION.tar.bz2
	check_error_exit
else
	echo "  (x) Already have isl-$ISL_VERSION"
fi

if [ $CLOOG_REQUIRED = "y" ]; then
    if [ ! -f cloog-$CLOOG_VERSION.tar.gz ]
    then
	echo "  >> cloog-$CLOOG_VERSION.tar.gz..."
	wget -c $CLOOG_MIRROR/cloog-$CLOOG_VERSION.tar.gz
	check_error_exit
    else
	echo "  (x) Already have cloog-$CLOOG_VERSION.tar.gz"
    fi
fi

if [ ! -f mpfr-$MPFR_VERSION.tar.gz ]; then
	echo "  >> Downloading mpfr-$MPFR_VERSION..."
	wget -c $MPFR_MIRROR/mpfr-$MPFR_VERSION.tar.gz
	check_error_exit
else
	echo "  (x) Already have mpfr-$MPFR_VERSION"
fi

if [ ! -f mpc-$MPC_VERSION.tar.gz ]; then
	echo "  >> Downloading mpc-$MPC_VERSION..."
	wget -c $MPC_MIRROR/mpc-$MPC_VERSION.tar.gz
	check_error_exit
else
	echo "  (x) Already have mpc-$MPC_VERSION"
fi

if [ ! -f $XMLADA_VERSION.tar.gz ]; then
    echo "  >> Downloading $XMLADA_VERSION..."
    wget -c -O $XMLADA_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$XMLADA_HASH
else
	echo "  (x) Already have $XMLADA_VERSION"
fi

if [ ! -f $GPRBUILD_VERSION.tar.gz ]; then
    echo "  >> Downloading $GPRBUILD_VERSION..."
    wget -c -O $GPRBUILD_VERSION.tar.gz http://mirrors.cdn.adacore.com/art/$GPRBUILD_HASH
else
	echo "  (x) Already have $GPRBUILD_VERSION"
fi

if [ ! -f asis-gpl-2014-src.tar.gz ]; then
    echo "  >> Downloading asis-gpl-2014..."
    wget -c -O asis-gpl-2014-src.tar.gz http://mirrors.cdn.adacore.com/art/51ecea080c3c6760cd024e8b467502de26f3c3f2
else
	echo "  (x) Already have asis-gpl-2014"
fi

if [ ! -f gnatmem-gpl-2014-src.tar.gz ]; then
    echo "  >> Downloading gnatmem-gpl-2014..."
    wget -c -O gnatmem-gpl-2014-src.tar.gz http://mirrors.cdn.adacore.com/art/6de65bb7e300e299711f90396710ace741123656
else
	echo "  (x) Already have gnatmem-gpl-2014"
fi

#################################################################################
# Unpack the downloaded archives.
#################################################################################

cd $SRC

if [ ! -d binutils-$BINUTILS_SRC_VERSION ]; then
	echo "  >> Unpacking binutils-$BINUTILS_VERSION.tar.bz2..."
	tar -xjpf $ARC/binutils-$BINUTILS_VERSION.tar.bz2
	check_error_exit
fi

if [ ! -d gdb-$GDB_SRC_VERSION ]; then
	echo "  >> Unpacking gdb-$GDB_VERSION.tar.xz..."
	tar -xJpf $ARC/gdb-$GDB_VERSION.tar.xz
	check_error_exit
fi

if [ ! -d gcc-$GCC_SRC_VERSION ]; then
	echo "  >> Unpacking gcc-$GCC_VERSION.tar.bz2..."
	tar -xjpf $ARC/gcc-$GCC_VERSION.tar.bz2
	check_error_exit
fi

# Apply any patches

cd gcc-$GCC_VERSION

if [ "$(ls -A $FILES/gcc-$GCC_VERSION/*)" ] && [ ! -f .patched ]; then
    echo "  >> Patching gcc-$GCC_VERSION..."

    for f in $FILES/gcc-$GCC_VERSION/*; do
	patch -p1 < $f
	check_error_exit
	check_error .patched
    done
fi

cd $SRC

if [ ! -d gmp-$GMP_VERSION ]; then
	echo "  >> Unpacking gmp-$GMP_VERSION.tar.bz2..."
	tar -xjpf $ARC/gmp-$GMP_VERSION.tar.bz2
	check_error_exit
fi

if [ ! -d mpfr-$MPFR_VERSION ]; then
	echo "  >> Unpacking mpfr-$MPFR_VERSION.tar.gz..."
	tar -xzpf $ARC/mpfr-$MPFR_VERSION.tar.gz
	check_error_exit
fi

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

if [ ! -d mpc-$MPC_VERSION ]; then
	echo "  >> Unpacking mpc-$MPC_VERSION.tar.gz..."
	tar -xzpf $ARC/mpc-$MPC_VERSION.tar.gz
	check_error_exit
fi

# if [ ! -d newlib-$NEWLIB_VERSION ]; then
# 	echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
# 	tar -xzpf $ARC/newlib-$NEWLIB_VERSION.tar.gz
# 	check_error_exit
# fi

if [ ! -d isl-$ISL_VERSION ]; then
	echo "  >> Unpacking isl-$ISL_VERSION.tar.bz2..."
	tar -xjpf $ARC/isl-$ISL_VERSION.tar.bz2
	check_error_exit
fi

if [ $CLOOG_REQUIRED = "y" ]; then
    if [ ! -d cloog-$CLOOG_VERSION ]; then
	echo "  >> Unpacking cloog-$CLOOG_VERSION.tar.gz..."
	tar -xzpf $ARC/cloog-$CLOOG_VERSION.tar.gz
	check_error_exit
    fi
fi

# if [ ! -d gcc ]; then
# 	echo "  >> Downloading GCC sources from GitHub, may take a while..."
# 	git clone $GCC_REPO gcc
# 	check_error_exit
# else
# 	echo "  >> Pulling latest GCC sources from GitHub..."
# 	cd gcc
# 	git pull
# fi

cd $SRC
