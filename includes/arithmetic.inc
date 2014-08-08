################################################################################
# Filename    # artihmetic.inc
# Purpose     # Common arithmetic lib handling functions.
# Description #
# Copyright   # Copyright (C) 2011-2014 Luke A. Guest, David Rees.
#             # All Rights Reserved.
################################################################################

################################################################################
# Build the Arithmetic/Optimisation Libs
################################################################################

function build_arithmetic_libs()
{
	echo "  ( ) Start Processing GMP, MPFR, MPC, ISL, and CLooG"

	# Constants
	local TASK_COUNT_TOTAL=26
	VER="native"
	DIRS="gmp-$GMP_VERSION mpfr-$MPFR_VERSION mpc-$MPC_VERSION isl-$ISL_VERSION cloog-$CLOOG_VERSION"
	LOGPRE=$LOG/native
	OBD=$BLD/$VER

	#multiarch support on some distributions
        export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

	echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

	cd $BLD
	for d in $DIRS; do
	if [ ! -d $VER/$d ]; then
	    mkdir -p $VER/$d
	fi
	done

	# GMP ######################################################################


	cd $OBD/gmp-$GMP_VERSION

	if [ ! -f .config ]; then
		echo "  >> [2/$TASK_COUNT_TOTAL] Configuring GMP..."
		$SRC/gmp-$GMP_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--disable-shared \
		--enable-cxx \
		&> $LOGPRE-gmp-$GMP_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [3/$TASK_COUNT_TOTAL] Building GMP..."
		make $JOBS &> $LOGPRE-gmp-$GMP_VERSION-make.txt
		check_error .make
	fi

#	if [ ! -f $OBD/gmp-$GMP_VERSION/.tuned ]; then
#		echo "  >> [3/$TASK_COUNT_TOTAL] Generating tuneup metrics for GMP..."
#		cd $OBD/gmp-$GMP_VERSION/tune
#		make tuneup
		# generate better contents for the `gmp-mparam.h' parameter file
#		./tuneup > ../.tuned
#		cd ..
#	fi


	if [ ! -f .make-check ]; then
		echo "  >> [4/$TASK_COUNT_TOTAL] Logging GMP Check..."
		make check &> $LOGPRE-gmp-$GMP_VERSION-check.txt
		check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Packaging GMP..."
		make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-gmp-$GMP_VERSION-pkg.txt
		check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR
		    tar -cjpf $PKG/$PROJECT-$HOST-gmp-$GMP_VERSION.tbz2 .
		    check_error $OBD/gmp-$GMP_VERSION/.make-pkg

		    cd $OBD/gmp-$GMP_VERSION
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Installing GMP..."
		tar -xjpf $PKG/$PROJECT-$HOST-gmp-$GMP_VERSION.tbz2 -C $INSTALL_BASE_DIR
		check_error .make-install
	fi

        # MPFR #####################################################################

	cd $OBD/mpfr-$MPFR_VERSION

	if [ ! -f .config ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Configuring MPFR..."
		$SRC/mpfr-$MPFR_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--disable-shared \
                --with-gmp=$INSTALL_DIR \
		&> $LOGPRE-mpfr-$MPFR_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [8/$TASK_COUNT_TOTAL] Building MPFR..."
		make $JOBS &> $LOGPRE-mpfr-$MPFR_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [9/$TASK_COUNT_TOTAL] Logging MPFR Check..."
		make check &> $LOGPRE-mpfr-$MPFR_VERSION-check.txt
		check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [10/$TASK_COUNT_TOTAL] Packaging MPFR..."
		make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-mpfr-$MPFR_VERSION-pkg.txt
		check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR
		    tar -cjpf $PKG/$PROJECT-$HOST-mpfr-$MPFR_VERSION.tbz2 .
		    check_error $OBD/mpfr-$MPFR_VERSION/.make-pkg

		    cd $OBD/mpfr-$MPFR_VERSION
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [11/$TASK_COUNT_TOTAL] Installing MPFR..."
		tar -xjpf $PKG/$PROJECT-$HOST-mpfr-$MPFR_VERSION.tbz2 -C $INSTALL_BASE_DIR
		check_error .make-install
	fi

        # MPC ######################################################################

	cd $OBD/mpc-$MPC_VERSION

	if [ ! -f .config ]; then
		echo "  >> [12/$TASK_COUNT_TOTAL] Configuring MPC..."
		$SRC/mpc-$MPC_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--disable-shared \
                --with-mpfr=$INSTALL_DIR \
                --with-gmp=$INSTALL_DIR \
		&> $LOGPRE-mpc-$MPC_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [13/$TASK_COUNT_TOTAL] Building MPC..."
		make $JOBS &> $LOGPRE-mpc-$MPC_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [14/$TASK_COUNT_TOTAL] Logging MPC Check..."
		make check &> $LOGPRE-mpc-$MPC_VERSION-check.txt
		check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [15/$TASK_COUNT_TOTAL] Packaging MPC..."
		make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-mpc-$MPC_VERSION-pkg.txt
		check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR
		    tar -cjpf $PKG/$PROJECT-$HOST-mpc-$MPC_VERSION.tbz2 .
		    check_error $OBD/mpc-$MPC_VERSION/.make-pkg

		    cd $OBD/mpc-$MPC_VERSION
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [16/$TASK_COUNT_TOTAL] Installing MPC..."
		tar -xjpf $PKG/$PROJECT-$HOST-mpc-$MPC_VERSION.tbz2 -C $INSTALL_BASE_DIR
		check_error .make-install
	fi

	# ISL ######################################################################
	# http://www.kotnet.org/~skimo/isl/user.html#installation

	cd $OBD/isl-$ISL_VERSION

	if [ ! -f .config ]; then
		echo "  >> [17/$TASK_COUNT_TOTAL] Configuring ISL..."

		$SRC/isl-$ISL_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--disable-shared \
		--with-gmp-prefix=$INSTALL_DIR \
		&> $LOGPRE-isl-$ISL_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [18/$TASK_COUNT_TOTAL] Building ISL..."
		make $JOBS &> $LOGPRE-isl-$ISL_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [19/$TASK_COUNT_TOTAL] Logging ISL Check..."
		make check &> $LOGPRE-isl-$ISL_VERSION-check.txt
		check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [20/$TASK_COUNT_TOTAL] Packaging ISL..."
		make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-isl-$ISL_VERSION-pkg.txt
		check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR
		    tar -cjpf $PKG/$PROJECT-$HOST-isl-$ISL_VERSION.tbz2 .
		    check_error $OBD/isl-$ISL_VERSION/.make-pkg

		    cd $OBD/isl-$ISL_VERSION
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [21/$TASK_COUNT_TOTAL] Installing ISL..."
		tar -xjpf $PKG/$PROJECT-$HOST-isl-$ISL_VERSION.tbz2 -C $INSTALL_BASE_DIR
		check_error .make-install
	fi

	# Cloog ################################################################
	cd $OBD/cloog-$CLOOG_VERSION

#                --with-gmp=system \
#                --with-isl=system \
	if [ ! -f .config ]; then
		echo "  >> [22/$TASK_COUNT_TOTAL] Configuring CLooG..."
		$SRC/cloog-$CLOOG_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--disable-shared \
		--with-gmp-prefix=$INSTALL_DIR \
		--with-isl-prefix=$INSTALL_DIR \
                --with-bits=gmp \
		&> $LOGPRE-cloog-$CLOOG_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [23/$TASK_COUNT_TOTAL] Building CLooG..."
		make $JOBS &> $LOGPRE-cloog-$CLOOG_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [24/$TASK_COUNT_TOTAL] Logging CLooG Check..."
		make check &> $LOGPRE-cloog-$CLOOG_VERSION-check.txt
		check_error .make-check
	fi

	if [ ! -f .make-pkg-stage ]; then
		echo "  >> [25/$TASK_COUNT_TOTAL] Packaging CLooG..."
		make DESTDIR=$STAGE_BASE_DIR install &> $LOGPRE-cloog-$CLOOG_VERSION-pkg.txt
		check_error .make-pkg-stage

		if [ ! -f .make-pkg ]; then
		    cd $STAGE_DIR
		    tar -cjpf $PKG/$PROJECT-$HOST-cloog-$CLOOG_VERSION.tbz2 .
		    check_error $OBD/cloog-$CLOOG_VERSION/.make-pkg

		    cd $OBD/cloog-$CLOOG_VERSION
		    rm -rf /tmp/opt
		fi
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [26/$TASK_COUNT_TOTAL] Installing CLooG..."
		tar -xjpf $PKG/$PROJECT-$HOST-cloog-$CLOOG_VERSION.tbz2 -C $INSTALL_BASE_DIR
		check_error .make-install
	fi

#	export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"
#	export LD_LIBRARY_PATH="$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH"

	echo "  (x) Finished Processing GMP, MPFR, MPC, ISL and CLooG"
}
