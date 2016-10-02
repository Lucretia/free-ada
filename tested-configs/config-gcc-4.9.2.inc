################################################################################
# Filename    # config.inc
# Purpose     # Defines the Toolchain source versions/mirrors
# Copyright   # Copyright (C) 2011-2013 Luke A. Guest, David Rees.
# Depends     # http://gcc.gnu.org/install/prerequisites.html
# Description # 1) cp config-master.inc config.inc
#             # 2) edit config.inc as required for your machine.
#             # 3) ./build-tools.sh --help
################################################################################

################################################################################
# Project name, can change.
################################################################################
export PROJECT_NAME=free-ada

################################################################################
# So we don't overwrite an already working toolchain! This is only valid when
# building a new native toolchain. Once this has been done, move your old tools
# to a new directory and rename the new one, then remove the "-new" from the
# PROJECT variable.
# TODO: Put in a check when building cross compilers.
################################################################################
export PROJECT=$PROJECT_NAME-new

################################################################################
# INSTALL_BASE_DIR - This is where tar needs to change directory to.
# INSTALL_DIR      - Where the actual local toolchain is going to placed.
# STAGE_BASE_DIR   - This is the where we stage the install to get ready for
#                    packaging.
# STAGE_DIR        - We want to get to the base $PROJECT_NAME directory for
#                    packaging.
################################################################################
INSTALL_BASE_DIR=$HOME/opt
INSTALL_DIR=$INSTALL_BASE_DIR/$PROJECT
STAGE_BASE_DIR=/tmp/opt/$PROJECT
STAGE_DIR=$STAGE_BASE_DIR$INSTALL_DIR/..

################################################################################
# Basic directories we need.
################################################################################
export SRC=$TOP/source
export ARC=$TOP/archives
export LOG=$TOP/build/logs
export BLD=$TOP/build
export PKG=$TOP/packages
export FILES=$TOP/files

################################################################################
# Date variable for packaging anything from source control.
################################################################################
export DATE=`date +%d%m%Y`

################################################################################
# What OS are we on? e.g. Linux, Darwin, MSYS_*
# N.B: Don't call is OS because gprbuild.gpr grabs the variable.
################################################################################
export LOCAL_OS=`uname -s`

################################################################################
# What archtecture is this? e.g. x86_64, i686
################################################################################
export ARCH=`uname -m`

################################################################################
# Find out what platform we are on.
################################################################################

case $LOCAL_OS in
    "Linux")
	HOST=$ARCH-pc-linux-gnu
	;;
    "Darwin")
	;;
    "MSYS*")
	;;
esac

################################################################################
# Is the host machine 64 bit? Used for LD_LIBRARY_PATH, leave blank for 32.
################################################################################
if grep -q 64 <<< $ARCH; then
    export BITS=64
    export MULTILIB="--enable-multilib"
    export EXTRA_BINUTILS_FLAGS="--enable-64-bit-bfd"
    export multilib_enabled="yes"
else
    export BITS=
    export MULTILIB=""
    export EXTRA_64_BIT_CONFIGURE=""
    export multilib_enabled="no"
fi

################################################################################
# Parallel Make Threads/Jobs
################################################################################
# How many 'make' threads do you want to have going during the build?
# In most cases using a value greater than the number of processors
# in your machine will result in fewer and shorter I/O latency hits,
# thus improving overall throughput; this is especially true for
# slow drives and network filesystems.
# Load-average Threshold tells 'make' to spawn new jobs only when the load
# average is less than or equal to it's value. If the load average becomes
# greater, 'make' will wait until the average drops below this number,
# or until all the other jobs finish. Use only one of the options;
# Static Jobs, Scaled Jobs, or Dynamic or Static Load-average Threshold.
################################################################################
CORES=`grep 'model name' /proc/cpuinfo | wc -l`

# Static Jobs
# 1 = No Parallel Make Jobs (slow)
export JOBS="-j 4"

# Scaled Jobs, 2 jobs per cpu core (fast)
# export JOBS="-j $(($CORES*2))"

