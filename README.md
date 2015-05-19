# Free Ada

## Who did this?

Copyright (C) 2011-2015 Luke A. Guest & David Rees

## What is this?

This is a set of build scripts to enable you to build the FSF Ada compiler with AdaCore's GPL'd tools. This is the FSF
version of GCC, not AdaCore's GPL'd version which cannot be used for commercial closed source use!

## Why?

GCC is a bitch to build and worse still are AdaCore's GPL'd (extra) projects. Having scripts to do it is a lot easier.

## What's provided?

* FSF GCC
* Binutils
* libgnat_util (using the FSF sources)
* XML/Ada
* GPRBuild
* GNATMem
* GNATColl
* ASIS (with tools)

To find out what versions are built, see the config-master.inc file.

## Help

Get help with the scripts and what can be built so far:

  ./build-tools.sh -h

## Building instructions

To get a native toolchain, use the following instructions:

  cp config-master.inc config.inc
  <modify config.inc as required>
  ./download.sh
  ./build-tools.sh -t 1

If you leave everything as default, you will have a bunch of archives in a packages directory and the toolchain installed
to ```$HOME/opt/free-ada-new

### Bare metal cross compilers

These options allow you to build bare metal C and Ada compilers, you have to provide your own runtime.

The following targets have been built, but any target supported by GCC should build now.

* arm-none-eabi
* i386-elf
* x86_64-elf
* mips-elf
* msp430-elf
* avr
* ppc-elf

## Notes

* This project uses git flow.
* GNATColl requires Python 2 to create documentation, it will not build with Python 3.
