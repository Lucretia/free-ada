########################################################################################################################
# Filename    # binutils.inc
# Purpose     # Common functions for building binutils for the various platforms.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
# $4 - Configure options
function binutils()
{
	local TASK_COUNT_TOTAL=4
	VER="$build_type/$3"
	DIRS="$BINUTILS_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."
    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    if [ ! -d $LOGPRE ]; then
        mkdir -p $LOGPRE
    fi

    cd $OBD/$BINUTILS_DIR

    if [ ! -f .config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring Binutils ($3)..."
        $SRC/$BINUTILS_DIR/configure \
            --prefix=$INSTALL_DIR \
            --target=$3 \
            --build=$2\
            --host=$1\
            $4 \
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
            &> $LOGPRE/$BINUTILS_DIR-config.txt


	#		--disable-threads \
	#		--disable-ppl \
	#		--disable-cloog \

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building Binutils ($3)..."
        
        make all $JOBS &> $LOGPRE/$BINUTILS_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging Binutils ($3)..."
        
        make DESTDIR=$STAGE_BASE_DIR install-strip install-html &> $LOGPRE/$BINUTILS_DIR-pkg.txt
        
        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$BINUTILS_DIR.tbz2 .

            check_error $OBD/$BINUTILS_DIR/.make-pkg

            cd $OBD/$BINUTILS_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing Binutils ($3)..."
        
        tar -xjpf $PKG/$PROJECT-$1-$BINUTILS_DIR.tbz2 -C $INSTALL_BASE_DIR
        
        check_error .make-install
    fi

    echo -e "  >> Binutils ($3) Installed\n"
}

