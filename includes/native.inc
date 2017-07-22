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

function build_native_gdb() {
    cd $CBD/gdb-$GDB_SRC_VERSION

    if [ ! -f .config ]; then
	echo "  >> [11/$TASK_COUNT_TOTAL] Configuring GDB (Native)..."
	$SRC/gdb-$GDB_SRC_VERSION/configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    --host=$HOST \
	    $MULTILIB \
	    $EXTRA_BINUTILS_FLAGS \
	    --disable-nls \
	    --enable-threads=posix \
	    &> $LOGPRE-gdb-$GDB_SRC_VERSION-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [12/$TASK_COUNT_TOTAL] Building GDB (Native)..."
	make all $JOBS &> $LOGPRE-gdb-$GDB_SRC_VERSION-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [13/$TASK_COUNT_TOTAL] Packaging GDB (Native)..."
	make DESTDIR=$STAGE_BASE_DIR install install-html &> $LOGPRE-gdb-$GDB_SRC_VERSION-pkg.txt
	check_error .make-pkg-stage

	strip $STAGE_BASE_DIR$INSTALL_DIR/bin/gdb
	strip $STAGE_BASE_DIR$INSTALL_DIR/bin/gdbserver

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gdb-$GDB_SRC_VERSION.tbz2 .
	    check_error $OBD/gdb-$GDB_VERSION/.make-pkg

	    cd $OBD/gdb-$GDB_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [14/$TASK_COUNT_TOTAL] Installing GDB (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gdb-$GDB_SRC_VERSION.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GDB (Native) Installed"
}

################################################################################
# This function builds a version of libgnat_util using AdaCore's GPL'd
# makefiles, but uses the source from the FSF GNAT we are using. The source has
# to match the compiler.
#
# This library is used by the other AdaCore tools.
################################################################################
function build_fsf_gnat_util_bootstrap()
{
    cd $CBD/

    if [ ! -f .gnat_util-dir ]; then
	echo "  >> [15/$TASK_COUNT_TOTAL] Creating directory for GNAT_Util (Native)..."
	mkdir gnat_util

	check_error .gnat_util-dir
    fi

    cd gnat_util

    if [ ! -f .build-files-copied ]; then
	echo "  >> [16/$TASK_COUNT_TOTAL] Copying build files for GNAT_Util (Native)..."
	cp $SRC/gnat_util/* .

	check_error .build-files-copied
    fi

    if [ ! -f .sources-copied ]; then
	echo "  >> [17/$TASK_COUNT_TOTAL] Copying FSF GCC sources for GNAT_Util (Native)..."
	for file in $(cat $SRC/gnat_util/MANIFEST.gnat_util); do cp $GCC_DIR/gcc/ada/"$file" .; done

	check_error .sources-copied
    fi

    if [ ! -f .gen-sources-copied ]; then
	echo "  >> [18/$TASK_COUNT_TOTAL] Copying FSF GCC generated sources for GNAT_Util (Native)..."
	cp $CBD/gcc/gcc/ada/sdefault.adb .

	check_error .gen-sources-copied
    fi

    if [ ! -f .make ]; then
	echo "  >> [19/$TASK_COUNT_TOTAL] Building GNAT_Util (Native)..."
	make -f Makefile.bootstrap ENABLE_SHARED=yes &> $LOGPRE-gnat_util-make.txt

	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
    	echo "  >> [20/$TASK_COUNT_TOTAL] Packaging GNAT_Util (Native)..."
    	make -f Makefile.bootstrap install prefix=$STAGE_BASE_DIR$INSTALL_DIR ENABLE_SHARED=yes &> $LOGPRE-gnat_util-pkg.txt
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
    	echo "  >> [21/$TASK_COUNT_TOTAL] Installing GNAT_Util (Native)..."
    	tar -xjpf $PKG/$PROJECT-$HOST-gnat_util.tbz2 -C $INSTALL_BASE_DIR
    	check_error .make-install
    fi

    echo "  >> GNAT_Util (Native) Installed"
}

################################################################################
# Build GPL'd AdaCore components that we need.
################################################################################

################################################################################
# Bootstrap GPRBuild/XMLAda
################################################################################
function bootstrap_gprbuild()
{
    cd $CBD/

    STRAP_DIR=gprbuild-bootstrap

    if [ ! -d $STRAP_DIR ]; then
	echo "  >> [??/$TASK_COUNT_TOTAL] Bootstrapping GPRBuild (Native)..."

	mkdir $STRAP_DIR
    fi

    cd $STRAP_DIR

    if [ ! -f .gprbuild-strapped ]; then
	$SRC/gprbuild/bootstrap.sh --prefix=$GPRBUILD_BOOTSTRAP_DIR --srcdir=$SRC/gprbuild --with-xmlada=$SRC/xmlada \
	    &> $LOGPRE-gdb-gprbuild-bootstrap-make.txt

	cp $SRC/gprbuild/share/gprconfig/*.ent $GPRBUILD_BOOTSTRAP_DIR/share/gprconfig/

	check_error .gprbuild-strapped
    fi
}

################################################################################
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
	echo "  >> [22/$TASK_COUNT_TOTAL] Unpacking XMLAda sources (Native)..."

	if [ $XMLADA_GIT = "y" ]; then
	    git clone file://$SRC/xmlada

	    cd xmlada
	else
	    tar -xzpf $ARC/$XMLADA_VERSION.tar.gz

	    cd xmlada-$GPL_YEAR-src
	fi

	check_error .xmlada-unpacked
    fi

    if [ ! -f .config ]; then
	echo "  >> [23/$TASK_COUNT_TOTAL] Configuring XMLAda (Native)..."
	PATH=$GPRBUILD_BOOTSTRAP_DIR/bin:$PATH ./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-xmlada-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [24/$TASK_COUNT_TOTAL] Building XMLAda (Native)..."
	PATH=$GPRBUILD_BOOTSTRAP_DIR/bin:$PATH make $JOBS &> $LOGPRE-xmlada-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [25/$TASK_COUNT_TOTAL] Packaging XMLAda (Native)..."
	PATH=$GPRBUILD_BOOTSTRAP_DIR/bin:$PATH make install &> $LOGPRE-xmlada-$GPL_YEAR-pkg.txt
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
	echo "  >> [26/$TASK_COUNT_TOTAL] Installing XMLAda (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-xmlada-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> XMLAda (Native) Installed"
}

function build_native_gprbuild()
{
    # git clone --branch free-ada-for-5.1.0 file://`pwd`/../source/gprbuild
    
    # Build GPRBuild
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .gprbuild-unpacked ]; then
	echo "  >> [27/$TASK_COUNT_TOTAL] Unpacking GPRBuild sources (Native)..."
	tar -xzpf $ARC/$GPRBUILD_VERSION.tar.gz

	check_error .gprbuild-unpacked
    fi

    cd gprbuild-gpl-$GPL_YEAR-src

    if [ ! -f .patched ]; then
	echo "  >> [28/$TASK_COUNT_TOTAL] Patching GPRBuild (Native)..."
	for f in $(cat $FILES/gprbuild/MANIFEST); do
	    patch -p1 < $FILES/gprbuild/$f;
	done
	check_error .patched
    fi

    if [ ! -f .links ]; then
	echo "  >> [29/$TASK_COUNT_TOTAL] Creating links for GPRBuild (Native)..."
	ln -s $GCC_DIR/gcc/ada gnat_src >/dev/null

    	check_error .links
    fi

    if [ ! -f .config ]; then
	echo "  >> [30/$TASK_COUNT_TOTAL] Configuring GPRBuild (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-gprbuild-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .copy ]; then
	echo "  >> [31/$TASK_COUNT_TOTAL] Copying files for GPRBuild (Native)..."

	make copy_gnat_src >/dev/null >/dev/null

	check_error .copy
    fi

    if [ ! -f .make ]; then
	echo "  >> [32/$TASK_COUNT_TOTAL] Building GPRBuild (Native)..."
	make $JOBS &> $LOGPRE-gprbuild-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [33/$TASK_COUNT_TOTAL] Packaging GPRBuild (Native)..."
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
	echo "  >> [34/$TASK_COUNT_TOTAL] Installing GPRBuild (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gprbuild-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GPRBuild (Native) Installed"
}

function build_native_gnatcoll()
{
    # Build GNATColl
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .gnatcoll-unpacked ]; then
	echo "  >> [35/$TASK_COUNT_TOTAL] Unpacking GNATColl sources (Native)..."
	tar -xzpf $ARC/$GNATCOLL_VERSION.tar.gz

	check_error .gnatcoll-unpacked
    fi

    cd $GNATCOLL_VERSION

    if [ ! -f .config ]; then
	echo "  >> [36/$TASK_COUNT_TOTAL] Configuring GNATColl (Native)..."
	./configure \
	    --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
	    &> $LOGPRE-gnatcoll-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [37/$TASK_COUNT_TOTAL] Building GNATColl (Native)..."
	make all docs $JOBS &> $LOGPRE-gnatcoll-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [38/$TASK_COUNT_TOTAL] Packaging GNATColl (Native)..."
	make install prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-gnatcoll-$GPL_YEAR-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-gnatcoll-$GPL_YEAR.tbz2 .
	    check_error $OBD/$GNATCOLL_VERSION/.make-pkg

	    cd $OBD/$GNATCOLL_VERSION
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [39/$TASK_COUNT_TOTAL] Installing GNATColl (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gnatcoll-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GNATColl (Native) Installed"
}

function build_native_asis()
{
    # Build ASIS
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .asis-unpacked ]; then
	echo "  >> [40/$TASK_COUNT_TOTAL] Unpacking ASIS sources (Native)..."
	tar -xzpf $ARC/$ASIS_VERSION.tar.gz

	check_error .asis-unpacked
    fi

    cd $ASIS_VERSION

    if [ ! -f .patched ]; then
	echo "  >> [41/$TASK_COUNT_TOTAL] Patching ASIS sources (Native)..."
	for f in $(cat $FILES/asis/MANIFEST); do
	    patch -p1 < $FILES/asis/$f;
	done
	check_error .patched
    fi

    if [ ! -f .make ]; then
	echo "  >> [42/$TASK_COUNT_TOTAL] Building ASIS (Native)..."
	make $JOBS &> $LOGPRE-asis-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-tools ]; then
	echo "  >> [43/$TASK_COUNT_TOTAL] Building ASIS Tools (Native)..."
	make tools $JOBS &> $LOGPRE-asis-$GPL_YEAR-make-tools.txt
	check_error .make-tools
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [44/$TASK_COUNT_TOTAL] Packaging ASIS (Native)..."
	make install install-tools prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-asis-$GPL_YEAR-pkg.txt
        install -s tools/gnat2xml/gnat2xml $STAGE_BASE_DIR$INSTALL_DIR/bin
        install -s tools/gnat2xml/gnat2xsd $STAGE_BASE_DIR$INSTALL_DIR/bin
        install -s tools/gnat2xml/xml2gnat $STAGE_BASE_DIR$INSTALL_DIR/bin
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
	echo "  >> [45/$TASK_COUNT_TOTAL] Installing ASIS (Native)..."
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
	echo "  >> [46/$TASK_COUNT_TOTAL] Unpacking GNATMem sources (Native)..."
	tar -xzpf $ARC/$GNATMEM_VERSION.tar.gz

	check_error .gnatmem-unpacked
    fi

    cd $GNATMEM_VERSION

    if [ ! -f .patched ]; then
	echo "  >> [47/$TASK_COUNT_TOTAL] Patching GNATMem (Native)..."
	patch -p1 < $FILES/gnatmem/0001-Added-missing-libs.patch;
	check_error .patched
    fi

    if [ ! -f .config ]; then
	echo "  >> [48/$TASK_COUNT_TOTAL] Configuring GNATMem (Native)..."
	./configure \
	    --with-binutils-buildtree=$CBD/binutils-$BINUTILS_SRC_VERSION \
	    --with-binutils-sources=$SRC/binutils-$BINUTILS_SRC_VERSION \
	    &> $LOGPRE-gnatmem-$GPL_YEAR-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [49/$TASK_COUNT_TOTAL] Building GNATMem (Native)..."
	make $JOBS &> $LOGPRE-gnatmem-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [50/$TASK_COUNT_TOTAL] Packaging GNATMem (Native)..."
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
	echo "  >> [51/$TASK_COUNT_TOTAL] Installing GNATMem (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-gnatmem-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> GNATMem (Native) Installed"
}

function build_native_aunit()
{
    # Build AUnit
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .aunit-unpacked ]; then
	echo "  >> [52/$TASK_COUNT_TOTAL] Unpacking AUnit sources (Native)..."
	tar -xzpf $ARC/$AUNIT_VERSION.tar.gz

	check_error .aunit-unpacked
    fi

    cd $AUNIT_DIR

    if [ ! -f .make ]; then
	echo "  >> [53/$TASK_COUNT_TOTAL] Building AUnit (Native)..."
	make $JOBS &> $LOGPRE-aunit-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [54/$TASK_COUNT_TOTAL] Packaging AUnit (Native)..."
	make install INSTALL=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-aunit-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-aunit-$GPL_YEAR.tbz2 .
	    check_error $OBD/$AUNIT_DIR/.make-pkg

	    cd $OBD/$AUNIT_DIR
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [55/$TASK_COUNT_TOTAL] Installing AUnit (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-aunit-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> AUnit (Native) Installed"
}

function build_native_polyorb()
{
    # Build PolyORB
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .polyorb-unpacked ]; then
	echo "  >> [56/$TASK_COUNT_TOTAL] Unpacking PolyORB sources (Native)..."
	tar -xzpf $ARC/$POLYORB_VERSION.tar.gz

	check_error .polyorb-unpacked
    fi

    cd $POLYORB_DIR

    if [ ! -f .config ]; then
	echo "  >> [57/$TASK_COUNT_TOTAL] Configuring PolyORB (Native shared)..."

	ADA=gcc CC=gcc ./configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    --enable-shared \
	    --with-gprbuild=gprbuild \
	    --with-appli-perso="corba dsa moma" \
	    --with-proto-perso="giop soap srp" \
	    --with-corba-services="event ir naming notification time"
	    &> $LOGPRE-polyorb-$GPL_YEAR-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [58/$TASK_COUNT_TOTAL] Building PolyORB (Native shared)..."
	make &> $LOGPRE-polyorb-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [59/$TASK_COUNT_TOTAL] Packaging (part 1) PolyORB (Native shared)..."
	make install prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-polyorb-pkg.txt
	check_error .make-pkg-stage
    fi

    make distclean

    # Static version

    if [ ! -f .config-static ]; then
	echo "  >> [60/$TASK_COUNT_TOTAL] Configuring PolyORB (Native static)..."

	ADA=gcc CC=gcc ./configure \
	    --prefix=$INSTALL_DIR \
	    --target=$HOST \
	    --build=$HOST \
	    --disable-shared \
	    --with-gprbuild=gprbuild \
	    --with-appli-perso="corba dsa moma" \
	    --with-proto-perso="giop soap srp" \
	    --with-corba-services="event ir naming notification time"
	    &> $LOGPRE-polyorb-$GPL_YEAR-configure-static.txt
	check_error .config-static
    fi

    if [ ! -f .make-static ]; then
	echo "  >> [61/$TASK_COUNT_TOTAL] Building PolyORB (Native static)..."
	make &> $LOGPRE-polyorb-$GPL_YEAR-make-static.txt
	check_error .make-static
    fi

    if [ ! -f .make-pkg-stage-static ]; then
	echo "  >> [62/$TASK_COUNT_TOTAL] Packaging (part 2) PolyORB (Native static)..."
	make install prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-polyorb-pkg-static.txt
	check_error .make-pkg-stage-static
    fi

    # Now package them both.

    if [ ! -f .make-pkg ]; then
	echo "  >> [63/$TASK_COUNT_TOTAL] Packaging (part 3) PolyORB (Native shared/static)..."
	cd $STAGE_DIR
	tar -cjpf $PKG/$PROJECT-$HOST-polyorb-$GPL_YEAR.tbz2 .
	check_error $OBD/$POLYORB_DIR/.make-pkg

	cd $OBD/$POLYORB_DIR
	rm -rf /tmp/opt
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [64/$TASK_COUNT_TOTAL] Installing PolyORB (Native shared/static)..."
	tar -xjpf $PKG/$PROJECT-$HOST-polyorb-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> PolyORB (Native shared/static) Installed"
}

function build_native_florist()
{
    # Build Florist
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .florist-unpacked ]; then
	echo "  >> [65/$TASK_COUNT_TOTAL] Unpacking Florist sources (Native)..."
	tar -xzpf $ARC/$FLORIST_VERSION.tar.gz

	check_error .florist-unpacked
    fi

    cd $FLORIST_DIR

    if [ ! -f .config ]; then
	echo "  >> [66/$TASK_COUNT_TOTAL] Configuring Florist (Native)..."

	ADA=gcc CC=gcc ./configure \
	    --prefix=$INSTALL_DIR \
	    &> $LOGPRE-florist-$GPL_YEAR-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [67/$TASK_COUNT_TOTAL] Building Florist (Native)..."
	make &> $LOGPRE-florist-$GPL_YEAR-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [68/$TASK_COUNT_TOTAL] Packaging Florist (Native)..."
	make install PREFIX=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE-florist-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-florist-$GPL_YEAR.tbz2 .
	    check_error $OBD/$FLORIST_DIR/.make-pkg

	    cd $OBD/$FLORIST_DIR
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [69/$TASK_COUNT_TOTAL] Installing Florist (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-florist-$GPL_YEAR.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> Florist (Native) Installed"
}

function build_native_adacore()
{
    bootstrap_gprbuild
    build_native_xmlada
    # build_native_gprbuild
    # build_native_gnatcoll
    # build_native_asis
    # build_native_gnatmem
    # build_native_aunit
    # build_native_polyorb
    # build_native_florist

    # Build SPARK
}

################################################################################
# Build other components.
################################################################################
function build_native_matreshka()
{
    # Build Matreshka
    # Unpack in build dir, config, install to tmp, package, unpack in install_dir.
    cd $CBD/

    if [ ! -f .matreshka-unpacked ]; then
	echo "  >> [66/$TASK_COUNT_TOTAL] Unpacking Matreshka sources (Native)..."
	tar -xzpf $ARC/matreshka-$MATRESHKA_VERSION.tar.gz

	check_error .matreshka-unpacked
    fi

    cd $MATRESHKA_DIR

    if [ ! -f .make-config ]; then
	echo "  >> [67/$TASK_COUNT_TOTAL] Make config Matreshka (Native)..."
	make config &> $LOGPRE-matreshka-$MATRESHKA_VERSION-make-config.txt
	check_error .make-config
    fi

    if [ ! -f .config ]; then
	echo "  >> [68/$TASK_COUNT_TOTAL] Configuring Matreshka (Native)..."

	./configure \
	    --prefix=$INSTALL_DIR \
	    &> $LOGPRE-matreshka-$MATRESHKA_VERSION-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [69/$TASK_COUNT_TOTAL] Building Matreshka (Native)..."
	make $JOBS &> $LOGPRE-matreshka-$MATRESHKA_VERSION-make.txt
	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
	echo "  >> [70/$TASK_COUNT_TOTAL] Packaging Matreshka (Native)..."
	make install DESTDIR=$STAGE_BASE_DIR &> $LOGPRE-matreshka-$MATRESHKA_VERSION-pkg.txt
	check_error .make-pkg-stage

	if [ ! -f .make-pkg ]; then
	    cd $STAGE_DIR
	    tar -cjpf $PKG/$PROJECT-$HOST-matreshka-$MATRESHKA_VERSION.tbz2 .
	    check_error $OBD/$MATRESHKA_DIR/.make-pkg

	    cd $OBD/$MATRESHKA_DIR
	    rm -rf /tmp/opt
	fi
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [71/$TASK_COUNT_TOTAL] Installing Matreshka (Native)..."
	tar -xjpf $PKG/$PROJECT-$HOST-matreshka-$MATRESHKA_VERSION.tbz2 -C $INSTALL_BASE_DIR
	check_error .make-install
    fi

    echo "  >> Matreshka (Native) Installed"
}

function build_native_other()
{
    build_native_matreshka
}

################################################################################
# Build the Native Compiler (using the compiler found on PATH).
################################################################################

function build_native_toolchain()
{

    echo "  ( ) Start Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Constants
    TASK_COUNT_TOTAL=71
    VER="native"
    DIRS="binutils-$BINUTILS_SRC_VERSION gcc gdb-$GDB_SRC_VERSION"
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
	    --enable-lto \
	    $CLOOG_OPTS \
	    $EXTRA_NATIVE_GCC_CONFIGURE_FLAGS \
	    CFLAGS="$EXTRA_NATIVE_CFLAGS" \
	    &> $LOGPRE-gcc-configure.txt
	check_error .config
    fi

    if [ ! -f .make ]; then
	echo "  >> [6/$TASK_COUNT_TOTAL] Building and Bootstrapping GNAT/GCC (Native)..."
	make all $JOBS &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-test ] && [ $GCC_TESTS = "y" ]; then
	echo "  >> [7-pre/$TASK_COUNT_TOTAL] Checking environment for test tools..."

	check_package_installed "Tcl" tclsh
	check_package_installed "Expect" expect
	check_package_installed "DejaGNU" runtest

	echo "  >>   Tcl, Expect and DejaGNU installed..."

	echo "  >> [8/$TASK_COUNT_TOTAL] Testing GNAT/GCC (Native)..."
	make -k check-gcc &> $LOGPRE-gcc-test.txt

	check_error .make-test
    else
	echo "  >> [7-8/$TASK_COUNT_TOTAL] Skipping testing GNAT/GCC (Native)..."
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

    build_native_gdb
    build_fsf_gnat_util_bootstrap
    build_native_adacore
#    build_native_other

    echo "  (x) Finished Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

    # Get back to the build directory.
    cd $BLD
}
