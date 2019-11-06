################################################################################
# Filename    # download.sh
# Purpose     # Downloads the source required to build the toolchains
# Description #
# Copyright   # Copyright (C) 2011-2018 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################
#!/bin/bash

# Cannot put this into config.inc.sh.
export TOP=`pwd`
export INC=$TOP/includes

# Incudes with common function declarations
source $INC/version.inc.sh
source $INC/errors.inc.sh

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

if [ ! -f ./config.inc.sh ]; then
	display_no_config_error
else
	source ./config.inc.sh
fi

source $INC/bootstrap.inc.sh

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
    local PKG_GIT="$1_GIT"
    local PKG_BRANCH="$1_BRANCH"
    local PKG_COMMIT="$1_COMMIT"
    
    if [ ! -d ${!PKG_DIR} ]; then
        echo "  >> Downloading ${!PKG_DIR}..."

        git clone -b ${!PKG_BRANCH} ${!PKG_GIT} ${!PKG_DIR}

        if [ ! -z ${!PKG_COMMIT} ]; then
            cd ${!PKG_DIR}
            git checkout ${!PKG_COMMIT}
            cd ..
        fi

        check_error_exit
    else
        echo "  (x) Already have ${!PKG_DIR}"
    fi
}

# $1 - Package macro prefix (in upper case)
function download_adacore_cdn_package()
{
    local PKG="$1_TARBALL"
    local HASH="$1_HASH"
    local PKG_MIRROR="$1_MIRROR"
    
    if [ ! -f ${!PKG} ]; then
        echo "  >> Downloading ${!PKG}..."

        wget -c ${!PKG_MIRROR}/${!HASH} -O ${!PKG}

        check_error_exit
    else
        echo "  (x) Already have ${!PKG}"
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

# $1 - Package macro prefix (in upper case)
function apply_patches()
{
    local PATCHES="$1_PATCHES"
    local PKG_DIR="$1_DIR"
    local PKG_NAME="$(echo $1 | tr [:upper:] [:lower:])"

    pushd ${!PKG_DIR} &>/dev/null

    for p in ${!PATCHES}; do
        local PATCH_NAME="$(basename ${p})"

        if [ ! -f .patched-${PATCH_NAME} ]; then
            echo "  >> Applying ${PATCH_NAME} to ${PKG_NAME}..."

            patch -Np1 < ${p} &>/dev/null

            check_error .patched-${PATCH_NAME}
        fi
    done

    popd &>/dev/null
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

# download_adacore_cdn_package "GPRBUILD"
download_adacore_cdn_package "XMLADA"
# download_adacore_cdn_package "GNATCOLL"
# download_adacore_cdn_package "ASIS"

#################################################################################
# Unpack the downloaded archives.
#################################################################################

#bootstrap_install

cd $SRC

download_unpack_package "BINUTILS" "j"
download_unpack_package "GDB" "J"
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

    # Make sure there is a directory of patches.
    if [ -d $FILES/$GCC_DIR ]; then
        patch -p0 < $FILES/$GCC_DIR/finalization_size.patch

        check_error .patched
    fi
fi
cd $SRC


download_unpack_package "ISL" "j"

download_unpack_package "PYTHON" "J"

# download_unpack_package "GPRBUILD" "z"
# apply_patches "GPRBUILD"

# download_unpack_package "XMLADA" "z"
# download_unpack_package "GNATCOLL" "z"
# download_unpack_package "ASIS" "z"


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
download_git_package "GNATCOLL_CORE"
download_git_package "GNATCOLL_BINDINGS"

# Remove the link lib iconv as this is in glibc
if [ ! -f .gnatcoll-bindings-commented-out-iconv ]; then
    sed -i '51,58 {s/^/--/}' gnatcoll-bindings/iconv/gnatcoll_iconv.gpr
    sed -i '98,100 {s/^/--/}' gnatcoll-bindings/iconv/gnatcoll_iconv.gpr

    check_error .gnatcoll-bindings-commented-out-iconv
fi

download_git_package "GNATCOLL_DB"

download_git_package "LANGKIT"
apply_patches "LANGKIT"

download_git_package "LIBADALANG"
download_git_package "LIBADALANG_TOOLS"

download_git_package "AUNIT"

# download_git_package "GTKADA"
# download_git_package "LANGKIT"
# download_git_package "LIBADALANG"
# download_git_package "GPS"