# Dynamic Load-average Threshold (slow, but can reduce cpu hammering)
# Spawn parallel processes only at < 100% core utilization
# export JOBS=--load-average=$(echo "scale=2; $CORES*100/100" | bc)

# Static Load-average Threshold
# export JOBS=--load-average=3.5


# Edit package versions/mirrors as required.

################################################################################
# Required tools ###############################################################
################################################################################

################################################################################
# BINUTILS #####################################################################
################################################################################

export BINUTILS_SNAPSHOT=n

if [ $BINUTILS_SNAPSHOT == "y" ]; then
    # Snapshot
    export BINUTILS_VERSION=2.24.51 # filename version
    BINUTILS_SRC_VERSION=2.24.51 # extracted version
    BINUTILS_TARBALL=ftp://sourceware.org/pub/binutils/snapshots/binutils-$BINUTILS_VERSION.tar.bz2
else
    # Release
    export BINUTILS_VERSION=2.25 # filename version
    BINUTILS_SRC_VERSION=2.25 # extracted version
    export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
    BINUTILS_TARBALL=$BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2
fi

export BINUTILS_TARBALL
export BINUTILS_SRC_VERSION

################################################################################
# GDB ##########################################################################
################################################################################
export GDB_VERSION=7.8.1 # filename version
export GDB_SRC_VERSION=7.8.1 # extracted version
export GDB_MIRROR=http://ftp.gnu.org/gnu/gdb
export GDB_TARBALL=$GDB_MIRROR/gdb-$GDB_VERSION.tar.xz

################################################################################
# GCC ##########################################################################
################################################################################

export NATIVE_LANGUAGES="c,c++,objc,obj-c++,ada"

export GCC_RELEASE=y

if [ $GCC_RELEASE == "y" ]; then
    export GCC_VERSION=4.9.2 # filename version
    export GCC_SRC_VERSION=4.9.2 # extracted version
    export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-4.9.2
    export GCC_TARBALL=$GCC_MIRROR/gcc-$GCC_VERSION.tar.bz2

    export GCC_DIR=$SRC/gcc-$GCC_SRC_VERSION
else
    # Always get GCC from GitHub now.
    #export GCC_REPO=git@github.com:Lucretia/gcc.git
    #export GCC_REPO=https://github.com/gcc-mirror/gcc.git

    export GCC_DIR=$SRC/gcc
fi

################################################################################
# Required libs ################################################################
################################################################################

# GMP (GNU Multiple Precision Arithmetic Library)
#export GMP_VERSION=4.3.2
export GMP_VERSION=5.1.2
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION

# MPC
#export MPC_VERSION=0.8.1
export MPC_VERSION=1.0.2
export MPC_MIRROR=http://www.multiprecision.org/mpc/download

# MPFR (Multiple Precision Floating Point Computations With Correct Rounding)
# Warning! Due to the fact that TLS support is now detected automatically, the
# MPFR build can be incorrect on some platforms (compiler or system bug). Indeed,
# the TLS implementation of some compilers/platforms is buggy, and MPFR cannot
# detect every problem at configure time. Please run "make check" to see if your
# build is affected. If you get failures, you should try the
# --disable-thread-safe configure option to disable TLS and see if this solves
# these failures. But you should not use an MPFR library with TLS disabled in a
# multithreaded program (unless you know what you are doing).
#export MPFR_VERSION=2.4.2
#export MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
#export MPFR_PATCHES=http://www.mpfr.org/mpfr-$MPFR_VERSION/allpatches
export MPFR_VERSION=3.1.2
export MPFR_MIRROR=http://mpfr.loria.fr/mpfr-current
export MPFR_PATCHES=http://mpfr.loria.fr/mpfr-current/allpatches

# ISL (Dependancy for CLooG)
# Added support to use the official cloog.org
# The --with-isl configure option should be used if ISL is not installed in your
# default library search path.
export ISL_VERSION=0.12.2
#export ISL_VERSION=0.14
export ISL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure

