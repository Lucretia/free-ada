################################################################################
# Filename    # bare_metal.inc
# Purpose     # Build a cross-compiler for bare metal compilers.
# Description #
# Copyright   # Copyright (C) 2011-2015 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

################################################################################
# $1 = Target.
# $2 = Enable interwork.
# $3 = Enable multilib.
# $4 = Add EFI targets.
################################################################################
function build_bare_metal_cross_toolchain()
{
    if [ $CLOOG_REQUIRED = "y" ]; then
	CLOOG_OPTS="--enable-cloog-backend=isl --disable-cloog-version-check --with-cloog=$INSTALL_DIR"
    fi

    VER=$1
    TARGET="$VER"
    INTERWORK=""
    MULTILIB=""
    EFI=""
    STAGE="$VER"

    if [ $2 = "y" ]; then
	INTERWORK="--enable-interwork"
    fi

    if [ $3 = "y" ]; then
	MULTILIB="--enable-multilib"
    fi

    if [ $4 = "y" ]; then
	EFI="--enable-targets=i386-efi-pe,$1"
    fi

    EXTRA_CONFIGURE_FLAGS="$INTERWORK $MULTILIB $EFI"

    cd $BLD

    echo "  ( ) Start Processing GNAT/GCC for $TARGET"

    if [ $TARGET = "x86_64-elf" ]; then
	DIRS="binutils-$BINUTILS_SRC_VERSION gcc"
    else
	DIRS="binutils-$BINUTILS_SRC_VERSION gcc gdb-$GDB_SRC_VERSION"
    fi

    local TASK_COUNT_TOTAL=15
    echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

    for d in $DIRS; do
	if [ ! -d $STAGE/$d ]; 	then
	    mkdir -p $STAGE/$d
	fi
    done

    LOGPRE=$LOG/$VER
    CBD=$BLD/$STAGE
    OBD=$BLD/$VER

    export PATH=$INSTALL_DIR/bin:$PATH
    export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

    export NATIVE_INSTALL_DIR=$INSTALL_DIR

    # Build Cross version of BinUtils.
    cd $CBD/binutils-$BINUTILS_SRC_VERSION

    if [ ! -f .config ]; then
	echo "  >> [2/$TASK_COUNT_TOTAL] Configuring Binutils for ($TARGET)..."
	$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$TARGET \
	    $EXTRA_CONFIGURE_FLAGS \
	    --disable-nls \
	    --disable-shared \
	    --disable-threads \
	    --with-gcc \
	    --with-gnu-as \
	    --with-gnu-ld \
            --with-ppl=$INSTALL_DIR \
	    --disable-isl-version-check \
            --disable-ppl-version-check \
	    --with-gmp=$INSTALL_DIR \
	    --with-mpfr=$INSTALL_DIR \
	    --with-mpc=$INSTALL_DIR \
	    --with-isl=$INSTALL_DIR \
	    $CLOOG_OPTS \
	&> $LOGPRE-binutils-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [3/$TASK_COUNT_TOTAL] Building Binutils for ($TARGET)..."
	make $JOBS &> $LOGPRE-binutils-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [4/$TASK_COUNT_TOTAL] Packaging Binutils ($TARGET)..."
	make DESTDIR=$STAGE_BASE_DIR install-strip &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$TARGET-binutils-$BINUTILS_SRC_VERSION.tbz2 .
	    check_error $OBD/binutils-$BINUTILS_VERSION/.make-pkg

	    cd $OBD/binutils-$BINUTILS_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [5/$TASK_COUNT_TOTAL] Installing Binutils for ($TARGET)..."
	tar -xjpf $PKG/$PROJECT-$TARGET-binutils-$BINUTILS_SRC_VERSION.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> Binutils ($TARGET) Installed"

    # Build GCC.
    cd $CBD/gcc

    if [ ! -f .config ]; then
	echo "  >> [6/$TASK_COUNT_TOTAL] Configuring Cross GCC ($TARGET)..."
	$GCC_DIR/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$TARGET \
	    $EXTRA_CONFIGURE_FLAGS \
	    --disable-nls \
	    --disable-shared \
	    --disable-threads \
	    --disable-lto \
	    --with-gnu-as \
	    --with-gnu-ld \
	    --enable-languages=c,ada \
	    --disable-libssp \
	    --without-headers \
	    --disable-isl-version-check \
	    --disable-ppl-version-check \
	    --with-gmp=$INSTALL_DIR \
	    --with-mpfr=$INSTALL_DIR \
	    --with-mpc=$INSTALL_DIR \
	    --with-isl=$INSTALL_DIR \
	    $CLOOG_OPTS \
	    --disable-libada \
	&> $LOGPRE-gcc-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [7/$TASK_COUNT_TOTAL] Building Cross GCC ($TARGET)..."
	make $JOBS all-gcc &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-libgcc ]; then
	echo "  >> [8/$TASK_COUNT_TOTAL] Building Cross libgcc ($TARGET)..."
	make $JOBS all-target-libgcc &> $LOGPRE-gcc-make.txt

	check_error .make-libgcc
    fi

    if [ ! -f .make-gnattools ]; then
	echo "  >> [9/$TASK_COUNT_TOTAL] Building Cross GNAT tools ($TARGET)..."
	make $JOBS -C gcc cross-gnattools ada.all.cross &> $LOGPRE-gcc-gnattools-make.txt

	check_error .make-gnattools
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [10/$TASK_COUNT_TOTAL] Packaging GNAT/GCC ($TARGET)..."
	make DESTDIR=$STAGE_BASE_DIR install-strip-gcc install-target-libgcc &> $LOGPRE-gcc-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$TARGET-gcc-$GCC_VERSION.tbz2 .
	    check_error $OBD/gcc/.make-pkg

	    cd $OBD/gcc
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [11/$TASK_COUNT_TOTAL] Installing Cross GCC ($TARGET)..."
	tar -xjpf $PKG/$PROJECT-$TARGET-gcc-$GCC_VERSION.tbz2 -C $INSTALL_BASE_DIR

	check_error .make-install
    fi

    echo "  >> GCC ($TARGET) Installed"

    ## GDB

    if [ $TARGET = "x86_64-elf" ]; then
	echo "  >> [12-15/$TASK_COUNT_TOTAL] Skipping x86-elf-gdb as it is broken and doesn't build, use your native gdb instead"
    else
	cd $CBD/gdb-$GDB_SRC_VERSION

	if [ ! -f .config ]; then
	    echo "  >> [12/$TASK_COUNT_TOTAL] Configuring Cross GDB ($TARGET)..."
	    CFLAGS="-O2" LDFLAGS="-s" $SRC/gdb-$GDB_SRC_VERSION/configure \
		  --prefix=$INSTALL_DIR \
		  --target=$TARGET \
		  $EXTRA_CONFIGURE_FLAGS \
		  --disable-nls \
		  --disable-shared \
		  --disable-threads \
	    &> $LOGPRE-gdb-$GDB_SRC_VERSION-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]; then
	    echo "  >> [13/$TASK_COUNT_TOTAL] Building Cross GDB ($TARGET)..."
	    make all $JOBS &> $LOGPRE-gdb-$GDB_SRC_VERSION-make.txt
	    check_error .make
	fi

	if [ ! -f .make-pkg-stage ]; then
	    echo "  >> [14/$TASK_COUNT_TOTAL] Packaging Cross GDB ($TARGET)..."
	    make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-gdb-$GDB_SRC_VERSION-pkg.txt
	    check_error .make-pkg-stage

	    #	strip $STAGE_BASE_DIR$INSTALL_DIR/bin/gdb
	    #	strip $STAGE_BASE_DIR$INSTALL_DIR/bin/gdbserver

	    if [ ! -f .make-pkg ]; then
		cd $STAGE_DIR
		tar -cjpf $PKG/$PROJECT-$TARGET-gdb-$GDB_SRC_VERSION.tbz2 .
		check_error $OBD/gdb-$GDB_VERSION/.make-pkg

		cd $OBD/gdb-$GDB_VERSION
		rm -rf /tmp/opt
	    fi
	fi

	if [ ! -f .make-install ]; then
	    echo "  >> [15/$TASK_COUNT_TOTAL] Installing Cross GDB ($TARGET)..."
	    tar -xjpf $PKG/$PROJECT-$TARGET-gdb-$GDB_SRC_VERSION.tbz2 -C $INSTALL_BASE_DIR
	    check_error .make-install
	fi

	echo "  >> GDB ($TARGET) Installed"
    fi
}
