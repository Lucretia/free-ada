# Free Ada

This is a set of build scripts to enable you to build the FSF Ada compiler with AdaCore's GPL'd tools. This is the FSF
version of GCC, not AdaCore's GPL'd version which cannot be used for commercial closed source use!

## Why?

GCC is a bitch to build and worse still are AdaCore's GPL'd (extra) projects. Having scripts to do it is a lot easier.

## What's provided?

* FSF GCC
* Binutils
* GDB

The following are AdaCore GPL-2018 versions:

* XML/Ada
* GPRBuild
* GNATColl
* GNATColl-Bindings
* GNATColl-DB
* LibAdaLang
* LibAdaLang-Tools
* AUnit

To find out what versions are built, see the ```config-master.inc.sh``` file.

## Git branches

I have the following branches I will develop on and changes in the latest branch will go into master.

* gcc-9.x - As of 06/11/2019, this branch has been merged into master.
* gcc-8.x - As of 06/11/2019, this is up to date with gcc-9.x, there will be no more updates on this branch unless deemed necessary.
* gcc-7.x - Deprecated as of 06/11/2019, cannot support the current libadalang.

I will be focussing on the latest GCC build's keeping the previous going as long as I can. I will note here the branches and what is deprecated and what isn't. When GCC-10.x is released I will add a new branch for that.

## Package manager

You can try [Alire](https://github.com/mosteo/alire) to handle the installation of Ada packages.

## Help

Get help with the scripts and what can be built so far:

```bash
$ ./build-tools.sh -h
```

## Building instructions

To get a native toolchain, use the following instructions:

```bash
  cp config-master.inc.sh config.inc.sh
  # modify config.inc as required
  ./download.sh
  ./build-tools.sh -t 1
```

If you leave everything as default, you will have a bunch of archives in a packages directory and the toolchain installed
to ```$HOME/opt/free-ada-new```

### Gentoo

```bash
$ emerge -av dev-util/dejagnu dev-tcltk/expect dev-lang/tcl
```

### Bare metal cross compilers

These options allow you to build bare metal C and Ada compilers, you have to provide your own runtime.

The following targets have been built, but any target supported by GCC should build now.

* arm-none-eabi
* i386-elf
* x86_64-elf
* mips-elf
* msp430-elf
* avr - **NOTE** Don't use this as it doesn't match the build from the official avr-ada and it's Duration isn't right.
* ppc-elf

## Copyright

Copyright (C) 2011-2019 Luke A. Guest with assistance from David Rees

## Notes

* This project no longer uses git flow.
* GNATColl requires Python 2 to create documentation, it will not build with Python 3.
* If you want to build the new [GNAT-LLVM](https://github.com/AdaCore/gnat-llvm) compiler, you need the gcc-9.x branch.
