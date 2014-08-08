################################################################################
# Filename         # patch.inc
# Purpose          # Common patch handling functions.
# Description      #
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################

function apply_native_gcc_patches()
{
	# Patch gcc trunk sources
#	if [ $GCC_FROM_REPO = "y" ]; then

		cd $GCC_DIR

#		if [ ! -f .patched ]; then
#			local PATCHES="gnatvsn.patch"

#			echo "  >> Applying Patches to GNAT/GCC (Native)..."
#			for p in $PATCHES; do
#				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
#				check_error .patched
#			done
#		fi


	# Patching a gcc snapshot or release
#    else

		#cd $GCC_DIR

		#if [ ! -f .patched ]; then
			#local PATCHES="ada-symbolic-tracebacks.diff"
			#echo "  >> Patching GNAT/GCC (Native)..."

			#if [ $GCC_VERSION == "4.6.1" ]; then
			#
			#fi

			#for p in $PATCHES; do
			#	patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
			#done

			#	check_error .patched
		#fi

#	fi
}

function apply_cross_gcc_patches()
{
	# Patch gcc trunk source
	if [ $GCC_FROM_REPO = "y" ]; then

		cd $GCC_DIR
		local PATCHES="gcc-$GCC_VERSION.diff t-arm-elf.patch"
#		local PATCHES="gcc-4.6.1.diff t-arm-elf.patch"

		if [ ! -f .patched ]; then
			echo "  >> Applying Patches to GNAT/GCC Cross..."
			for p in $PATCHES; do
				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
				check_error .patched
			done
		fi
	# Patch gcc snapshots or releases
	else

		cd $GCC_DIR
		local PATCHES="gcc-$GCC_VERSION.diff"

		if [ ! -f .patched ]; then
			echo "  >> Applying Patches to GNAT/GCC Cross..."
			for p in $PATCHES; do
				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
				check_error .patched
			done
		fi
	fi
}

function reverse_patches()
{
	echo "  >> Reversing patches that were previously applied to src/gcc"
	cat $TOP/patches/gcc-$GCC_VERSION/* | patch -p1 -s -t -d $GCC_DIR -i -;
	rm -f $GCC_DIR/.patched;
}
