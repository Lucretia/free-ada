################################################################################
# Filename    # artihmetic.inc
# Purpose     # Common arithmetic lib handling functions.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

################################################################################
# Build the Arithmetic/Optimisation Libs
################################################################################

function build_arithmetic_libs()
{
	echo "  ( ) Start Processing GMP, MPFR, MPC and ISL"

	# Constants
	local TASK_COUNT_TOTAL=21
	VER="$build_type/$TARGET"
	DIRS="$GMP_DIR $MPFR_DIR $MPC_DIR $ISL_DIR"
	LOGPRE=$LOG/$VER
	OBD=$BLD/$VER

	#multiarch support on some distributions
    #export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

	echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

	cd $BLD
    mkdir -p $LOGPRE
	for d in $DIRS; do
        if [ ! -d $VER/$d ]; then
            mkdir -p $VER/$d
        fi
	done

	# GMP ######################################################################


	cd $OBD/$GMP_DIR

	if [ ! -f .config ]; then
		echo "  >> [2/$TASK_COUNT_TOTAL] Configuring GMP..."

        $SRC/$GMP_DIR/configure \
            --prefix=$INSTALL_DIR \
            --disable-shared \
            --enable-cxx \
		&> $LOGPRE/$GMP_DIR-configure.txt

        check_error .config
	fi
    
	if [ ! -f .make ]; then
		echo "  >> [3/$TASK_COUNT_TOTAL] Building GMP..."

		make $JOBS &> $LOGPRE/$GMP_DIR-make.txt

        check_error .make
	fi

#	if [ ! -f $OBD/$GMP_DIR/.tuned ]; then
#		echo "  >> [3/$TASK_COUNT_TOTAL] Generating tuneup metrics for GMP..."
#		cd $OBD/gmp-$GMP_VERSION/tune
#		make tuneup
		# generate better contents for the `gmp-mparam.h' parameter file
#		./tuneup > ../.tuned
#		cd ..
#	fi


	if [ ! -f .make-check ]; then
		echo "  >> [4/$TASK_COUNT_TOTAL] Logging GMP Check..."

        make check &> $LOGPRE/$GMP_DIR-check.txt

        check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Packaging GMP..."

        make DESTDIR=$STAGE_BASE_DIR install-strip &> $LOGPRE/$GMP_DIR-pkg.txt

        check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$HOST-$GMP_DIR.tbz2 .

            check_error $OBD/$GMP_DIR/.make-pkg

		    cd $OBD/$GMP_DIR

		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Installing GMP..."

        tar -xjpf $PKG/$PROJECT-$HOST-$GMP_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
	fi

    # MPFR #####################################################################

	cd $OBD/$MPFR_DIR

	if [ ! -f .config ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Configuring MPFR..."

		$SRC/$MPFR_DIR/configure \
            --prefix=$INSTALL_DIR \
            --disable-shared \
            --with-gmp=$INSTALL_DIR \
		&> $LOGPRE/$MPFR_DIR-configure.txt

        check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [8/$TASK_COUNT_TOTAL] Building MPFR..."

        make $JOBS &> $LOGPRE/$MPFR_DIR-make.txt

        check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [9/$TASK_COUNT_TOTAL] Logging MPFR Check..."

        make check &> $LOGPRE/$MPFR_DIR-check.txt

        check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [10/$TASK_COUNT_TOTAL] Packaging MPFR..."

        make DESTDIR=$STAGE_BASE_DIR install-strip &> $LOGPRE/$MPFR_DIR-pkg.txt

        check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$HOST-$MPFR_DIR.tbz2 .

            check_error $OBD/$MPFR_DIR/.make-pkg

		    cd $OBD/$MPFR_DIR
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [11/$TASK_COUNT_TOTAL] Installing MPFR..."

        tar -xjpf $PKG/$PROJECT-$HOST-$MPFR_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
	fi

    # MPC ######################################################################

	cd $OBD/$MPC_DIR

	if [ ! -f .config ]; then
		echo "  >> [12/$TASK_COUNT_TOTAL] Configuring MPC..."

		$SRC/$MPC_DIR/configure \
            --prefix=$INSTALL_DIR \
            --disable-shared \
            --with-mpfr=$INSTALL_DIR \
            --with-gmp=$INSTALL_DIR \
		&> $LOGPRE/$MPC_DIR-configure.txt

        check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [13/$TASK_COUNT_TOTAL] Building MPC..."

        make $JOBS &> $LOGPRE/$MPC_DIR-make.txt

        check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [14/$TASK_COUNT_TOTAL] Logging MPC Check..."

        make check &> $LOGPRE/$MPC_DIR-check.txt

        check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [15/$TASK_COUNT_TOTAL] Packaging MPC..."

        make DESTDIR=$STAGE_BASE_DIR install-strip &> $LOGPRE/$MPC_DIR-pkg.txt

        check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$HOST-$MPC_DIR.tbz2 .
		    check_error $OBD/$MPC_DIR/.make-pkg

		    cd $OBD/$MPC_DIR
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [16/$TASK_COUNT_TOTAL] Installing MPC..."

        tar -xjpf $PKG/$PROJECT-$HOST-$MPC_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
	fi

	# ISL ######################################################################
	# http://www.kotnet.org/~skimo/isl/user.html#installation

	cd $OBD/$ISL_DIR

	if [ ! -f .config ]; then
		echo "  >> [17/$TASK_COUNT_TOTAL] Configuring ISL..."

		$SRC/$ISL_DIR/configure \
            --prefix=$INSTALL_DIR \
            --disable-shared \
            --with-gmp-prefix=$INSTALL_DIR \
		&> $LOGPRE/$ISL_DIR-configure.txt

        check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [18/$TASK_COUNT_TOTAL] Building ISL..."

        make $JOBS &> $LOGPRE/$ISL_DIR-make.txt

        check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [19/$TASK_COUNT_TOTAL] Logging ISL Check..."

        make check &> $LOGPRE/$ISL_DIR-check.txt

        check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [20/$TASK_COUNT_TOTAL] Packaging ISL..."

        make DESTDIR=$STAGE_BASE_DIR install-strip &> $LOGPRE/$ISL_DIR-pkg.txt

        check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR

            tar -cjpf $PKG/$PROJECT-$HOST-$ISL_DIR.tbz2 .

            check_error $OBD/$ISL_DIR/.make-pkg

		    cd $OBD/$ISL_DIR
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [21/$TASK_COUNT_TOTAL] Installing ISL..."

        tar -xjpf $PKG/$PROJECT-$HOST-$ISL_DIR.tbz2 -C $INSTALL_BASE_DIR

        check_error .make-install
	fi


#	export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"
#	export LD_LIBRARY_PATH="$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH"

    echo "  (x) Finished Processing GMP, MPFR, MPC and ISL"
}
