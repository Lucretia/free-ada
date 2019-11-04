########################################################################################################################
# Filename    # python.inc
# Purpose     # Python 2.7
# Description # Required by AdaCore's packages.
# Copyright   # Copyright (C) 2011-2018 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
# $4 - Configure options
function python()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$1"
	DIRS="$PYTHON_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$PYTHON_DIR

    MAKEFILE=$SRC/$PYTHON_DIR/Makefile
    
    if [ ! -f .config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring Python ($3)..."

        $SRC/$PYTHON_DIR/configure \
            --prefix=$INSTALL_DIR \
            --without-pymalloc \
            --enable-shared &> $LOGPRE/$PYTHON_DIR-config.txt

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building Python ($3)..."
        
        check_error .make
        
        make $JOBS &> $LOGPRE/$PYTHON_DIR-make.txt

        check_error_exit
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging Python ($3)..."
        
        make DESTDIR=$STAGE_BASE_DIR altinstall &> $LOGPRE/$PYTHON_DIR-pkg.txt
        
        strip $STAGE_BASE_DIR$INSTALL_DIR/bin/python2.7

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$PYTHON_DIR.tbz2 .

            check_error $OBD/$PYTHON_DIR/.make-pkg

            cd $OBD/$PYTHON_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing Python ($3)..."
        
        tar -xjpf $PKG/$PROJECT-$1-$PYTHON_DIR.tbz2 -C $INSTALL_BASE_DIR
        
        check_error .make-install
    fi

    echo "  >> Python bootstrap ($3) Installed"
}
