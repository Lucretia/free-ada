################################################################################
# Filename    # build-tools.sh
# Purpose     # Batch build toolchain components
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
# Depends     # http://gcc.gnu.org/install/prerequisites.html
################################################################################
#!/bin/bash

VERSION="build-tools.sh (16/06/2014)"
COPYRIGHT="Copyright (C) 2011-2014 Luke A. Guest, David Rees. All Rights Reserved."

usage="\
$VERSION
$COPYRIGHT

Automate the build of compiler toolchains.

Usage: $0 [-t] TARGET

Options:

     --help           Display this help and exit
     --version        Display version info and exit
     --target TARGET  Build for specified TARGET

                      Valid values for TARGET
                      -----------------------
                       1  - native
                       2  - arm-none-eabi     (Generic boards)
                       3  - i586-elf          (Generic boards)
                       4  - x86_64-elf        (Generic boards)
                       5  - mips-elf          (Generic boards)
                       6  - msp430-elf        (Generic boards)
                       7  - avr               (Generic boards)
                       8  - ppc-elf           (Generic boards)
                       9  - ARM Android       (TODO)
                      10  - MIPS Android      (TODO)
                      11  - x86 Android       (TODO)
                      12  - Win32             (TODO)
                      13  - Win64             (TODO)
                      14  - Mac OS X          (TODO)
                      15  - iOS               (TODO)
                      16  - i586 Steam        (TODO)
                      17  - AMD64 Steam       (TODO)
                      18  - i686-pc-linux-gnu (cross)
                      19  - i686-pc-linux-gnu (host-x-host)
"

target_list="You must enter a target number to build, use -h flag to see list."

################################################################################
# Commandline parameters
################################################################################

case "$1" in
    --help|-h)
	echo "$usage"
	exit $?
	;;

    --version|-v)
	echo "$VERSION"
	echo "$COPYRIGHT"
	exit $?
	;;

    --target|-t)
	case $2 in
	    1)
		# TODO: build_type: native, cross, canadian
		build_type="native"
		;;
	    2)
		build_type="arm-none-eabi"
		;;
	    3)
		build_type="i586-elf"
		;;
	    4)
		build_type="x86_64-elf"
		;;
	    5)
		build_type="mips-elf"
		;;
	    6)
		build_type="msp430-elf"
		;;
	    7)
		build_type="avr"
		;;
	    8)
		build_type="ppc-elf"
		;;
	    18)
		build_type="i686-pc-linux-gnu"
		;;
	    19)
		;;
	    *)
		echo "$target_list"
		exit 1
		;;
	esac
	;;

    # Invalid
    -*)
	echo "$0: invalid option: $1" >&2
	exit 1
	;;

    # Default
    *)
	echo "$target_list"
	exit 1
	;;
esac

clear
cat <<START

  You are about to build and install a compiler toolchain (Native or Cross).
  For basic usage information, please run:

  ./build-tools.sh --help

  Logs from the build process are placed in a build/logs directory with a
  standardised naming, i.e. [description]-[config|make|check|install].txt

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

#exit

# Cannot put this into config.inc.
export TOP=`pwd`
export INC=$TOP/includes

# Incudes with common function declarations
source $INC/errors.inc
source $INC/arithmetic.inc
source $INC/native.inc
source $INC/bare_metal.inc
#source $INC/cross.inc

################################################################################
# Enforce a personalised configuration
################################################################################

if [ ! -f ./config.inc ]; then
	display_no_config_error
else
	source ./config.inc
fi

################################################################################
# Check to make sure the source is downloaded.
################################################################################
if [ ! -d $SRC ]; then
    echo "ERROR: ./source directory not present. Execute ./download.sh"
    exit
fi

################################################################################
# Handle pre-existing build directories
################################################################################
if [ -d $BLD ]; then
    while true; do
	echo    "  -----------------------------------------------------"
	echo    "  -- NOTE: Toolchain build directories exist! ---------"
	echo    "  -----------------------------------------------------"
	read -p "  (R)emove all build directories, (c)ontinue, or (e)xit script? " builddir
	case $builddir in
	    [R]*)
		rm -Rf $BLD
		if [ -d $PKG ]; then
		    rm -Rf $PKG
		fi
		break
		;;
	    [Cc]*) break;;
	    [Ee]*) exit;;
	    *) echo "  Please answer 'R', '[C/c]' or '[E/e]'.";;
	esac
    done
fi

