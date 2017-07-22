################################################################################
# Filename    # cross.inc
# Purpose     # Common cross handling functions.
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

################################################################################
# $1 = Target.
# $2 = Any extra configure parameters.
################################################################################
function build_cross_toolchain()
{
	echo "  ( ) Start Processing GNAT/GCC for $1"

	apply_cross_gcc_patches

	cd $BLD

	VER=$1
	STAGE="$VER"
	DIRS="binutils-$BINUTILS_SRC_VERSION gcc1 newlib gcc2"

	local TASK_COUNT_TOTAL=13
	echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

	for d in $DIRS; do
		if [ ! -d $STAGE/$d ]; 	then
			mkdir -p $STAGE/$d
		fi
	done

	LOGPRE=$LOG/$1
	CBD=$BLD/$STAGE

	export PATH=$INSTALL_DIR/bin:$PATH
	export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

	export NATIVE_INSTALL_DIR=$INSTALL_DIR

	# Build Cross version of BinUtils.
	cd $CBD/binutils-$BINUTILS_SRC_VERSION

	if [ ! -f .config ]; then
		echo "  >> [2/$TASK_COUNT_TOTAL] Configuring Binutils for $1..."
		$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--target=$1 \
		--enable-targets=all \
		$2 \
		--enable-multilib \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--with-gcc \
		--with-gnu-as \
		--with-gnu-ld \
                --with-ppl=$INSTALL_DIR \
		--enable-cloog-backend=isl \
		--disable-cloog-version-check \
		--disable-isl-version-check \
                --disable-ppl-version-check \
		--with-gmp=$INSTALL_DIR \
		--with-mpfr=$INSTALL_DIR \
		--with-mpc=$INSTALL_DIR \
		--with-isl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-binutils-config.txt
#		--without-ppl \
#		--without-cloog \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [3/$TASK_COUNT_TOTAL] Building Binutils for $1..."
		make $JOBS &> $LOGPRE-binutils-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [4/$TASK_COUNT_TOTAL] Installing Binutils for $1..."
		make install &> $LOGPRE-binutils-install.txt
		check_error .make-install
	fi
	echo "  >> Binutils Installed"

	LAST=`pwd`

	# Build stage 1 GCC with C only.
	cd $CBD/gcc1

	if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Configuring Cross Stage 1 GCC (C Only)..."
		$GCC_DIR/configure \
		--prefix=$INSTALL_DIR \
		--target=$1 \
		$2 \
		--enable-multilib \
		--with-newlib \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--disable-lto \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c \
		--disable-libssp \
		--without-headers \
		--disable-cloog-version-check \
		--disable-isl-version-check \
		--with-gmp=$INSTALL_DIR \
		--with-mpfr=$INSTALL_DIR \
		--with-mpc=$INSTALL_DIR \
		--with-isl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-gcc1-config.txt
#		--without-ppl \
#		--without-cloog \
#		--with-gmp-include=$NATIVE_INSTALL_DIR/include \
#		--with-ppl=$NATIVE_INSTALL_DIR \
#		--with-cloog=$INSTALL_DIR \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Building Cross Stage 1 GCC (C Only)..."
		# use all-gcc, otherwise libiberty fails as it requires sys/types.h
		# which doesn't exist and tbh, shouldn't even be getting built, it's
		# a bug which has been reported here:
		#   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43073
		make $JOBS all-gcc &> $LOGPRE-gcc1-make.txt

		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Installing Cross Stage 1 GCC (C Only)..."
		make install-gcc &> $LOGPRE-gcc1-install.txt

	    check_error .make-install
	fi
	fi
	echo "  (x) Cross Stage 1 GCC (C Only) Installed"

	LAST=`pwd`

	# Build NewLib
	cd $CBD/newlib

	if [ -f $LAST/.make-install ]; then
		if [ ! -f .config ]; then
			echo "  >> [8/$TASK_COUNT_TOTAL] Configuring Newlib for $1..."
			$SRC/newlib-$NEWLIB_VERSION/configure \
			--prefix=$INSTALL_DIR \
			--target=$1 \
			$2 \
			--enable-multilib \
			--with-gnu-as \
			--with-gnu-ld \
			--disable-nls \
		--with-gmp=$NATIVE_INSTALL_DIR \
		--with-ppl=$NATIVE_INSTALL_DIR \
		--with-cloog=$NATIVE_INSTALL_DIR \
			&> $LOGPRE-newlib-config.txt
#			--without-ppl \
#			--without-cloog \

			check_error .config
		fi

		if [ ! -f .make ]; then
			echo "  >> [9/$TASK_COUNT_TOTAL] Building Newlib for $1..."
			make $JOBS &> $LOGPRE-newlib-make.txt

			check_error .make
		fi

		if [ ! -f .make-install ]; then
			echo "  >> [10/$TASK_COUNT_TOTAL] Installing Newlib for $1..."
			make install &> $LOGPRE-newlib-install.txt

			check_error .make-install
		fi
	fi
	echo "  (x) Newlib Installed"
	LAST=`pwd`

	# Build Stage 2 GCC with C, C++ & Ada
	cd $CBD/gcc2

	if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
		echo "  >> [11/$TASK_COUNT_TOTAL] Configuring Cross Stage 2 GCC (C/Ada)..."
		$GCC_DIR/configure \
		--prefix=$INSTALL_DIR \
		--target=$1 \
		$2 \
		--enable-multilib \
		--with-newlib \
		--with-headers=$SRC/newlib-$NEWLIB_VERSION/newlib/libc/include \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--disable-lto \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c,c++,ada \
		--disable-libssp \
		--disable-cloog-version-check \
		--disable-isl-version-check \
		--with-gmp=$INSTALL_DIR \
		--with-mpfr=$INSTALL_DIR \
		--with-mpc=$INSTALL_DIR \
		--with-isl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-gcc2-config.txt
#		--without-ppl \
#		--without-cloog \
# this next line actually forces gnattools not to build!
#		--disable-libada \
#		--with-gmp=$NATIVE_INSTALL_DIR \
#		--with-ppl=$NATIVE_INSTALL_DIR \
#		--with-cloog=$NATIVE_INSTALL_DIR \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [12/$TASK_COUNT_TOTAL] Building Cross Stage 2 GCC (C/Ada)..."
		make $JOBS &> $LOGPRE-gcc2-make.txt

		check_error .make
	fi

	# if [ ! -f .make-gnattools ]; then
	# 	echo "  >> [13/$TASK_COUNT_TOTAL] Building Cross Stage 2 GCC (GNAT Tools)..."
	# 	make $JOBS all-gnattools &> $LOGPRE-gcc2-make-gnattools.txt

	# 	check_error .make-gnattools
	# fi

	if [ ! -f .make-install ]; then
		echo "  >> [13/$TASK_COUNT_TOTAL] Installing Cross Stage 2 GCC (C/Ada)..."
		make install &> $LOGPRE-gcc2-install.txt

		check_error .make-install
	fi
	fi

	echo "  (x) Cross Stage 2 GCC (C/Ada) Installed"

	# Get back to the build directory.
	cd $BLD
}
