# Gaea regression testing Makefile
# (Currently only supports builds)


# Build targets
COMPILERS := gnu intel nvidia
STATE := debug repro
LAYOUTS := dynamic_symmetric dynamic_nonsymmetric
#MODELS := ocean_only ice_ocean_SIS2 coupled_AM2_SIS2_MOM6?
MODELS := ocean_only ice_ocean_SIS2


# Gaea compiler configuration

# GNU configuration
CFLAGS_GNU := -g
CFLAGS_GNU_DEBUG := $(CFLAGS_GNU) -O0
CFLAGS_GNU_REPRO := $(CFLAGS_GNU) -O2

FC_GNU := ftn
FCFLAGS_GNU := -g -fbacktrace -Waliasing -fno-range-check
FCFLAGS_GNU_DEBUG := $(FCFLAGS_GNU) -O0 -W -fbounds-check \
  -ffpe-trap=invalid,zero,overflow
FCFLAGS_GNU_REPRO := $(FCFLAGS_GNU) -O2


# Intel configuration
CFLAGS_INTEL := -g -sox -traceback
CFLAGS_INTEL_DEBUG := $(CFLAGS_INTEL) -O0 -ftrapuv
CFLAGS_INTEL_REPRO := $(CFLAGS_INTEL) -O2 -debug minimal

FC_INTEL := ftn
FCFLAGS_INTEL := -g -traceback -fno-alias -safe-cray-ptr -ftz -assume byterecl \
  -nowarn -sox
FCFLAGS_INTEL_DEBUG := $(FCFLAGS_INTEL) -O0 -check -check noarg_temp_created \
  -check nopointer -warn -warn noerrors -fpe0 -ftrapuv
FCFLAGS_INTEL_REPRO := $(FCFLAGS_INTEL) -O2 -debug minimal -fp-model source


# Nvidia configuration
CC_NVIDIA := cc
CFLAGS_NVIDIA := -g -traceback
CFLAGS_NVIDIA_DEBUG := $(CFLAGS_NVIDIA) -O0 -Ktrap=fp
CFLAGS_NVIDIA_REPRO := $(CFLAGS_NVIDIA) -O2

# NOTE: Nvidia has reproducibility issues at -O2 and -Mfma.  These are disabled
# for now, but we may restore these in the future.
FC_NVIDIA := ftn
FCFLAGS_NVIDIA := -g -traceback -Mdwarf3 -byteswapio -Mflushz -Mnofma -Mdaz \
  -D_F2000
FCFLAGS_NVIDIA_DEBUG := $(FCFLAGS_NVIDIA) -O0 -Ktrap=fp
FCFLAGS_NVIDIA_REPRO := $(FCFLAGS_NVIDIA) -O0


# Rules

all: \
	$(foreach c,$(COMPILERS),\
	$(foreach s,$(STATE),\
	$(foreach l,$(LAYOUTS),\
	$(foreach m,$(MODELS),\
	  build/$(c)/$(s)/$(l)/$(m)/MOM6 \
	))))

# TODO: We do not need to use the module symbolic links here.
# The explicit module file can be set alongside the compiler flags.

build/gnu/%: MODULES ?= environ/gnu.env
build/gnu/debug/%: CFLAGS = $(CFLAGS_GNU_DEBUG)
build/gnu/repro/%: CFLAGS = $(CFLAGS_GNU_REPRO)
build/gnu/debug/%: FCFLAGS = $(FCFLAGS_GNU_DEBUG)
build/gnu/repro/%: FCFLAGS = $(FCFLAGS_GNU_REPRO)

build/intel/%: MODULES = environ/intel.env
build/intel/debug/%: CFLAGS = $(CFLAGS_INTEL_DEBUG)
build/intel/repro/%: CFLAGS = $(CFLAGS_INTEL_REPRO)
build/intel/debug/%: FCFLAGS = $(FCFLAGS_INTEL_DEBUG)
build/intel/repro/%: FCFLAGS = $(FCFLAGS_INTEL_REPRO)

