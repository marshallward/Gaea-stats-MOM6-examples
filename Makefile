# MOM6-examples Makefile for Gaea

#COMPILERS = gnu intel nvidia
COMPILERS := gnu
STATE := debug repro
LAYOUTS := dynamic_symmetric dynamic_nonsymmetric
#MODELS := ocean_only ice_ocean_SIS2 coupled_AM2_SIS2_MOM6?
MODELS := ocean_only


# GNU configuration
CC_GNU := cc
CFLAGS_GNU := -g
CFLAGS_GNU_DEBUG := $(CFLAGS_GNU) -O0
CFLAGS_GNU_REPRO := $(CFLAGS_GNU) -O2

FC_GNU := ftn
FCFLAGS_GNU := -g -fbacktrace -Waliasing -fno-range-check
FCFLAGS_GNU_DEBUG := $(FCFLAGS_GNU) -O0 -W -fbounds-check \
  -ffpe-trap=invalid,zero,overflow
FCFLAGS_GNU_REPRO := $(FCFLAGS_GNU) -O2


# Intel configuration
CC_INTEL := cc
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

build/gnu/%: CC = $(CC_GNU)
build/gnu/%: FC = $(FC_GNU)
build/gnu/debug/%: CFLAGS = $(CFLAGS_GNU_DEBUG)
build/gnu/repro/%: CFLAGS = $(CFLAGS_GNU_REPRO)
build/gnu/debug/%: FCFLAGS = $(FCFLAGS_GNU_DEBUG)
build/gnu/repro/%: FCFLAGS = $(FCFLAGS_GNU_REPRO)

build/intel/%: CC = $(CC_INTEL)
build/intel/%: FC = $(FC_INTEL)
build/intel/debug/%: CFLAGS = $(CFLAGS_INTEL_DEBUG)
build/intel/repro/%: CFLAGS = $(CFLAGS_INTEL_REPRO)
build/intel/debug/%: FCFLAGS = $(FCFLAGS_INTEL_DEBUG)
build/intel/repro/%: FCFLAGS = $(FCFLAGS_INTEL_REPRO)

build/nvidia/%: CC = $(CC_NVIDIA)
build/nvidia/%: FC = $(FC_NVIDIA)
build/nvidia/debug/%: CFLAGS = $(CFLAGS_NVIDIA_DEBUG)
build/nvidia/repro/%: CFLAGS = $(CFLAGS_NVIDIA_REPRO)
build/nvidia/debug/%: FCFLAGS = $(FCFLAGS_NVIDIA_DEBUG)
build/nvidia/repro/%: FCFLAGS = $(FCFLAGS_NVIDIA_REPRO)

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