################################################################################
# Handle pre-existing installation directories
################################################################################

if [ -d $INSTALL_DIR ]; then
	while true; do
		echo    "  -----------------------------------------------------"
		echo    "  -- ATTENTION: Toolchain install directories exist! --"
		echo    "  -----------------------------------------------------"
		read -p "  (R)emove all install directories, (c)ontinue, or (e)xit? " installdir
	case $installdir in
		[R]*) rm -Rf $INSTALL_DIR; break;;
		[Cc]*) break;;
		[Ee]*) exit;;
		*) echo "  Please answer 'R', '[C/c]' or '[E/e]'.";;
	esac
	done
fi

################################################################################
# Display some build configuration details
################################################################################

cd $TOP
echo "  Directories"
echo "  -----------"
echo "  Build Type    : " $build_type
echo "  Multilib      : " $multilib_enabled
echo "  Host          : " $HOST
echo "  Build         : "
echo "  Target        : "
echo "  Source        : " $SRC
echo "  Build         : " $BLD
echo "  Log           : " $LOG
echo "  Install dir   : " $INSTALL_DIR
echo "  Stage base dir: " $STAGE_BASE_DIR
echo "  Stage dir     : " $STAGE_DIR
#echo "  GCC Source    : " $GCC_DIR
#echo "  Cross         : " $CROSS_PREFIX
echo ""
echo "  Versions"
echo "  --------"
echo "  GMP           : " $GMP_VERSION
echo "  MPFR          : " $MPFR_VERSION
echo "  MPC           : " $MPC_VERSION
echo "  ISL           : " $ISL_VERSION
if [ $CLOOG_REQUIRED = "y" ]; then
    echo "  CLooG         : " $CLOOG_VERSION
fi
#echo "  NewLib        : " $NEWLIB_VERSION
echo "  Binutils      : " $BINUTILS_SRC_VERSION
#echo "  GCC           : " $GCC_VERSION
echo "  GCC           :  GitHub"
echo "  GDB           : " $GDB_VERSION
echo "  XMLAda        : " $GPL_YEAR
echo "  GPRBuild      : " $GPL_YEAR
echo "  ASIS          : " $GPL_YEAR
echo "  GNATMem       : " $GPL_YEAR
echo "  AUnit         : " $GPL_YEAR
echo "  GNATColl      : " $GPL_YEAR
echo "  PolyORB       : " $GPL_YEAR
echo "  Florist       : " $GPL_YEAR

#echo "  ST-Link       :  GitHub"

echo "  Matreshka     : " $MATRESHKA_VERSION

echo "  Other"
echo "  -----"
echo "  Parallelism   : " $JOBS

echo "Press ENTER to continue."

read x

################################################################################
# Symlinks
#################################################################################

# function create_gmp_symlink()
# {
# 	if [ ! -h gmp ]; then
# 		echo "  >> Creating symbolic link to GMP source..."
# 		ln -s $SRC/gmp-$GMP_VERSION gmp
# 	fi
# }

# function create_gcc_symlinks()
# {
# 	if [ ! -h $GCC_DIR/mpfr ]; then
# 		echo "  >> Creating symbolic link to MPFR source..."
# 		ln -s $SRC/mpfr-$MPFR_VERSION mpfr
# 	fi

# 	if [ ! -h $GCC_DIR/mpc ]; then
# 		echo "  >> Creating symbolic link to MPC source..."
# 		ln -s $SRC/mpc-$MPC_VERSION mpc
# 	fi

#	if [ ! -h $GCC_DIR/gdb ]; then
#		echo "  >> Creating symbolic link to GDB source..."
#		ln -s $SRC/gdb-$GDB_SRC_VERSION gdb
#	fi
#}




# function build_stlink()
# {
#     echo "  ( ) Start Processing stlink for $1"

#     cd $BLD

#     VER=$1
#     STAGE="$VER"
#     DIRS="stlink"

#     echo "  >> Creating Directories (if needed)..."

#     for d in $DIRS; do
# 	if [ ! -d $STAGE/$d ]; 	then
# 	    mkdir -p $STAGE/$d
# 	fi
#     done

#     LOGPRE=$LOG/$1
#     CBD=$BLD/$STAGE

#     cd $CBD/stlink

#     make

#     if [ ! -f .make ]; then
# 	echo "  >> [1] Building stlink for $1..."
# 	make &> $LOGPRE-stlink-make.txt
# 	check_error .make
#     fi

