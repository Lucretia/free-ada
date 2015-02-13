################################################################################
# Filename    # native.inc
# Purpose     # Common native handling functions.
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

function build_native_binutils() {

    if [ $CLOOG_REQUIRED = "y" ]; then
	CLOOG_OPTS="--enable-cloog-backend=isl --disable-cloog-version-check --with-cloog=$INSTALL_DIR"
    fi

    # Build BinUtils.
    cd $CBD/binutils-$BINUTILS_SRC_VERSION

#	    --disable-shared \
    if [ ! -f .config ]; then
	echo "  >> [1/$TASK_COUNT_TOTAL] Configuring Binutils (Native)..."
	$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    --host=$HOST \
	    $MULTILIB \
	    $EXTRA_BINUTILS_FLAGS \
	    --disable-nls \
	    --enable-threads=posix \
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
	    &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-config.txt


	#		--disable-threads \
	#		--disable-ppl \
	#		--disable-cloog \

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "  >> [2/$TASK_COUNT_TOTAL] Building Binutils (Native)..."
	make all $JOBS &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [3/$TASK_COUNT_TOTAL] Packaging Binutils (Native)..."
	make DESTDIR=$STAGE_BASE_DIR install-strip install-html &> $LOGPRE-binutils-$BINUTILS_SRC_VERSION-pkg.txt
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
# This function builds a version of libgnat_util using AdaCore's GPL'd
# makefiles, but uses the source from the FSF GNAT we are using. The source has
# to match the compiler.
#
# This library is used by the other AdaCore tools.
################################################################################
function build_fsf_gnat_util()
{
    cd $CBD/

    if [ ! -f .gnat_util-dir ]; then
	echo "  >> [11/$TASK_COUNT_TOTAL] Creating directory for GNAT_Util (Native)..."
	mkdir gnat_util

	check_error .gnat_util-dir
    fi

    cd gnat_util

    if [ ! -f .build-files-copied ]; then
	echo "  >> [12/$TASK_COUNT_TOTAL] Copying build files for GNAT_Util (Native)..."
	cp $SRC/gnat_util/* .

	check_error .build-files-copied
    fi

    if [ ! -f .sources-copied ]; then
	echo "  >> [13/$TASK_COUNT_TOTAL] Copying FSF GCC sources for GNAT_Util (Native)..."
	for file in $(cat $SRC/gnat_util/MANIFEST.gnat_util); do cp $GCC_DIR/gcc/ada/"$file" .; done

	check_error .sources-copied
    fi

    if [ ! -f .gen-sources-copied ]; then
	echo "  >> [14/$TASK_COUNT_TOTAL] Copying FSF GCC generated sources for GNAT_Util (Native)..."
	cp $CBD/gcc/gcc/ada/sdefault.adb .

	check_error .gen-sources-copied
    fi

    if [ ! -f .make ]; then
	echo "  >> [15/$TASK_COUNT_TOTAL] Building GNAT_Util (Native)..."
	make &> $LOGPRE-gnat_util-make.txt

	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [16/$TASK_COUNT_TOTAL] Packaging GNAT_Util (Native)..."
	make install prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-gnat_util-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gnat_util.tbz2 .
	    check_error $OBD/gnat_util/.make-pkg

	    cd $OBD/gnat_util
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [17/$TASK_COUNT_TOTAL] Installing GNAT_Util (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gnat_util.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GNAT_Util (Native) Installed"
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
	echo "  >> [18/$TASK_COUNT_TOTAL] Unpacking XMLAda sources (Native)..."
	tar -xzpf $ARC/$XMLADA_VERSION.tar.gz

	check_error .xmlada-unpacked
    fi

    cd xmlada-$GPL_YEAR-src

    if [ ! -f .config ]; then
	echo "  >> [19/$TASK_COUNT_TOTAL] Configuring XMLAda (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-xmlada-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [20/$TASK_COUNT_TOTAL] Building XMLAda (Native)..."
	make $JOBS &> $LOGPRE-xmlada-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [21/$TASK_COUNT_TOTAL] Packaging XMLAda (Native)..."
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
	echo "  >> [22/$TASK_COUNT_TOTAL] Installing XMLAda (Native)..."
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
	echo "  >> [23/$TASK_COUNT_TOTAL] Unpacking GPRBuild sources (Native)..."
	tar -xzpf $ARC/$GPRBUILD_VERSION.tar.gz

	check_error .gprbuild-unpacked
    fi

    cd gprbuild-gpl-$GPL_YEAR-src

    if [ ! -f .patched ]; then
	echo "  >> [24/$TASK_COUNT_TOTAL] Patching GPRBuild (Native)..."
	for f in $(cat $FILES/gprbuild/MANIFEST); do
	    patch -p1 < $FILES/gprbuild/$f;
	done
	check_error .patched
    fi

    if [ ! -f .links ]; then
	echo "  >> [25/$TASK_COUNT_TOTAL] Creating links for GPRBuild (Native)..."
	ln -s $GCC_DIR/gcc/ada gnat_src >/dev/null

    	check_error .links
    fi

    if [ ! -f .config ]; then
	echo "  >> [26/$TASK_COUNT_TOTAL] Configuring GPRBuild (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-gprbuild-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .copy ]; then
	echo "  >> [27/$TASK_COUNT_TOTAL] Copying files for GPRBuild (Native)..."

	make copy_gnat_src >/dev/null >/dev/null

	check_error .copy
    fi

    if [ ! -f .make ]; then
	echo "  >> [28/$TASK_COUNT_TOTAL] Building GPRBuild (Native)..."
	make $JOBS &> $LOGPRE-gprbuild-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [29/$TASK_COUNT_TOTAL] Packaging GPRBuild (Native)..."
	make install &> $LOGPRE-gprbuild-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gprbuild-$GPL_YEAR.tbz2 .
	    check_error $OBD/gprbuild-gpl-$GPL_YEAR-src/.make-pkg

	    cd $OBD/gprbuild-gpl-$GPL_YEAR-src
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [30/$TASK_COUNT_TOTAL] Installing GPRBuild (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gprbuild-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GPRBuild (Native) Installed"
}

function build_native_asis()
{
    # Build ASIS
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .asis-unpacked ]; then
	echo "  >> [31/$TASK_COUNT_TOTAL] Unpacking ASIS sources (Native)..."
	tar -xzpf $ARC/$ASIS_VERSION.tar.gz

	check_error .asis-unpacked
    fi

    cd $ASIS_VERSION

    if [ ! -f .make ]; then
	echo "  >> [32/$TASK_COUNT_TOTAL] Building ASIS (Native)..."
	make $JOBS &> $LOGPRE-asis-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [33/$TASK_COUNT_TOTAL] Packaging ASIS (Native)..."
	make install prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-asis-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-asis-$GPL_YEAR.tbz2 .
	    check_error $OBD/$ASIS_VERSION/.make-pkg

	    cd $OBD/$ASIS_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [34/$TASK_COUNT_TOTAL] Installing ASIS (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-asis-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> ASIS (Native) Installed"
}

function build_native_gnatmem()
{
    # Build GNATMem
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .gnatmem-unpacked ]; then
	echo "  >> [35/$TASK_COUNT_TOTAL] Unpacking GNATMem sources (Native)..."
	tar -xzpf $ARC/$GNATMEM_VERSION.tar.gz

	check_error .gnatmem-unpacked
    fi

    cd $GNATMEM_VERSION

    if [ ! -f .patched ]; then
	echo "  >> [36/$TASK_COUNT_TOTAL] Patching GNATMem (Native)..."
	patch -p1 < $FILES/gnatmem/0001-Added-missing-libs.patch;
	check_error .patched
    fi

    if [ ! -f .config ]; then
	echo "  >> [37/$TASK_COUNT_TOTAL] Configuring GNATMem (Native)..."
	./configure \
	    --with-binutils-buildtree=$CBD/binutils-$BINUTILS_SRC_VERSION \
	    --with-binutils-sources=$SRC/binutils-$BINUTILS_SRC_VERSION \
	    &> $LOGPRE-gnatmem-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [38/$TASK_COUNT_TOTAL] Building GNATMem (Native)..."
	make $JOBS &> $LOGPRE-gnatmem-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [39/$TASK_COUNT_TOTAL] Packaging GNATMem (Native)..."
	mkdir -p $STAGE_BASE_DIR$INSTALL_DIR/bin &&
	    cp ./obj/gnatmem $STAGE_BASE_DIR$INSTALL_DIR/bin &> $LOGPRE-gnatmem-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gnatmem-$GPL_YEAR.tbz2 .
	    check_error $OBD/$GNATMEM_VERSION/.make-pkg

	    cd $OBD/$GNATMEM_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [40/$TASK_COUNT_TOTAL] Installing GNATMem (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gnatmem-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GNATMem (Native) Installed"
}

function build_native_adacore()
{
    build_native_xmlada
    build_native_gprbuild
    build_native_asis
    build_native_gnatmem

    # Build SPARK
}

################################################################################
# Build the Native Compiler (using the compiler found on PATH).
################################################################################

function build_native_toolchain()
{

    echo "  ( ) Start Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Constants
    TASK_COUNT_TOTAL=40
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
	    --disable-isl-version-check \
	    --with-gmp=$INSTALL_DIR \
	    --with-mpfr=$INSTALL_DIR \
	    --with-mpc=$INSTALL_DIR \
	    --with-isl=$INSTALL_DIR \
	    $CLOOG_OPTS \
	    CFLAGS="$EXTRA_NATIVE_CFLAGS" \
	    $EXTRA_NATIVE_GCC_CONFIGURE_FLAGS \
	    &> $LOGPRE-gcc-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [6/$TASK_COUNT_TOTAL] Building and Bootstrapping GNAT/GCC (Native)..."
	make all $JOBS &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-test ]; then
	echo "  >> [7-pre/$TASK_COUNT_TOTAL] Checking environment for test tools..."

	check_package_installed "Tcl" tclsh
	check_package_installed "Expect" expect
	check_package_installed "DejaGNU" runtest

	echo "  >>   Tcl, Expect and DejaGNU installed..."

	echo "  >> [8/$TASK_COUNT_TOTAL] Testing GNAT/GCC (Native)..."
	make -k check-gcc &> $LOGPRE-gcc-test.txt

	check_error .make-test
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [9/$TASK_COUNT_TOTAL] Packaging GNAT/GCC (Native)..."
	make DESTDIR=$STAGE_BASE_DIR install-strip install-html &> $LOGPRE-gcc-pkg.txt
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
	echo "  >> [10/$TASK_COUNT_TOTAL] Installing GNAT/GCC (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gcc-$DATE.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    build_fsf_gnat_util
    build_native_adacore

    echo "  (x) Finished Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Get back to the build directory.
    cd $BLD
}
