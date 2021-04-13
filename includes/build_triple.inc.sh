########################################################################################################################
# This file defines what the build machine is.
########################################################################################################################

function is_gcc_installed() {
    command -v gcc >/dev/null 2>&1 || return 1
}

function is_clang_installed() {
    command -v clang >/dev/null 2>&1 || return 1
}

########################################################################################################################
# Use the compiler for the BUILD_TRIPLE as different OS', even different distributions of the same OS, can be different.
#
# Debian/Ubuntu has a x86_64-linux-gnu dir in /usr/lib
#   + gcc -dumpmachine -> x86_64-linux-linux
# Gentoo has /usr/x86_64-pc-linux-gnu
#   + gcc/clang -dumpmachine -> x86_64-pc-linux-linux
# Fedora has no x86_64-pc-linux-gnu dirs.
#   + gcc -dumpmachine -> x86_64-redhat-linux
# DragonFly BSD has no x86_64-pc-linux-gnu dirs.
#   + gcc -dumpmachine -> x86_64-pc-dragonflybsd
# Windows 10 Powershell doesn't have OSTYPE or uname
########################################################################################################################
if [ ! is_gcc_installed ]; then
    if [ ! is_clang_installed ]; then
        BUILD_TRIPLE="`clang -dumpmachine`"
    else
        echo "No C compiler installed, install GCC or Clang."

        exit 1
    fi
else
    BUILD_TRIPLE="`gcc -dumpmachine`"
fi

########################################################################################################################
# What archtecture is this? e.g. x86_64, i686
########################################################################################################################
export CPU="`uname -m`"

########################################################################################################################
# What OS are we on? e.g. Linux, Darwin, MSYS_*
# N.B: Don't call is OS because gprbuild.gpr grabs the variable.
# Cannot rely on GCC config.guess script giving the correct value, gives x86_64-unknown-linux-gnu insteaed of
# x86_64-pc-linux-gnu!
#
# N.B: Do not rename this variable to OS, it conflicts with a variable inside GPRBuild's gpr file.
########################################################################################################################
# export OS="`uname -s`"

# case ${OS} in
#     "Linux")
#         HOST_TRIPLE="${CPU}-pc-linux-gnu"
#         ;;
#     "Darwin")
#         # OSTYPE contains the Darwin with version number e.g. darwin19.0
#         HOST_TRIPLE="${CPU}-apple-${OSTYPE}"
#         ;;
#     "MSYS*")
#         ;;
# esac

# # As default, set the build system to the host, i.e. either native or cross build.
# BUILD_TRIPLE=${HOST}