#     if [ ! -f .make-install ]; then
# 	echo "  >> [2] Installing stlink..."
# 	cp gdbserver/st-util $INSTALL_DIR/bin &> $LOGPRE-stlink-install.txt

# 	check_error .make-install
#     fi
# }

# function build_qemu()
# {
#     cd $BLD

#     if [ ! -d qemu ]
#     then
# 	mkdir -p qemu
#     fi

#     cd qemu

#     if [ ! -f .config ]
#     then
# 	echo "  >> Configuring qemu..."

# 	$SRC/qemu/configure --prefix=$INSTALL_DIR \
# 	    --extra-cflags="-Wunused-function" \
# 	    --disable-werror \
# 	    &> $LOG/qemu-config.txt

# 	check_error .config
#     fi

#     if [ ! -f .make ]
#     then
# 	echo "  >> Building qemu..."

# 	make config-host.h all &> $LOG/qemu-make.txt

# 	check_error .make
#     fi

#     if [ ! -f .make-install  ]
#     then
# 	echo "  >> Installing qemu..."

# 	make install &> $LOG/qemu-make-install.txt

# 	check_error .make-install
#     fi
# }

# # U-Boot requires libgcc!
# function build_u_boot()
# {
#     if [ ! -d $1/u-boot ]; then
#     	mkdir -p $1/u-boot
#     fi

# #    cd ../src/u-boot-$U_BOOT_VERSION
#     cd $TOP/src/u-boot

#     if [ ! -f .make ]; then
# 	    echo "  >> Configuring and Building U-Boot for $1..."
# 	    make O=../../build/$1/u-boot distclean
# 	    make O=../../build/$1/u-boot omap3_beagle_config ARCH=arm CROSS_COMPILE=$1-
# 	    make O=../../build/$1/u-boot all ARCH=arm CROSS_COMPILE=$1- &> $LOG/$1-u-boot-make.txt

# 	    check_error .make
#     fi

#     # Back to the thirdparty directory
#     cd $TOP
# }

################################################################################
# Install GNAT wrappers where we cannot build cross versions
# of the gnattools
# $1 = target (i.e. arm-none-eabi)
# $2 = install directory
################################################################################

# function install_wrappers()
# {
#     WRAPPERS="gnatmake gnatlink"

#     cd $TOP/../tools/gcc

#     echo "  >> Installing Gnat Wrappers..."

#     for f in $WRAPPERS; do
# 		install -m0755 -p $f $2/$1-$f
# 		sed -i -e s/target/$1/ $2/$1-$f
#     done
# }

################################################################################
# Prepare log directory, start building
# Creates the $TOP/build directory as well.
################################################################################

if [ ! -d $LOG ]; then
    mkdir -p $LOG
fi

################################################################################
# Prepare the packages directory.
################################################################################

if [ ! -d $PKG ]; then
    mkdir -p $PKG
fi

TIMEFORMAT=$'  Last Process Took: %2lR';
# Begin the specified build operation
case "$build_type" in
    native)
	{ time {
		build_arithmetic_libs;
		build_native_toolchain;
	    } }
	;;

    arm-none-eabi)
	{ time {
		build_bare_metal_cross_toolchain arm-none-eabi y y n;
	    } }
	;;

    i586-elf)
	{ time {
		build_bare_metal_cross_toolchain i586-elf n n y;
	    } }
	;;

    x86_64-elf)
	{ time {
		build_bare_metal_cross_toolchain x86_64-elf n n n;
	    } }
	;;

    x86_64-elf)
	{ time {
		build_bare_metal_cross_toolchain x86_64-elf n n n;
	    } }
	;;

    mips-elf)
	{ time {
		build_bare_metal_cross_toolchain mips-elf n y n;
	    } }
	;;

    msp430-elf)
	{ time {
		build_bare_metal_cross_toolchain msp430-elf n y n;
	    } }
	;;

    avr)
	{ time {
		build_bare_metal_cross_toolchain avr n y n;
	    } }
	;;

    ppc-elf)
	{ time {
		build_bare_metal_cross_toolchain ppc-elf n y n;
	    } }
	;;

    *)				# Default
    	{ time {
    		build_arithmetic_libs;
    		build_native_toolchain;
    		#time ( build_cross_toolchain arm-none-eabi --enable-interwork );
    		#build_cross_toolchain i386-elf;
    		#build_cross_toolchain mips-elf;
    	    } }
    	;;

esac

exit 0
