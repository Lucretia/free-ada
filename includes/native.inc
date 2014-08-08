################################################################################
# Filename    # native.inc
# Purpose     # Common native handling functions.
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

function build_native_binutils() {

    # Build BinUtils.
    cd $CBD/binutils-$BINUTILS_SRC_VERSION

#	    --disable-shared \
    if [ ! -f .config ]; then
	echo "  >> [1/$TASK_COUNT_TOTAL] Configuring Binutils (Native)..."
	$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    $MULTILIB \
	    $EXTRA_BINUTILS_FLAGS \
	    --disable-nls \
	    --enable-threads=posix \
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
	    &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-config.txt


	#		--disable-threads \
	#		--disable-ppl \
	#		--disable-cloog \

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "  >> [2/$TASK_COUNT_TOTAL] Building Binutils (Native)..."
	make $JOBS &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [3/$TASK_COUNT_TOTAL] Packaging Binutils (Native)..."
	make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-binutils-$BINUTILS_SRC_VERSION.tbz2 .
	    check_error $OBD/binutils-$BINUTILS_VERSION/.make-pkg

	    cd $OBD/binutils-$BINUTILS_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]
    then
	echo "  >> [4/$TASK_COUNT_TOTAL] Installing Binutils (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-binutils-$BINUTILS_SRC_VERSION.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi
    echo "  >> Binutils (Native) Installed"
}

################################################################################
# Build GPL'd AdaCore components that we need.
#
# XMLAda for gprbuild.
# gprbuild for better project files and multilanguage support.
#
# Have to build these differently because they don't do configure based builds
# like other tools do.
# TODO: Create a local repo and modify the build work better.
################################################################################
function build_native_xmlada()
{
    # Build XMLAda
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .xmlada-unpacked ]; then
	echo "  >> [10/$TASK_COUNT_TOTAL] Unpacking XMLAda sources (Native)..."
	tar -xzpf $ARC/$XMLADA_VERSION.tar.gz

	check_error .xmlada-unpacked
    fi

    cd xmlada-$GPL_YEAR-src

    if [ ! -f .config ]; then
	echo "  >> [11/$TASK_COUNT_TOTAL] Configuring XMLAda (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-xmlada-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [12/$TASK_COUNT_TOTAL] Building XMLAda (Native)..."
	make $JOBS &> $LOGPRE-xmlada-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [13/$TASK_COUNT_TOTAL] Packaging XMLAda (Native)..."
	make install &> $LOGPRE-xmlada-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-xmlada-$GPL_YEAR.tbz2 .
	    check_error $OBD/xmlada-$GPL_YEAR-src/.make-pkg

	    cd $OBD/xmlada-$GPL_YEAR-src
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [14/$TASK_COUNT_TOTAL] Installing XMLAda (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-xmlada-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> XMLAda (Native) Installed"
}

function build_native_gprbuild()
{
    # Build GPRBuild
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .gprbuild-unpacked ]; then
	echo "  >> [15/$TASK_COUNT_TOTAL] Unpacking GPRBuild sources (Native)..."
	tar -xzpf $ARC/$GPRBUILD_VERSION.tar.gz

	check_error .gprbuild-unpacked
    fi

    cd gprbuild-gpl-$GPL_YEAR-src

    if [ ! -f .patched ]; then
	echo "  >> [16/$TASK_COUNT_TOTAL] Patching GPRBuild (Native)..."
	for f in $(cat $FILES/gprbuild/MANIFEST); do
	    patch -p1 < $FILES/gprbuild/$f;
	done
	check_error .patched
    fi

    if [ ! -f .links ]; then
	echo "  >> [17/$TASK_COUNT_TOTAL] Creating links for GPRBuild (Native)..."
	ln -s $CBD/gcc gcc_build >/dev/null
	ln -s $SRC/gcc/gcc/ada gnat_src >/dev/null
    fi

    if [ ! -f .config ]; then
	echo "  >> [18/$TASK_COUNT_TOTAL] Configuring GPRBuild (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-gprbuild-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .copy ]; then
	echo "  >> [19/$TASK_COUNT_TOTAL] Copying files for GPRBuild (Native)..."

	make copy_gnat_src >/dev/null && make link_version >/dev/null

	check_error .copy
    fi

    if [ ! -f .make ]; then
	echo "  >> [20/$TASK_COUNT_TOTAL] Building GPRBuild (Native)..."
	make $JOBS &> $LOGPRE-gprbuild-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [21/$TASK_COUNT_TOTAL] Packaging GPRBuild (Native)..."
	make install &> $LOGPRE-gprbuild-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gprbuild-$GPL_YEAR.tbz2 .
	    check_error $OBD/gprbuild-$GPL_YEAR-src/.make-pkg

	    cd $OBD/gprbuild-$GPL_YEAR-src
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [22/$TASK_COUNT_TOTAL] Installing GPRBuild (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gprbuild-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GPRBuild (Native) Installed"
}

