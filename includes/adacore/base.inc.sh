########################################################################################################################
# Filename    # adacore/base.inc
# Purpose     # AdaCore base packages, GPRBuild, XMLAda, GNATColl, AWS.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################

# $1 - Host triple
function gpr_bootstrap()
{
	local TASK_COUNT_TOTAL=1
 	VER="$build_type/$1"
	DIRS="$GPRBUILD_DIR-strap"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$GPRBUILD_DIR-strap

    if [ ! -f .gprbuild_strap ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building and installing GPRBuild bootstrap ($1)..."
        
        $SRC/$GPRBUILD_DIR/bootstrap.sh --srcdir=$SRC/$GPRBUILD_DIR --with-xmlada=$SRC/$XMLADA_DIR --prefix=$INSTALL_DIR &> $LOGPRE/$GPRBUILD_DIR-strap.txt

        check_error .gprbuild_strap
    fi

    echo "  >> GPRBuild bootstrap ($1) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function xmlada()
{
	local TASK_COUNT_TOTAL=5
 	VER="$build_type/$3"
	#DIRS="$XMLADA_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $OBD

    if [ ! -f .xmlada-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying XMLAda due to broken configure script ($3)..."

        cp -Ra $SRC/$XMLADA_DIR .

        check_error .xmlada-copied
    fi

    cd $OBD/$XMLADA_DIR

    if [ ! -f .config ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Configuring XMLAda ($3)..."
        # Hack around the prefix as xmlada doesn't support DESTDIR.
        ./configure \
            --prefix=$STAGE_BASE_DIR$INSTALL_DIR \
            --enable-shared \
            --target=$3 \
            --build=$2\
            --host=$1\
            &> $LOGPRE/$XMLADA_DIR-config.txt

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Building XMLAda ($3)..."
        
        make all $JOBS &> $LOGPRE/$XMLADA_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Packaging XMLAda ($3)..."
        
        make install &> $LOGPRE/$XMLADA_DIR-pkg.txt

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$XMLADA_DIR.tbz2 .

            check_error $OBD/$XMLADA_DIR/.make-pkg

            cd $OBD/$XMLADA_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [5/$TASK_COUNT_TOTAL] Installing XMLAda (Native)..."

        tar -xjpf $PKG/$PROJECT-$1-$XMLADA_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> XMLAda (Native) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function build_gprbuild()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$3"
	DIRS="$GPRBUILD_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$GPRBUILD_DIR

    MAKEFILE=$SRC/$GPRBUILD_DIR/Makefile
    
    if [ ! -f .config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring GPRBuild ($3)..."

        # Taken from Arch.
        # Make using a single job (-j1) to avoid the same file being compiled at the same time.
        make -f $MAKEFILE \
            -j1 \
            prefix=$INSTALL_DIR \
            SOURCE_DIR=$SRC/$GPRBUILD_DIR \
            ENABLE_SHARED="yes" \
            BUILD=production \
            TARGET=$3 \
            setup &> $LOGPRE/$GPRBUILD_DIR-config.txt

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GPRBuild ($3)..."
        
        make -f $MAKEFILE \
            -j1 \
            BUILD=production \
            GPRBUILD_OPTIONS=-R \
            all libgpr.build &> $LOGPRE/$GPRBUILD_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging GPRBuild ($3)..."
        
        LD_LIBRARY_PATH=$(pwd)/gpr/lib/production/relocatable:$LD_LIBRARY_PATH \
            make -f $MAKEFILE \
                prefix=$STAGE_BASE_DIR$INSTALL_DIR \
                -j1 \
                BUILD=production \
                install libgpr.install &> $LOGPRE/$GPRBUILD_DIR-pkg.txt

        rm $STAGE_BASE_DIR$INSTALL_DIR/doinstall

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$GPRBUILD_DIR.tbz2 .

            check_error $OBD/$GPRBUILD_DIR/.make-pkg

            cd $OBD/$GPRBUILD_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing GPRBuild ($3)..."
        
        tar -xjpf $PKG/$PROJECT-$1-$GPRBUILD_DIR.tbz2 -C $INSTALL_BASE_DIR
        
        check_error .make-install
    fi

    echo "  >> GPRBuild ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_core()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$3"
	DIRS="$GNATCOLL_CORE_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/$GNATCOLL_CORE_DIR

    if [ ! -f .config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring GNATColl-Core ($3)..."

        make -f $SRC/$GNATCOLL_CORE_DIR/Makefile prefix=$STAGE_BASE_DIR$INSTALL_DIR PROCESSORS=${JOBS_NUM} setup
            &> $LOGPRE/$GNATCOLL_CORE_DIR-config.txt

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-Core ($3)..."

        make -f $SRC/$GNATCOLL_CORE_DIR/Makefile &> $LOGPRE/$GNATCOLL_CORE_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging GNATColl-Core ($3)..."

        make -f $SRC/$GNATCOLL_CORE_DIR/Makefile install &> $LOGPRE/$GNATCOLL_CORE_DIR-pkg.txt

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_CORE_DIR.tbz2 .

            check_error $OBD/$GNATCOLL_CORE_DIR/.make-pkg

            cd $OBD/$GNATCOLL_CORE_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing GNATColl-Core ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_CORE_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> GNATColl-Core ($3) Installed"
}

# TODO: Look into installing all versions, but they overwrite the ali files, where there is a difference, i.e. extra -fPIC flag.

# $1 - Env vars
# $2 - GPR file
# $3 - Linker flags
# $4 - Name
function gnatcoll_build_component()
{
    if [ ! -z ${3} ]; then
        GNATCOLL_LINKER_FLAGS="-largs ${3}"
    else
        GNATCOLL_LINKER_FLAGS=""
    fi

    # declare -a BUILD_TYPES="static static-pic relocatable"
    declare -a BUILD_TYPES="relocatable"

    for gc_type in ${BUILD_TYPES[@]}; do
        gprbuild -P ${2} -XBUILD=PROD -XLIBRARY_TYPE=${gc_type} -p ${GNATCOLL_LINKER_FLAGS} &> ${LOGPRE}/${4}-${gc_type}-make.txt
    done
}

# $1 - Prefix
# $2 - GPR file
# $3 - Name
function gnatcoll_install_component()
{
    # declare -a BUILD_TYPES="static static-pic relocatable"
    declare -a BUILD_TYPES="relocatable"

    for gc_type in ${BUILD_TYPES[@]}; do
        gprinstall -f --prefix=${1} -P ${2} -XBUILD=PROD -XLIBRARY_TYPE=${gc_type} -p &> ${LOGPRE}/${3}-${gc_type}-pkg.txt
    done
}

# TODO - Add host / build /target
# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_bindings()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    # TODO: Another broken configure script requires copying this into the build dir.
    cd $OBD

    if [ ! -f .gnatcoll-bindings-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying GNATColl-Bindings due to broken GPR file ($3)..."

        cp -Ra $SRC/$GNATCOLL_BINDINGS_DIR .

        check_error .gnatcoll-bindings-copied
    fi

    cd $OBD/$GNATCOLL_BINDINGS_DIR

    # The make stage
    echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-Bindings ($3)..."

    if [ ${GNATCOLL_BINDINGS_GMP} == "y" ]; then
        if [ ! -f .make-gmp ]; then
            echo "  >> [2.1/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - GMP ($3)..."

            gnatcoll_build_component "" "gmp/gnatcoll_gmp.gpr" "" "${GNATCOLL_BINDINGS_DIR}-gmp"

            check_error .make-gmp
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_ICONV} == "y" ]; then
        if [ ! -f .make-iconv ]; then
            echo "  >> [2.2/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - IConv ($3)..."

            gnatcoll_build_component "" "iconv/gnatcoll_iconv.gpr" "" "${GNATCOLL_BINDINGS_DIR}-iconv"

            check_error .make-iconv
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_LZMA} == "y" ]; then
        if [ ! -f .make-lzma ]; then
            echo "  >> [2.3/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - LZMA ($3)..."

            gnatcoll_build_component "" "lzma/gnatcoll_lzma.gpr" "" "${GNATCOLL_BINDINGS_DIR}-lzma"

            check_error .make-lzma
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_OMP} == "y" ]; then
        if [ ! -f .make-omp ]; then
            echo "  >> [2.4/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - OMP ($3)..."

            gnatcoll_build_component "" "omp/gnatcoll_omp.gpr" "" "${GNATCOLL_BINDINGS_DIR}-omp"

            check_error .make-omp
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_PYTHON} == "y" ]; then
        if [ ! -f .make-python ]; then
            echo "  >> [2.5/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - Python ($3)..."

            export GNATCOLL_PYTHON_CFLAGS=$(python2.7-config --includes)
            export Python_Libs="-L$(python2.7-config --prefix)/lib $(python2.7-config --libs)"

            gnatcoll_build_component \
                "" "python/gnatcoll_python.gpr" "" "${GNATCOLL_BINDINGS_DIR}-python"

            check_error .make-python

            unset GNATCOLL_PYTHON_CFLAGS
            unset Python_Libs
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_READLINE} == "y" ]; then
        if [ ! -f .make-readline ]; then
            echo "  >> [2.6/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - Readline ($3)..."

            gnatcoll_build_component "" "readline/gnatcoll_readline.gpr" "" "${GNATCOLL_BINDINGS_DIR}-readline"

            check_error .make-readline
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_SYSLOG} == "y" ]; then
        if [ ! -f .make-syslog ]; then
            echo "  >> [2.7/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - SysLog ($3)..."

            gnatcoll_build_component "" "syslog/gnatcoll_syslog.gpr" "" "${GNATCOLL_BINDINGS_DIR}-syslog"

            check_error .make-syslog
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_ZLIB} == "y" ]; then
        if [ ! -f .make-zlib ]; then
            echo "  >> [2.8/$TASK_COUNT_TOTAL] Building GNATColl-Bindings - ZLib ($3)..."

            gnatcoll_build_component "" "zlib/gnatcoll_zlib.gpr" "" "${GNATCOLL_BINDINGS_DIR}-zlib"

            check_error .make-zlib
        fi
    fi

    # Staging area.
    echo "  >> [3/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings ($3)..."

    if [ ${GNATCOLL_BINDINGS_GMP} == "y" ]; then
        if [ ! -f .make-pkg-stage-gmp ]; then
            echo "  >> [2.1/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - GMP ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "gmp/gnatcoll_gmp.gpr" "${GNATCOLL_BINDINGS_DIR}-gmp"

            check_error .make-pkg-stage-gmp
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_ICONV} == "y" ]; then
        if [ ! -f .make-pkg-stage-iconv ]; then
            echo "  >> [2.2/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - IConv ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "iconv/gnatcoll_iconv.gpr" "${GNATCOLL_BINDINGS_DIR}-iconv"

            check_error .make-pkg-stage-iconv
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_LZMA} == "y" ]; then
        if [ ! -f .make-pkg-stage-lzma ]; then
            echo "  >> [2.3/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - LZMA ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "lzma/gnatcoll_lzma.gpr" "${GNATCOLL_BINDINGS_DIR}-lzma"

            check_error .make-pkg-stage-lzma
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_OMP} == "y" ]; then
        if [ ! -f .make-pkg-stage-omp ]; then
            echo "  >> [2.4/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - OMP ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "omp/gnatcoll_omp.gpr" "${GNATCOLL_BINDINGS_DIR}-omp"

            check_error .make-pkg-stage-omp
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_PYTHON} == "y" ]; then
        if [ ! -f .make-pkg-stage-python ]; then
            echo "  >> [2.5/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - Python ($3)..."

            gnatcoll_build_component "$STAGE_BASE_DIR$INSTALL_DIR" "python/gnatcoll_python.gpr" "${GNATCOLL_BINDINGS_DIR}-python"

            check_error .make-pkg-stage-python
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_READLINE} == "y" ]; then
        if [ ! -f .make-pkg-stage-readline ]; then
            echo "  >> [2.6/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - Readline ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "readline/gnatcoll_readline.gpr" "${GNATCOLL_BINDINGS_DIR}-readline"

            check_error .make-pkg-stage-readline
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_SYSLOG} == "y" ]; then
        if [ ! -f .make-pkg-stage-syslog ]; then
            echo "  >> [2.7/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - SysLog ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "syslog/gnatcoll_syslog.gpr" "${GNATCOLL_BINDINGS_DIR}-syslog"

            check_error .make-pkg-stage-syslog
        fi
    fi

    if [ ${GNATCOLL_BINDINGS_ZLIB} == "y" ]; then
        if [ ! -f .make-pkg-stage-zlib ]; then
            echo "  >> [2.8/$TASK_COUNT_TOTAL] Packaging GNATColl-Bindings - ZLib ($3)..."

            gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "zlib/gnatcoll_zlib.gpr" "${GNATCOLL_BINDINGS_DIR}-zlib"

            check_error .make-pkg-stage-zlib
        fi
    fi

    if [ ! -f .make-pkg ]; then
        cd $STAGE_DIR

        tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_BINDINGS_DIR.tbz2 .

        check_error $OBD/$GNATCOLL_BINDINGS_DIR/.make-pkg

        cd $OBD/$GNATCOLL_BINDINGS_DIR
        rm -rf /tmp/opt
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing GNATColl-Bindings ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_BINDINGS_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> GNATColl-Bindings ($3) Installed"
}

