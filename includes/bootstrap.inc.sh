########################################################################################################################
# Filename    # bootstrap.inc
# Purpose     # Download and install the bootstrap compiler if required.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################
function is_bootstrap_required()
{
    command -v gnat >/dev/null 2>&1 || return 1
}

function bootstrap_download()
{
    if [ is_bootstrap_required ]; then
        local PKG_CPU=$(echo $(uname -m) | tr [:lower:] [:upper:])
        local PKG_OS=$(echo $(uname) | tr [:lower:] [:upper:])
        local PKG_PREFIX=${PKG_CPU}_${PKG_OS}
        local PKG="${PKG_PREFIX}_BOOTSTRAP_TARBALL"
        local PKG_NAME="${PKG_PREFIX}_BOOTSTRAP_TARBALL_NAME"
        local PKG_MIRROR="${BOOTSTRAP_MIRROR}/${!PKG}"

        if [ ! -f $ARC/${!PKG_NAME} ]; then
            echo "  >> Downloading ${!PKG_NAME}..."

            wget ${PKG_MIRROR} -O $ARC/${!PKG_NAME}

            check_error_exit
        else
            echo "  (x) Already have ${!PKG_NAME}"
        fi

        echo -e "** Unpack and install $ARC/${!PKG_NAME} then set up the bootstrap paths before running build-tools.sh -t 1, e.g.:\n\n"
        echo -e "\texport OLD_PATH=\$PATH"
        echo -e "\texport OLD_LD_LIBRARY_PATH=\$LD_LIBRARY_PATH"
        echo -e "\texport PATH=${BOOTSTRAP_DIR}/bin:\$PATH"
        echo -e "\texport LD_LIBRARY_PATH=${BOOTSTRAP_DIR}/lib64:${BOOTSTRAP_DIR}/lib:\$LD_LIBRARY_PATH"
        echo -e "\n\tWhen you have built your native toolchain, set the paths back to the originals:"
        echo -e "\texport PATH=\$OLD_PATH"
        echo -e "\texport LD_LIBRARY_PATH=\$OLD_LD_LIBRARY_PATH"
    fi
}

#export OLD_PATH=$PATH
#export BS_CC="$BOOTSTRAP_DIR/bin/gcc"
#export BS_CXX="$BOOTSTRAP_DIR/bin/g++"
#export BS_AR="$BOOTSTRAP_DIR/bin/gcc-ar"
#export BS_NM="$BOOTSTRAP_DIR/bin/gcc-nm"
#export BS_RANLIB="$BOOTSTRAP_DIR/bin/gcc-ranlib"
#export BS_LD="$BOOTSTRAP_DIR/bin/g++"

#export BS_CC=
#export BS_CXX=
#export BS_AR=
#export BS_NM=
#export BS_RANLIB=
#export BS_LD=

function bootstrap_install()
{
    echo "  >> Installing bootstrap compiler"

    if [ is_bootstrap_required ]; then
        if [ ! -d $BOOTSTRAP_BASE_DIR ]; then
            mkdir -p $BOOTSTRAP_BASE_DIR

            local PKG_PREFIX=$(echo $(uname -m) | tr [:lower:] [:upper:])
            local PKG="${PKG_PREFIX}_BOOTSTRAP_TARBALL"

            if [ ! -d $BOOTSTRAP_BASE_DIR/usr ]; then
                tar -xJpf $ARC/${!PKG} -C $BOOTSTRAP_BASE_DIR

            fi
        fi

        export PATH=$BOOTSTRAP_DIR/bin:$PATH

        export BS_CC="$BOOTSTRAP_DIR/bin/gcc"
        export BS_CXX="$BOOTSTRAP_DIR/bin/g++"
        export BS_AR="$BOOTSTRAP_DIR/bin/gcc-ar"
        export BS_NM="$BOOTSTRAP_DIR/bin/gcc-nm"
        export BS_RANLIB="$BOOTSTRAP_DIR/bin/gcc-ranlib"
        export BS_LD="$BOOTSTRAP_DIR/bin/g++"
    
        echo ">>> PATH: $PATH"
        echo ">>> BS_CC: $BS_CC"
    fi
}

function bootstrap_remove()
{
    if [ is_bootstrap_required ]; then
        echo "  >> Uninstalling bootstrap compiler"

        rm -rf $BOOTSTRAP_DIR

        #echo ">>> PATH: $PATH"
        #echo ">>> OLD_PATH: $OLD_PATH"

        export PATH=$OLD_PATH

        #echo ">>> PATH: $PATH"
    fi
}
