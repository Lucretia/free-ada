########################################################################################################################
# Filename    # gcc.inc
# Purpose     # Common functions for building GCC for the various platforms.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
# $4 - Configure options
function gcc()
{
	local TASK_COUNT_TOTAL=5
	VER="$build_type/$3"
	DIRS="$GCC_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    case $build_type in
        "native")
            MAKEFILE_ALL_TARGET="all"
            MAKEFILE_INSTALL_TARGET="install-strip install-html"
            LANGUAGES=$NATIVE_LANGUAGES
            ;;

        "cross")
            MAKEFILE_ALL_TARGET="all-gcc"
            MAKEFILE_INSTALL_TARGET="install-strip-gcc install-target-libgcc"

            # Special variant for bare metal.
            if [ $variant == "bare" ]; then
                LANGUAGES="c,ada"
            fi
            ;;
    esac

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$GCC_DIR

    if [ ! -f .config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring GCC ($3)..."
        $SRC/$GCC_DIR/configure \
            --prefix=$INSTALL_DIR \
            --target=$3 \
            --build=$2\
            --host=$1\
            $4 \
            --disable-nls \
            --with-gnu-as \
            --with-gnu-ld \
            --enable-languages=$LANGUAGES \
            --with-system-zlib \
            --without-libiconv-prefix \
            --disable-libmudflap \
            --disable-libstdcxx-pch \
            --enable-lto \
            --disable-isl-version-check \
            --disable-ppl-version-check \
            --with-gmp=$INSTALL_DIR \
            --with-mpfr=$INSTALL_DIR \
            --with-mpc=$INSTALL_DIR \
            --with-isl=$INSTALL_DIR \
            &> $LOGPRE/$GCC_DIR-config.txt


	#		--disable-threads \
	#		--disable-ppl \
	#		--disable-cloog \

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GCC ($3)..."
        
        make $MAKEFILE_ALL_TARGET $JOBS &> $LOGPRE/$GCC_DIR-make.txt

        check_error .make
    fi

    # Only run the testsuite if this is a native build.
    case $build_type in
        "native")
            if [ ! -f .make-test ] && [ $GCC_TESTS = "y" ]; then
                echo "  >> [3-pre/$TASK_COUNT_TOTAL] Checking environment for test tools..."

                check_package_installed "Tcl" tclsh
                check_package_installed "Expect" expect
                check_package_installed "DejaGNU" runtest

                echo "  >>   Tcl, Expect and DejaGNU installed..."

                echo "  >> [3/$TASK_COUNT_TOTAL] Testing GNAT/GCC ($3)..."
                make -k check-gcc &> $LOGPRE/$GCC_DIR-test.txt

                check_error .make-test
            else
                echo "  >> [3/$TASK_COUNT_TOTAL] Skipping testing GNAT/GCC ($3)..."
            fi
            ;;

        "cross")
            if [ ! -f .make-libgcc ]; then
                echo "  >> [3.1/$TASK_COUNT_TOTAL] Building Cross libgcc ($3)..."

                make $JOBS all-target-libgcc &> $LOGPRE/$GCC_DIR-libgcc-make.txt

                check_error .make-libgcc
            fi

            if [ ! -f .make-gnattools ]; then
                echo "  >> [3.2/$TASK_COUNT_TOTAL] Building Cross GNAT tools ($3)..."

                make $JOBS -C gcc cross-gnattools ada.all.cross &> $LOGPRE/$GCC_DIR-gnattools-make.txt

                check_error .make-gnattools
            fi
            ;;
    esac

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Packaging GCC ($3)..."
        
        make DESTDIR=$STAGE_BASE_DIR $MAKEFILE_INSTALL_TARGET &> $LOGPRE/$GCC_DIR-pkg.txt
        
        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$GCC_DIR.tbz2 .

            check_error $OBD/$GCC_DIR/.make-pkg

            cd $OBD/$GCC_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [5/$TASK_COUNT_TOTAL] Installing GCC ($3)..."
        
        tar -xjpf $PKG/$PROJECT-$1-$GCC_DIR.tbz2 -C $INSTALL_BASE_DIR
        
        check_error .make-install
    fi

    echo "  >> GCC ($3) Installed"

    echo -e "\n\tDon't forget to set the paths back to the originals:"
    echo -e "\texport PATH=\$OLD_PATH"
    echo -e "\texport LD_LIBRARY_PATH=\$OLD_LD_LIBRARY_PATH\n"
}