function gnatcoll_db()
{
	local TASK_COUNT_TOTAL=1

    # TODO: Another broken configure script requires copying this into the build dir.
    cd $OBD

    if [ ! -f .gnatcoll-db-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying GNATColl-DB due to broken GPR file..."

        cp -Ra $SRC/$GNATCOLL_DB_DIR .

        check_error .gnatcoll-db-copied
    fi
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_sql()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-sql ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - SQL ($3)..."

        gnatcoll_build_component "" "sql/gnatcoll_sql.gpr" "" "${GNATCOLL_DB_DIR}-sql"

        check_error .make-sql
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-sql ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Packaging GNATColl-DB - SQL ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "sql/gnatcoll_sql.gpr" "${GNATCOLL_DB_DIR}-sql"

        check_error .make-pkg-stage-sql

        if [ ! -f .make-pkg-sql ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sql.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-sql

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-sql ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - SQL ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sql.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-sql
    fi

    echo "  >> GNATColl-DB - SQL ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_sqlite()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-sqlite ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - SQLite ($3)..."

        gnatcoll_build_component "" "sqlite/gnatcoll_sqlite.gpr" "" "${GNATCOLL_DB_DIR}-sqlite"

        check_error .make-sqlite
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-sqlite ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Packaging GNATColl-DB - SQLite ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "sqlite/gnatcoll_sqlite.gpr" "${GNATCOLL_DB_DIR}-sqlite"

        check_error .make-pkg-stage-sqlite

        if [ ! -f .make-pkg-sqlite ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sqlite.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-sqlite

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-sqlite ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - SQLite ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sqlite.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-sqlite
    fi

    echo "  >> GNATColl-DB - SQLite ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_postgres()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-postgres ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - Postgres ($3)..."

        gnatcoll_build_component "" "postgres/gnatcoll_postgres.gpr" "" "${GNATCOLL_DB_DIR}-postgres"

        check_error .make-postgres
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-postgres ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Packaging GNATColl-DB - Postgres ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "postgres/gnatcoll_postgres.gpr" "${GNATCOLL_DB_DIR}-postgres"

        check_error .make-pkg-stage-postgres

        if [ ! -f .make-pkg-postgres ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-postgres.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-postgres

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-postgres ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - Postgres ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-postgres.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-postgres
    fi

    echo "  >> GNATColl-DB - Postgres ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_db2ada()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-db2ada ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - DB2Ada ($3)..."

        gnatcoll_build_component "" "gnatcoll_db2ada/gnatcoll_db2ada.gpr" "-ldl" "${GNATCOLL_DB_DIR}-db2ada"

        check_error .make-db2ada
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-db2ada ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Packaging GNATColl-DB - DB2Ada ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "gnatcoll_db2ada/gnatcoll_db2ada.gpr" "${GNATCOLL_DB_DIR}-db2ada"

        check_error .make-pkg-stage-db2ada

        if [ ! -f .make-pkg-db2ada ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-db2ada.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-db2ada

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - DB2Ada ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-db2ada.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-db2ada
    fi

    echo "  >> GNATColl-DB - DB2Ada ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_sqlite2ada()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-sqlite2ada ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - SQLite2Ada ($3)..."

        gnatcoll_build_component "" "gnatcoll_db2ada/gnatcoll_sqlite2ada.gpr" "-ldl" "${GNATCOLL_DB_DIR}-sqlite2ada"

        check_error .make-sqlite2ada
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-sqlite2ada ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-DB - SQLite2Ada ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "gnatcoll_db2ada/gnatcoll_sqlite2ada.gpr" "${GNATCOLL_DB_DIR}-sqlite2ada"

        check_error .make-pkg-stage-sqlite2ada

        if [ ! -f .make-pkg-sqlite2ada ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sqlite2ada.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-sqlite2ada

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-sqlite2ada ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - SQLite2Ada ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-sqlite2ada.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-sqlite2ada
    fi

    echo "  >> GNATColl-DB - SQLite2Ada ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_postgres2ada()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-postgres2ada ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - Postgres2Ada ($3)..."

        gnatcoll_build_component "" "gnatcoll_db2ada/gnatcoll_postgres2ada.gpr" "-ldl" "${GNATCOLL_DB_DIR}-postgres2ada"

        check_error .make-postgres2ada
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-postgres2ada ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-DB - Postgres2Ada ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "gnatcoll_db2ada/gnatcoll_postgres2ada.gpr" "${GNATCOLL_DB_DIR}-postgres2ada"

        check_error .make-pkg-stage-postgres2ada

        if [ ! -f .make-pkg-postgres2ada ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-postgres2ada.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-postgres2ada

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-postgres2ada ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - Postgres2Ada ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-postgres2ada.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-postgres2ada
    fi

    echo "  >> GNATColl-DB - Postgres2Ada ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_xref()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-xref ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - XRef ($3)..."

        gnatcoll_build_component "" "xref/gnatcoll_xref.gpr" "" "${GNATCOLL_DB_DIR}-xref"

        check_error .make-xref
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-xref ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-DB - XRef ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "xref/gnatcoll_xref.gpr" "${GNATCOLL_DB_DIR}-xref"

        check_error .make-pkg-stage-xref

        if [ ! -f .make-pkg-xref ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-xref.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-xref

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-xref ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - XRef ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-xref.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-xref
    fi

    echo "  >> GNATColl-DB - XRef ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnatcoll_db_gnatinspect()
{
	local TASK_COUNT_TOTAL=3
 	VER="$build_type/$3"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    cd $OBD/$GNATCOLL_DB_DIR

    # The make stage
    if [ ! -f .make-gnatinspect ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Building GNATColl-DB - GNATInspect ($3)..."

        gnatcoll_build_component "" "gnatinspect/gnatinspect.gpr" "-ldl" "${GNATCOLL_DB_DIR}-gnatinspect"

        check_error .make-gnatinspect
    fi

    # Staging area.
    if [ ! -f .make-pkg-stage-gnatinspect ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building GNATColl-DB - GNATInspect ($3)..."

        gnatcoll_install_component "$STAGE_BASE_DIR$INSTALL_DIR" "gnatinspect/gnatinspect.gpr" "${GNATCOLL_DB_DIR}-gnatinspect"

        check_error .make-pkg-stage-gnatinspect

        if [ ! -f .make-pkg-gnatinspect ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-gnatinspect.tbz2 .

            check_error $OBD/$GNATCOLL_DB_DIR/.make-pkg-gnatinspect

            cd $OBD/$GNATCOLL_DB_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install-gnatinspect ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Installing GNATColl-DB - GNATInspect ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNATCOLL_DB_DIR-gnatinspect.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install-gnatinspect
    fi

    echo "  >> GNATColl-DB - GNATInspect ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function langkit()
{
	local TASK_COUNT_TOTAL=4
    VER="$build_type/$3"
	DIRS="$LANGKIT_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    export PYTHONPATH=$SRC/$LANGKIT_DIR

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD #/$LANGKIT_DIR

    if [ ! -f $LANGKIT_DIR/.config ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Configuring LangKit ($3)..."

        # Taken from Arch.
        python2.7 $SRC/$LANGKIT_DIR/scripts/build-langkit_support.py \
            --build-dir $LANGKIT_DIR \
            generate &> $LOGPRE/$LANGKIT_DIR-config.txt

        check_error $LANGKIT_DIR/.config
    fi

    if [ ! -f $LANGKIT_DIR/.make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building LangKit ($3)..."

        python2.7 $SRC/$LANGKIT_DIR/scripts/build-langkit_support.py \
            --library-types relocatable \
            --build-dir $LANGKIT_DIR \
            build \
            --build-mode=prod --gargs="-R" \
                &> $LOGPRE/$LANGKIT_DIR-make.txt

        check_error $LANGKIT_DIR/.make
    fi

    if [ ! -f $LANGKIT_DIR/.make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging LangKit ($3)..."

        python2.7 $SRC/$LANGKIT_DIR/setup.py install --prefix=$STAGE_BASE_DIR$INSTALL_DIR  &> $LOGPRE/$LANGKIT_DIR-pkg.txt

        check_error $LANGKIT_DIR/.make-pkg-stage1

        python2.7 $SRC/$LANGKIT_DIR/scripts/build-langkit_support.py \
            --library-types relocatable \
            --build-dir $LANGKIT_DIR \
            install $STAGE_BASE_DIR$INSTALL_DIR \
                >>$LOGPRE/$LANGKIT_DIR-pkg.txt 2>&1

        check_error $LANGKIT_DIR/.make-pkg-stage2

        sed -i 's@/usr/lib/python-exec/python2.7/python2@'"$INSTALL_DIR"'/bin/python2.7@' $STAGE_BASE_DIR$INSTALL_DIR/bin/create-project.py

        check_error $LANGKIT_DIR/.make-pkg-stage

        if [ ! -f $LANGKIT_DIR/.make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$LANGKIT_DIR.tbz2 .

            check_error $OBD/$LANGKIT_DIR/.make-pkg

            cd $OBD/$LANGKIT_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing LangKit ($3)..."

        tar -xjpf $PKG/$PROJECT-$1-$LANGKIT_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> LangKit ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function libadalang()
{
	local TASK_COUNT_TOTAL=5
 	VER="$build_type/$3"
	#DIRS="$LIBADALANG_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $OBD

    if [ ! -f .libadalang-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying LibAdaLang due to not being able to specify a build directory ($3)..."

        cp -Ra $SRC/$LIBADALANG_DIR .

        check_error .libadalang-copied
    fi

    cd $OBD/$LIBADALANG_DIR

    if [ ! -f .config ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Configuring LibAdaLang ($3)..."

        gprconfig -o config.cgpr --batch --config=c,,,,GCC --config=ada,,,, &> $LOGPRE/$LIBADALANG_DIR-config.txt

        check_error .config
    fi

    if [ ! -f .make ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Building LibAdaLang ($3)..."

        python2.7 ada/manage.py --no-langkit-support generate --no-pretty-print &> $LOGPRE/$LIBADALANG_DIR-make-generate.txt

        check_error .make-generate
        
        python2.7 ada/manage.py --library-types relocatable --no-langkit-support build --build-mode=prod --gargs="-R --config=$PWD/config.cgpr" \
            &> $LOGPRE/$LIBADALANG_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Packaging LibAdaLang ($3)..."

        python2.7 ada/manage.py --library-types relocatable --no-langkit-support install $STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE/$LIBADALANG_DIR-pkg.txt

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$LIBADALANG_DIR.tbz2 .

            check_error $OBD/$LIBADALANG_DIR/.make-pkg

            cd $OBD/$LIBADALANG_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [5/$TASK_COUNT_TOTAL] Installing LibAdaLang ($3)..."

        tar -xjpf $PKG/$PROJECT-$1-$LIBADALANG_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> LibAdaLang ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function libadalang_tools()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$3"
	#DIRS="$LIBADALANG_TOOLS_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $OBD

    if [ ! -f .libadalang-tools-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying LibAdaLang due to not being able to specify a build directory ($3)..."

        cp -Ra $SRC/$LIBADALANG_TOOLS_DIR .

        check_error .libadalang-tools-copied
    fi

    cd $OBD/$LIBADALANG_TOOLS_DIR

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building LibAdaLang Tools ($3)..."

        make BUILD_MODE=prod LIBRARY_TYPE=relocatable PROCESSORS=${JOBS_NUM} &> $LOGPRE/$LIBADALANG_TOOLS_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging LibAdaLang Tools ($3)..."

        mkdir -p $STAGE_BASE_DIR$INSTALL_DIR/bin

        for program in gnatpp gnatmetric gnatstub
        do
            install -m755 bin/$program "$STAGE_BASE_DIR$INSTALL_DIR/bin/"
        done

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$LIBADALANG_TOOLS_DIR.tbz2 .

            check_error $OBD/$LIBADALANG_TOOLS_DIR/.make-pkg

            cd $OBD/$LIBADALANG_TOOLS_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing LibAdaLang Tools ($3)..."

        tar -xjpf $PKG/$PROJECT-$1-$LIBADALANG_TOOLS_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> LibAdaLang Tools ($3) Installed"
}

# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function aunit()
{
	local TASK_COUNT_TOTAL=4
 	VER="$build_type/$3"
	#DIRS="$AUNIT_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $OBD

    if [ ! -f .aunit-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying AUnit due to broken Makefile ($3)..."

        cp -Ra $SRC/$AUNIT_DIR .

        check_error .aunit-copied
    fi

    cd $OBD/$AUNIT_DIR

    if [ ! -f .make ]; then
        echo "  >> [2/$TASK_COUNT_TOTAL] Building AUnit ($3)..."
        
        make all $JOBS &> $LOGPRE/$AUNIT_DIR-make.txt

        check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
        echo "  >> [3/$TASK_COUNT_TOTAL] Packaging AUnit ($3)..."
        
        # Easier than patching the makefile.
        gprinstall -p -f --prefix=$STAGE_BASE_DIR$INSTALL_DIR -XMODE=Install -XRUNTIME=full -XPLATFORM=native --no-build-var \
            lib/gnat/aunit.gpr &> $LOGPRE/$AUNIT_DIR-pkg.txt

        check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1-$AUNIT_DIR.tbz2 .

            check_error $OBD/$AUNIT_DIR/.make-pkg

            cd $OBD/$AUNIT_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [4/$TASK_COUNT_TOTAL] Installing AUnit ($3)..."

        tar -xjpf $PKG/$PROJECT-$1-$AUNIT_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> AUnit ($3) Installed"
}


################################################################################
# This function builds a version of libgnat_util using AdaCore's GPL'd
# makefiles, but uses the source from the FSF GNAT we are using. The source has
# to match the compiler.
#
# This library is used by the other AdaCore tools.
#
# This is only used in 2016 tools, from 2017, it's gone.
################################################################################
# TODO: Cross builds!
# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function gnat_util()
{
	local TASK_COUNT_TOTAL=5
 	VER="$build_type/$3"
	DIRS="$GNAT_UTIL_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/

    if [ ! -f .gnat_util-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying GNAT_Util sources ($3)..."

        cp -Ra $SRC/$GNAT_UTIL_DIR/* $GNAT_UTIL_DIR/

        check_error .gnat_util-copied
    fi

    cd $OBD/$GNAT_UTIL_DIR

    if [ ! -f .sources-copied ]; then
	echo "  >> [2/$TASK_COUNT_TOTAL] Copying FSF GCC sources for GNAT_Util ($3)..."

	for file in $(cat $SRC/$GNAT_UTIL_DIR/MANIFEST.gnat_util); do cp $SRC/$GCC_DIR/gcc/ada/"$file" .; done

	check_error .sources-copied
    fi

    if [ ! -f .gen-sources-copied ]; then
	echo "  >> [3/$TASK_COUNT_TOTAL] Copying FSF GCC generated sources for GNAT_Util ($3)..."

	cp $OBD/$GCC_DIR/gcc/ada/sdefault.adb .

	check_error .gen-sources-copied
    fi

    if [ ! -f .make ]; then
	echo "  >> [4/$TASK_COUNT_TOTAL] Building GNAT_Util ($3)..."

	# WARNING! This will not build in parallel mode.
	make -f Makefile ENABLE_SHARED=yes &> $LOGPRE/$GNAT_UTIL_DIR-make.txt

	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
    	echo "  >> [5/$TASK_COUNT_TOTAL] Packaging GNAT_Util ($3)..."

    	make -f Makefile install prefix=$STAGE_BASE_DIR$INSTALL_DIR ENABLE_SHARED=yes &> $LOGPRE/$GNAT_UTIL_DIR-pkg.txt

    	check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$GNAT_UTIL_DIR.tbz2 .

            check_error $OBD/$GNAT_UTIL_DIR/.make-pkg

            cd $OBD/$GNAT_UTIL_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [6/$TASK_COUNT_TOTAL] Installing GNAT_Util ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$GNAT_UTIL_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> GNAT_Util ($3) Installed"
}


# $1 - Host triple
# $2 - Build triple
# $3 - Target triple
function asis()
{
	local TASK_COUNT_TOTAL=5
 	VER="$build_type/$3"
	DIRS="$ASIS_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

    echo "  >> Creating Directories (if needed)..."

    cd $BLD
    for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
    done

    cd $OBD/

    if [ ! -f .asis-copied ]; then
        echo "  >> [1/$TASK_COUNT_TOTAL] Copying ASIS (${ASIS_GPL_YEAR}) sources ($3)..."

        cp -Ra $SRC/$ASIS_DIR/* $ASIS_DIR/

        check_error .asis-copied
    fi

    cd $OBD/$ASIS_DIR

    if [ ! -f .patched ]; then
	echo "  >> [2/$TASK_COUNT_TOTAL] Patching ASIS (${ASIS_GPL_YEAR}) sources ($3)..."

	for f in $(cat $FILES/asis_${ASIS_GPL_YEAR}/MANIFEST); do
	    echo "    >> Applying $f..."

	    patch -p1 < $FILES/asis_${ASIS_GPL_YEAR}/$f;
	done

	check_error .patched
    fi

    if [ ! -f .make ]; then
	echo "  >> [3/$TASK_COUNT_TOTAL] Building ASIS (${ASIS_GPL_YEAR}) ($3)..."

	# WARNING! This will not pass the parallel option to gprbuild.
	make all tools &> $LOGPRE/$ASIS_DIR-make.txt

	check_error .make
    fi

    if [ ! -f .make-pkg-stage ]; then
    	echo "  >> [4/$TASK_COUNT_TOTAL] Packaging ASIS (${ASIS_GPL_YEAR}) ($3)..."

    	make install install-tools prefix=$STAGE_BASE_DIR$INSTALL_DIR &> $LOGPRE/$ASIS_DIR-pkg.txt

    	check_error .make-pkg-stage

        if [ ! -f .make-pkg ]; then
            cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$1_$2_$3-$ASIS_DIR.tbz2 .

            check_error $OBD/$ASIS_DIR/.make-pkg

            cd $OBD/$ASIS_DIR
            rm -rf /tmp/opt
        fi
    fi

    if [ ! -f .make-install ]; then
        echo "  >> [5/$TASK_COUNT_TOTAL] Installing ASIS (${ASIS_GPL_YEAR}) ($3)..."

        tar -xjpf $PKG/$PROJECT-$1_$2_$3-$ASIS_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
    fi

    echo "  >> ASIS (${ASIS_GPL_YEAR}) ($3) Installed"
}

