########################################################################################################################
# Filename    # bootstrap.inc
# Purpose     # Download and install the bootstrap compiler if required.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################
# NOTE: Must be included after build_triple.inc.sh and config.inc.sh!
########################################################################################################################
# TODO - Build own statically linked bootstrap compilers.

BOOTSTRAP_MIRROR="https://community.download.adacore.com/v1"

case $(uname -s) in
    "Linux")
        BOOTSTRAP_HASH="9682e2e1f2f232ce03fe21d77b14c37a0de5649b"
        # BOOTSTRAP_HASH="10360eb85955d40f340f672441e8415cb0877fcc"
        BOOTSTRAP_SUFFIX="${CPU}-linux-bin"
        ;;
    "Darwin")
        # OSTYPE contains the Darwin with version number e.g. darwin19.0
        BOOTSTRAP_HASH="7bbc77bd9c3c03fdb93699bce67b458f95d049a9"
        BOOTSTRAP_SUFFIX="${CPU}-darwin-bin"
        ;;
    "MSYS*")
        ;;
esac

BOOTSTRAP_PREFIX="gnat-gpl-2017"
# BOOTSTRAP_PREFIX="gnat-community-2018-20180528"
BOOTSTRAP_BASE_NAME=${BOOTSTRAP_PREFIX}-${BOOTSTRAP_SUFFIX}
BOOTSTRAP_TARBALL="${BOOTSTRAP_HASH}?filename=${BOOTSTRAP_BASE_NAME}.tar.gz"
BOOTSTRAP_TARBALL_NAME="${BOOTSTRAP_BASE_NAME}.tar.gz"

# BOOTSTRAP_DIR="${BOOTSTRAPS}"

function bootstrap_download()
{
    if ! command -v gnat >/dev/null 2>&1; then
        local PKG="${BOOTSTRAP_TARBALL}"
        local PKG_NAME="${BOOTSTRAP_TARBALL_NAME}"
        local PKG_MIRROR="${BOOTSTRAP_MIRROR}/${PKG}"

        if [ ! -f $ARC/${PKG_NAME} ]; then
            echo "  >> Downloading ${PKG_NAME}..."

            wget ${PKG_MIRROR} --quiet --show-progress --progress=bar:force -O $ARC/${PKG_NAME}

            check_error_exit
        else
            echo "  (x) Already have ${PKG_NAME}"
        fi
    fi
}

function bootstrap_install()
{
    echo "  >> Installing bootstrap compiler"

    if ! command -v gnat >/dev/null 2>&1; then
        if [ ! -d ${BOOTSTRAPS} ]; then
            mkdir -p ${BOOTSTRAPS}
        fi

        local PKG_NAME="${BOOTSTRAP_TARBALL_NAME}"

        # echo "PKG_NAME - ${PKG_NAME}"
        # echo "BOOTSTRAPS - ${BOOTSTRAPS}"

        if [ ! -d ${BOOTSTRAPS}/${BOOTSTRAP_BASE_NAME} ]; then
            tar -xzpf ${ARC}/${PKG_NAME} -C ${BOOTSTRAPS}
        fi
    fi
}

function bootstrap_path()
{
    if ! command -v gnat >/dev/null 2>&1; then
        # echo "  >> Enabling use of bootstrap compiler."

        # export PATH=${BOOTSTRAPS}/bin:${PATH}
        # echo "BS PATH - $PATH"

        echo "${BOOTSTRAPS}/${BOOTSTRAP_BASE_NAME}"
    fi

    # export BS_CC="${BOOTSTRAPS}/bin/gcc"
    # export BS_CXX="${BOOTSTRAPS}/bin/g++"
    # export BS_AR="${BOOTSTRAPS}/bin/gcc-ar"
    # export BS_NM="${BOOTSTRAPS}/bin/gcc-nm"
    # export BS_RANLIB="${BOOTSTRAPS}/bin/gcc-ranlib"
    # export BS_LD="${BOOTSTRAPS}/bin/g++"

    # echo ">>> PATH: ${PATH}"
    # echo ">>> BS_CC: ${BS_CC}"
    # echo ">>> BS_CXX: ${BS_CXX}"
    # echo ">>> BS_AR: ${BS_AR}"
    # echo ">>> BS_NM: ${BS_NM}"
    # echo ">>> BS_RANLIB: ${BS_RANLIB}"
    # echo ">>> BS_LD: ${BS_LD}"
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
