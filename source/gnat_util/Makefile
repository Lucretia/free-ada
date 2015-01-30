# This makefile is used to build and install Gnat_Util
# For information on building and installing Gnat_Util see README.gnat_util.

ENABLE_SHARED=no
BUILD_TYPE=Production

prefix=/usr/local

BUILDER=gprbuild -j0
INSTALLER=gprinstall

OS_TYPE=unix

ifeq ($(OS),Windows_NT)
  OS_TYPE=Windows_NT
endif

CP=cp -p
MKDIR=mkdir -p
SRC=gen_src

.PHONY: all
all: generate_sources
	${BUILDER} -m -XOS=$(OS_TYPE) -XBUILD=$(BUILD_TYPE) \
		-XLIBRARY_TYPE=static -Pgnat_util -p
ifeq ($(ENABLE_SHARED), yes)
	${BUILDER} -m -XOS=$(OS_TYPE) -XBUILD=$(BUILD_TYPE) \
		-XLIBRARY_TYPE=relocatable -Pgnat_util -p
endif

.PHONY: generate_sources
generate_sources:
	$(MKDIR) $(SRC)
	$(CP) xsnamest.adb xutil.* snames.adb-tmpl snames.ads-tmpl snames.h-tmpl $(SRC)
	(cd $(SRC) && \
	   gnatmake -gnatf -gnatwae -gnatyg -gnatyS xsnamest && \
	   ./xsnamest && mv snames.ns snames.ads && mv snames.nb snames.adb)
	$(CP) sdefault.adb $(SRC)/sdefault.adb
#	$(CP) sdefault_adb.gnat_util $(SRC)/sdefault.adb

install-clean:
ifneq (,$(wildcard $(prefix)/lib/gnat/manifests/gnat_util))
	-$(INSTALLER) -XOS=$(OS_TYPE) -XBUILD=$(BUILD_TYPE) --uninstall \
		--prefix=$(prefix) --project-subdir=lib/gnat gnat_util
endif

.PHONY: install
install: install-clean
	${INSTALLER} -p -f -XOS=$(OS_TYPE) -XBUILD=$(BUILD_TYPE) \
		-XLIBRARY_TYPE=static \
		--prefix=$(prefix) \
		--sources-subdir=include/gnat_util \
		--lib-subdir=lib/gnat_util/static \
		--project-subdir=lib/gnat \
		--build-var=LIBRARY_TYPE --build-name=static -Pgnat_util
ifeq ($(ENABLE_SHARED), yes)
	${INSTALLER} -p -f -XOS=$(OS_TYPE) -XBUILD=$(BUILD_TYPE) \
		-XLIBRARY_TYPE=relocatable \
		--prefix=$(prefix) \
		--sources-subdir=include/gnat_util \
		--lib-subdir=lib/gnat_util/relocatable \
		--project-subdir=lib/gnat \
		--build-var=LIBRARY_TYPE --build-name=relocatable -Pgnat_util
endif

.PHONY: clean
clean:
	-gprclean -r -q -Pgnat_util -XOS=$(OS_TYPE) -XLIBRARY_TYPE=relocatable
	-gprclean -r -q -Pgnat_util -XOS=$(OS_TYPE) -XLIBRARY_TYPE=static
