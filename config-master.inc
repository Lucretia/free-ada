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
export PROJECT_NAME=tinyada

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
#export JOBS="-j 1"

# Scaled Jobs, 2 jobs per cpu core (fast)
export JOBS="-j $(($CORES*2))"

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

export BINUTILS_SNAPSHOT=y

if [ $BINUTILS_SNAPSHOT == "y" ]; then
	# Snapshot
	export BINUTILS_VERSION=2.24.51 # filename version
	BINUTILS_SRC_VERSION=2.24.51 # extracted version
	BINUTILS_TARBALL=ftp://sourceware.org/pub/binutils/snapshots/binutils-$BINUTILS_VERSION.tar.bz2
else
	# Release
	export BINUTILS_VERSION=2.24 # filename version
	BINUTILS_SRC_VERSION=2.24 # extracted version
	export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
	BINUTILS_TARBALL=$BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2
fi

export BINUTILS_TARBALL
export BINUTILS_SRC_VERSION

################################################################################
# GDB ##########################################################################
################################################################################
export GDB_VERSION=7.7.1 # filename version
export GDB_SRC_VERSION=7.7.1 # extracted version
export GDB_MIRROR=http://ftp.gnu.org/gnu/gdb
export GDB_TARBALL=$GDB_MIRROR/gdb-$GDB_VERSION.tar.bz2

################################################################################
# GCC ##########################################################################
################################################################################

export NATIVE_LANGUAGES="c,c++,objc,ada,go"

# Always get GCC from GitHub now.
export GCC_REPO=git@github.com:Lucretia/gcc.git

export GCC_DIR=$SRC/gcc

################################################################################
# Required libs ################################################################
################################################################################

# GMP (GNU Multiple Precision Arithmetic Library)
export GMP_VERSION=5.1.2
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION

# MPC
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
export MPFR_VERSION=3.1.2
export MPFR_MIRROR=http://www.mpfr.org/mpfr-current
export MPFR_PATCHES=http://www.mpfr.org/mpfr-current/allpatches
#export MPFR_MIRROR=http://mpfr.loria.fr/mpfr-current
#export MPFR_PATCHES=http://mpfr.loria.fr/mpfr-current/allpatches

# ISL (Dependancy for CLooG)
# Added support to use the official cloog.org
# The --with-isl configure option should be used if ISL is not installed in your
# default library search path.
export ISL_VERSION=0.12.2
export ISL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure

#CLooG (uses isl as polyhedral library)
# The --with-cloog configure option should be used if CLooG is not installed in
# your default library search path. CLooG needs to be built against ISL 0.10,
# not its included copy of ISL which is too old. Use --with-isl=system to direct
# CLooG to pick up an already installed ISL. CLooG needs to be configured to use
# GMP internally, use --with-bits=gmp to direct it to do that.
export CLOOG_VERSION=0.18.1
export CLOOG_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure

################################################################################
# AdaCore GPL components #######################################################
################################################################################
export GPL_YEAR=2014
export XMLADA_HASH=065e0e6750288d9ecc2f7780d3ed8ef3c86ab991
export XMLADA_VERSION=xmlada-gpl-$GPL_YEAR-src
export GPRBUILD_HASH=c9d9271952a829ff1d355a01285a8558f24baf93
export GPRBUILD_VERSION=gprbuild-gpl-$GPL_YEAR-src

################################################################################
# Additional Options ###########################################################
################################################################################

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