#CLooG (uses isl as polyhedral library)
# The --with-cloog configure option should be used if CLooG is not installed in
# your default library search path. CLooG needs to be built against ISL 0.10,
# not its included copy of ISL which is too old. Use --with-isl=system to direct
# CLooG to pick up an already installed ISL. CLooG needs to be configured to use
# GMP internally, use --with-bits=gmp to direct it to do that.
export CLOOG_REQUIRED=y

if [ $CLOOG_REQUIRED = "y" ]; then
    export CLOOG_VERSION=0.18.1
    export CLOOG_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
fi

################################################################################
# AdaCore GPL components #######################################################
################################################################################
export GPL_YEAR=2014
export XMLADA_HASH=065e0e6750288d9ecc2f7780d3ed8ef3c86ab991
export XMLADA_VERSION=xmlada-gpl-$GPL_YEAR-src
export GPRBUILD_HASH=c9d9271952a829ff1d355a01285a8558f24baf93
export GPRBUILD_VERSION=gprbuild-gpl-$GPL_YEAR-src
export ASIS_HASH=51ecea080c3c6760cd024e8b467502de26f3c3f2
export ASIS_VERSION=asis-gpl-$GPL_YEAR-src
export GNATMEM_HASH=6de65bb7e300e299711f90396710ace741123656
export GNATMEM_VERSION=gnatmem-gpl-$GPL_YEAR-src
export AUNIT_HASH=43f6630248c40941c77be5c06571000925764bbb
export AUNIT_VERSION=aunit-gpl-$GPL_YEAR-src
export AUNIT_DIR=aunit-3.7.0w-src
export GNATCOLL_HASH=0f1572cadf981e4e493497dfbf783889387d52be
export GNATCOLL_VERSION=gnatcoll-gpl-$GPL_YEAR-src
export POLYORB_HASH=22f27fec50a9c2b92be2e10aa5027eb49567787c
export POLYORB_VERSION=polyorb-gpl-$GPL_YEAR-src
export POLYORB_DIR=polyorb-$GPL_YEAR-src
export FLORIST_HASH=224f73e1cd4afd1f0f6ca3bd1ad0191aa7f81e05
export FLORIST_VERSION=florist-gpl-$GPL_YEAR-src
export FLORIST_DIR=florist-src

################################################################################
# Additional Options ###########################################################
################################################################################

export MATRESHKA_VERSION=0.7.0
export MATRESHKA_MIRROR=http://forge.ada-ru.org/matreshka/downloads
export MATRESHKA_DIR=matreshka-$MATRESHKA_VERSION

export AHVEN_VERSION=2.6
export AHVEN_MIRROR=http://www.ahven-framework.com/releases
export AHVEN_DIR=ahven-$AHVEN_VERSION

# export U_BOOT_VERSION=1.3.4
# export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
#export NEWLIB_VERSION=1.20.0
#export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
#export STLINK_MIRROR=git://github.com/texane/stlink.git
# export SPARK_FILE=spark-gpl-2011-x86_64-pc-linux-gnu.tar.gz

################################################################################
# Implementation specific tuning ###############################################
################################################################################

# Versions of the GNU C library up to and including 2.11.1 included an incorrect
# implementation of the cproj function. GCC optimizes its builtin cproj according
# to the behavior specified and allowed by the ISO C99 standard. If you want to
# avoid discrepancies between the C library and GCC's builtin transformations
# when using cproj in your code, use GLIBC 2.12 or later. If you are using an
# older GLIBC and actually rely on the incorrect behavior of cproj, then you can
# disable GCC's transformations using -fno-builtin-cproj.

#export EXTRA_NATIVE_CFLAGS="-march=native"

################################################################################
# GMP, MPFR, MPC static lib installation directory #############################
################################################################################
# export STAGE1_LIBS_PREFIX=$STAGE1_PREFIX/opt/libs
# export STAGE2_LIBS_PREFIX=$STAGE2_PREFIX/opt/libs