build/nvidia/%: MODULES = environ/pgi.env
build/nvidia/debug/%: CFLAGS = $(CFLAGS_NVIDIA_DEBUG)
build/nvidia/repro/%: CFLAGS = $(CFLAGS_NVIDIA_REPRO)
build/nvidia/debug/%: FCFLAGS = $(FCFLAGS_NVIDIA_DEBUG)
build/nvidia/repro/%: FCFLAGS = $(FCFLAGS_NVIDIA_REPRO)

# TODO: ...?
# - CPPFLAGS
# - CFLAGS
# - LDFLAGS
# ---
#   - PYTHON?
#   - LIBS? [Autoconf is supposed to set this]
#   - MPICC/MPIFC? [Autoconf *should* set this... I think?]

# TODO: Some comments:
#
# * We could pass CC, FC, etc as macros, then swap to environment variables
# 	when configure is invoked.
#
# * MODULES could also be passed as a macro and sourced in the build Makefile.

build/%: CC_ENV = CC="cc" MPICC="cc" CFLAGS="$(CFLAGS)"
build/%: FC_ENV = FC="ftn" MPIFC="ftn" FCFLAGS="$(FCFLAGS)"

# Executables

build/%/dynamic_symmetric/ice_ocean_SIS2/MOM6: \
  build/%/shared/fms/libFMS.a \
  build/%/shared/atmos_null/libatmos_null.a \
  build/%/shared/icebergs/libicebergs.a \
  build/%/shared/ice_param/libice_param.a \
  build/%/shared/land_null/libland_null.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ice_ocean_SIS2 \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/$*/shared/fms \
	  ATMOS_BUILD=../../build/$*/shared/atmos_null \
	  ICEBERGS_BUILD=../../build/$*/shared/icebergs \
	  ICE_PARAM_BUILD=../../build/$*/shared/ice_param \
	  LAND_BUILD=../../build/$*/shared/land_null

build/%/dynamic_nonsymmetric/ice_ocean_SIS2/MOM6: \
  build/%/shared/fms/libFMS.a \
  build/%/shared/atmos_null/libatmos_null.a \
  build/%/shared/icebergs/libicebergs.a \
  build/%/shared/ice_param/libice_param.a \
  build/%/shared/land_null/libland_null.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ice_ocean_SIS2 \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/$*/shared/fms \
	  ATMOS_BUILD=../../build/$*/shared/atmos_null \
	  ICEBERGS_BUILD=../../build/$*/shared/icebergs \
	  ICE_PARAM_BUILD=../../build/$*/shared/ice_param \
	  LAND_BUILD=../../build/$*/shared/land_null \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h \
	  SIS_MEMORY=../src/SIS2/config_src/dynamic/SIS2_memory.h

build/%/dynamic_symmetric/ocean_only/MOM6: build/%/shared/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/$*/shared/fms \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_symmetric/MOM_memory.h

build/%/dynamic_nonsymmetric/ocean_only/MOM6: build/%/shared/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(@D) \
	  FMS_BUILD=../../build/$*/shared/fms \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h


# Libraries

build/%/fms/libFMS.a:
	source $(MODULES) && \
	$(CC_ENV) $(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/fms \
	  BUILD=../../../$(@D)

build/%/atmos_null/libatmos_null.a: build/%/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/atmos_null \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/land_null/libland_null.a: build/%/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/land_null \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/ice_param/libice_param.a: build/%/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/ice_param \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

build/%/icebergs/libicebergs.a: build/%/fms/libFMS.a
	source $(MODULES) && \
	$(FC_ENV) \
	$(MAKE) -C MOM6-examples/shared/icebergs \
	  BUILD=../../../$(@D) \
	  FMS_BUILD=../../../build/$*/fms

clean:
	rm -rf build