function build_native_adacore()
{
    build_native_xmlada
    build_native_gprbuild

    # Build ASIS

    # Build GNATMem

    # Build SPARK
}

################################################################################
# Build the Native Compiler (using the compiler found on PATH).
################################################################################

function build_native_toolchain()
{

    echo "  ( ) Start Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Constants
    TASK_COUNT_TOTAL=22
    VER="native"
    DIRS="binutils-$BINUTILS_SRC_VERSION gcc"
    LOGPRE=$LOG/native
    CBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."
    cd $BLD
    for d in $DIRS; do
	if [ ! -d $VER/$d ]; then
	    mkdir -p $VER/$d
	fi
    done

    # Paths
    export PATH=$INSTALL_DIR/bin:$PATH
    export LD_LIBRARY_PATH=$INSTALL_DIR/lib$BITS:$INSTALL_DIR/lib:$LD_LIBRARY_PATH

    #echo "PATH - $PATH"
    #echo "LD_LIBRARY_PATH - $LD_LIBRARY_PATH"

    # Build native binutils
    build_native_binutils

    # gmp,ppl,cloog-ppl built seperate
    # mpfr and mpc src are symlinked in source/gcc
    cd $GCC_DIR
    #create_gcc_symlinks

    # Build native GCC compiler
    cd $CBD/gcc

#	    --disable-shared \
    if [ ! -f .config ]; then
	echo "  >> [5/$TASK_COUNT_TOTAL] Configuring GNAT/GCC (Native)..."
	$GCC_DIR/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    $MULTILIB \
	    --enable-threads=posix \
	    --with-gnu-as \
	    --with-gnu-ld \
	    --enable-languages=$NATIVE_LANGUAGES \
	    --with-system-zlib \
	    --disable-libgomp \
	    --without-libffi \
	    --without-libiconv-prefix \
	    --disable-libmudflap \
	    --disable-nls \
	    --disable-libstdcxx-pch \
	    --disable-cloog-version-check \
	    --disable-isl-version-check \
	    --with-gmp=$INSTALL_DIR \
	    --with-mpfr=$INSTALL_DIR \
	    --with-mpc=$INSTALL_DIR \
	    --with-isl=$INSTALL_DIR \
	    --with-cloog=$INSTALL_DIR \
	    CFLAGS="$EXTRA_NATIVE_CFLAGS" \
	    $EXTRA_NATIVE_GCC_CONFIGURE_FLAGS \
	    &> $LOGPRE-gcc-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [6/$TASK_COUNT_TOTAL] Building and Bootstrapping GNAT/GCC (Native)..."
	make $JOBS &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-test ]; then
	echo "  >> [7-pre/$TASK_COUNT_TOTAL] Checking environment for test tools..."

	check_package_installed "Tcl" tclsh
	check_package_installed "Expect" expect
	check_package_installed "DejaGNU" runtest

	echo "  >>   Tcl, Expect and DejaGNU installed..."

	echo "  >> [7/$TASK_COUNT_TOTAL] Testing GNAT/GCC (Native)..."
	make -k check-gcc &> $LOGPRE-gcc-test.txt

	check_error .make-test
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [8/$TASK_COUNT_TOTAL] Packaging GNAT/GCC (Native)..."
	make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-gcc-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gcc-$DATE.tbz2 .
	    check_error $OBD/gcc/.make-pkg

	    cd $OBD/gcc
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [9/$TASK_COUNT_TOTAL] Installing GNAT/GCC (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gcc-$DATE.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    build_native_adacore

    echo "  (x) Finished Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Get back to the build directory.
    cd $BLD
}
