#COMPILERS = gnu intel nvidia
COMPILERS := gnu
STATE := debug repro
LAYOUTS := dynamic_symmetric dynamic_nonsymmetric
#MODELS := ocean_only ice_ocean_SIS2 coupled_AM2_SIS2_MOM6?
MODELS := ocean_only

# TODO: Move to config file?
CC_GNU := gcc
CFLAGS_GNU := -g
CFLAGS_GNU_DEBUG := $(CFLAGS_GNU) -O0
CFLAGS_GNU_REPRO := $(CFLAGS_GNU) -O2

FC_GNU := gfortran
FCFLAGS_GNU := -g -fbacktrace -Waliasing -fno-range-check
FCFLAGS_GNU_DEBUG := $(FCFLAGS_GNU) -O0 -W -fbounds-check -ffpe-trap=invalid,zero,overflow
FCFLAGS_GNU_REPRO := $(FCFLAGS_GNU) -O2


all: \
	$(foreach c,$(COMPILERS),\
	$(foreach s,$(STATE),\
	$(foreach l,$(LAYOUTS),\
	$(foreach m,$(MODELS),\
	build/$(c)/$(s)/$(l)/$(m)/MOM6 \
	))))

# GNU
build/gnu/%: CC = $(CC_GNU)
build/gnu/%: FC = $(FC_GNU)
build/gnu/debug/%: CFLAGS = $(CFLAGS_GNU_DEBUG)
build/gnu/repro/%: CFLAGS = $(CFLAGS_GNU_REPRO)
build/gnu/debug/%: FCFLAGS = $(FCFLAGS_GNU_DEBUG)
build/gnu/repro/%: FCFLAGS = $(FCFLAGS_GNU_REPRO)

# TODO: ...?
# - CPPFLAGS
# - CFLAGS
# - LDFLAGS
# ---
# 	- PYTHON?
#   - LIBS? [Autoconf is supposed to set this]
#   - MPICC/MPIFC? [Autoconf *should* set this... I think?]

build/%: CC_ENV = CC="$(CC)" CFLAGS="$(CFLAGS)"
build/%: FC_ENV = FC="$(FC)" FCFLAGS="$(FCFLAGS)"


build/gnu/%/dynamic_symmetric/ocean_only/MOM6: build/gnu/%/shared/fms/libFMS.a
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/gnu/debug/shared/fms \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_symmetric/MOM_memory.h

build/gnu/%/dynamic_nonsymmetric/ocean_only/MOM6: build/gnu/%/shared/fms/libFMS.a
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
