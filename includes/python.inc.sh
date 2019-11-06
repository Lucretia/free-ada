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

function install_python_packages()
{
	local TASK_COUNT_TOTAL=8
 	VER="$build_type/$1"
	DIRS="python-pkgs"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$DIRS

    echo "  >> Downloading required Python packages..."

    if [ ! -f get-pip.py ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Downloading get-pip.py..."

        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py &> $LOGPRE/$DIRS-pip-download.txt

        check_error_exit
    fi

    if [ ! -f .installed-pip ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Packaging PIP..."

        python2.7 get-pip.py &> $LOGPRE/$DIRS-pip-install.txt

        check_error .installed-pip
    fi

    if [ ! -f .installed-mako ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging Mako..."

        pip2.7 install mako &> $LOGPRE/$DIRS-mako-install.txt

        check_error .installed-mako
    fi

    if [ ! -f .installed-pyyaml ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Packaging PyYAML..."

        pip2.7 install pyyaml &> $LOGPRE/$DIRS-pyyaml-install.txt

        check_error .installed-pyyaml
    fi

    if [ ! -f .installed-enum ]; then
        echo "  >> [5/$TASK_COUNT_TOTAL] Packaging Enum..."

        pip2.7 install enum &> $LOGPRE/$DIRS-enum-install.txt

        check_error .installed-enum
    fi

    if [ ! -f .installed-enum34 ]; then
        echo "  >> [6/$TASK_COUNT_TOTAL] Packaging Enum34..."

        pip2.7 install enum34 &> $LOGPRE/$DIRS-enum34-install.txt

        check_error .installed-enum34
    fi

    if [ ! -f .installed-funcy ]; then
        echo "  >> [7/$TASK_COUNT_TOTAL] Packaging Funcy..."

        pip2.7 install funcy &> $LOGPRE/$DIRS-funcy-install.txt

        check_error .installed-funcy
    fi

    if [ ! -f .installed-docutils ]; then
        echo "  >> [8/$TASK_COUNT_TOTAL] Packaging DocUtils..."

        pip2.7 install docutils &> $LOGPRE/$DIRS-docutils-install.txt

        check_error .installed-docutils
    fi

    echo "  >> Python packages Installed"
}