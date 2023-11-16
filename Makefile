#COMPILERS = gnu intel nvidia
COMPILERS := gnu
MODES := debug repro

# TODO: Move to config file?
CC_GNU := gcc
FC_GNU := gfortran
FCFLAGS_GNU := -g
FCFLAGS_GNU_DEBUG := $(FCFLAGS_GNU) -O0
FCFLAGS_GNU_REPRO := -g -O2

#all: $(foreach COMPILERS,c,$(foreach MODES,m,build/$(c)/$(m)/shared/fms/libFMS.a))
#all: $(foreach m,$(MODES),build/gnu/$(m)/shared/fms/libFMS.a)
all: $(foreach m,$(MODES),build/gnu/$(m)/shared/atmos_null/libatmos_null.a)

# GNU
build/gnu/%: CC = $(CC_GNU)
build/gnu/%: FC = $(FC_GNU)
build/gnu/debug/%: FCFLAGS = $(FCFLAGS_GNU_DEBUG)
build/gnu/repro/%: FCFLAGS = $(FCFLAGS_GNU_REPRO)

# TODO:
# - CPPFLAGS
# - CFLAGS
# - LDFLAGS
# ---
# 	- PYTHON?
#   - LIBS? [Autoconf is supposed to set this]
#   - MPICC/MPIFC? [Autoconf *should* set this... I think?]

build/%: CC_ENV = CC="$(CC)" CFLAGS="$(CFLAGS)"
build/%: FC_ENV = FC="$(FC)" FCFLAGS="$(FCFLAGS)"


build/gnu/debug/dynamic_symmetric/ocean_only/MOM6: build/gnu/debug/shared/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/gnu/debug/shared/fms \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h

build/%/fms/libFMS.a:
	$(CC_ENV) $(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/fms \
	  BUILD=../../../$(@D)

build/%/atmos_null/libatmos_null.a: build/%/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/atmos_null \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/land_null/libland_null.a: build/%/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/land_null \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/ice_param/libice_param.a: build/%/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/ice_param \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/icebergs/libicebergs.a: build/%/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/icebergs \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

clean:
	rm -rf build
