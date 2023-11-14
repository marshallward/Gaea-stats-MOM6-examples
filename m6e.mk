# Test build
BUILD ?= build

# Models
MODELS=ocean_only ice_ocean_SIS2 coupled_AM2_LM3_SIS2
LIBS=AM2 atmos_null LM3 land_null icebergs ice_param fms

.PHONY: all
all: $(MODELS)

# ocean_only

.PHONY: ocean_only
ocean_only: ocean_only.symmetric ocean_only.asymmetric

.PHONY: ocean_only.symmetric
ocean_only.symmetric: fms
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(BUILD)/dynamic_symmetric/ocean_only \
	  FMS_BUILD=../../$(BUILD)/fms

.PHONY: ocean_only.asymmetric
ocean_only.asymmetric: fms
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(BUILD)/dynamic_nonsymmetric/ocean_only \
	  FMS_BUILD=../../$(BUILD)/fms \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h


# ice_ocean_SIS2

.PHONY: ice_ocean_SIS2
ice_ocean_SIS2: ice_ocean_SIS2.symmetric ice_ocean_SIS2.asymmetric

.PHONY: ice_ocean_SIS2.symmetric
ice_ocean_SIS2.symmetric: fms atmos_null land_null ice_param icebergs
	$(MAKE) -C MOM6-examples/ice_ocean_SIS2 \
	  BUILD=../../$(BUILD)/dynamic_symmetric/ice_ocean_SIS2 \
	  FMS_BUILD=../../$(BUILD)/fms \
	  ATMOS_BUILD=../../$(BUILD)/atmos_null \
	  ICEBERGS_BUILD=../../$(BUILD)/icebergs \
	  ICE_PARAM_BUILD=../../$(BUILD)/ice_param \
	  LAND_BUILD=../../$(BUILD)/land_null

.PHONY: ice_ocean_SIS2.asymmetric
ice_ocean_SIS2.asymmetric: fms atmos_null land_null ice_param icebergs
	$(MAKE) -C MOM6-examples/ice_ocean_SIS2 \
	  BUILD=../../$(BUILD)/dynamic_nonsymmetric/ice_ocean_SIS2 \
	  FMS_BUILD=../../$(BUILD)/fms \
	  ATMOS_BUILD=../../$(BUILD)/atmos_null \
	  ICEBERGS_BUILD=../../$(BUILD)/icebergs \
	  ICE_PARAM_BUILD=../../$(BUILD)/ice_param \
	  LAND_BUILD=../../$(BUILD)/land_null \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h \
	  SIS_MEMORY=../src/SIS2/config_src/dynamic/SIS2_memory.h


# Full coupled model

.PHONY: coupled_AM2_LM3_SIS2
coupled_AM2_LM3_SIS2: coupled_AM2_LM3_SIS2.symmetric coupled_AM2_LM3_SIS2.asymmetric

.PHONY: coupled_AM2_LM3_SIS2.symmetric
coupled_AM2_LM3_SIS2.symmetric: fms AM2 LM3 ice_param icebergs
	$(MAKE) -C MOM6-examples/coupled_AM2_LM3_SIS2 \
	  BUILD=../../$(BUILD)/dynamic_symmetric/coupled_AM2_LM3_SIS2 \
	  FMS_BUILD=../../$(BUILD)/fms \
	  AM2_BUILD=../../$(BUILD)/AM2 \
	  ICEBERGS_BUILD=../../$(BUILD)/icebergs \
	  ICE_PARAM_BUILD=../../$(BUILD)/ice_param \
	  LM3_BUILD=../../$(BUILD)/LM3

.PHONY: coupled_AM2_LM3_SIS2.asymmetric
coupled_AM2_LM3_SIS2.asymmetric: fms AM2 LM3 ice_param icebergs
	$(MAKE) -C MOM6-examples/coupled_AM2_LM3_SIS2 \
	  BUILD=../../$(BUILD)/dynamic_nonsymmetric/coupled_AM2_LM3_SIS2 \
	  FMS_BUILD=../../$(BUILD)/fms \
	  AM2_BUILD=../../$(BUILD)/AM2 \
	  ICEBERGS_BUILD=../../$(BUILD)/icebergs \
	  ICE_PARAM_BUILD=../../$(BUILD)/ice_param \
	  LM3_BUILD=../../$(BUILD)/LM3 \
	  MOM_MEMORY=../src/MOM6/config_src/memory/dynamic_nonsymmetric/MOM_memory.h \
	  SIS_MEMORY=../src/SIS2/config_src/dynamic/SIS2_memory.h

#---------
#---------

# testing
.PHONY: ocean_only.main
ocean_only.main: fms.main
	$(MAKE) -C MOM6-examples/ocean_only \
	  BUILD=../../$(BUILD)/main/ocean_only \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  FMS_FRAMEWORK=fms2


.PHONY: ice_ocean_SIS2.main
ice_ocean_SIS2.main: fms.main atmos_null.main land_null.main ice_param.main icebergs.main
	$(MAKE) -C MOM6-examples/ice_ocean_SIS2 \
	  BUILD=../../$(BUILD)/main/ice_ocean_SIS2 \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  ATMOS_BUILD=../../$(BUILD)/main/atmos_null \
	  ICEBERGS_BUILD=../../$(BUILD)/main/icebergs \
	  ICE_PARAM_BUILD=../../$(BUILD)/main/ice_param \
	  LAND_BUILD=../../$(BUILD)/main/land_null \
	  FMS_FRAMEWORK=fms2


.PHONY: atmos_null.main
atmos_null.main: fms.main MOM6-examples/src/main/atmos_null
	$(MAKE) -C MOM6-examples/shared/atmos_null \
	  BUILD=../../$(BUILD)/main/atmos_null \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  CODEBASE=../../src/main/atmos_null

MOM6-examples/src/main/atmos_null:
	mkdir -p MOM6-examples/src/main
	git -C MOM6-examples/src/main clone https://github.com/NOAA-GFDL/atmos_null.git
	git -C $@ checkout master


.PHONY: land_null.main
land_null.main: fms.main MOM6-examples/src/main/land_null
	$(MAKE) -C MOM6-examples/shared/land_null \
	  BUILD=../../$(BUILD)/main/land_null \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  CODEBASE=../../src/main/land_null

MOM6-examples/src/main/land_null:
	mkdir -p MOM6-examples/src/main
	git -C MOM6-examples/src/main clone https://github.com/NOAA-GFDL/land_null.git
	git -C $@ checkout master


.PHONY: ice_param.main
ice_param.main: fms.main MOM6-examples/src/main/ice_param
	$(MAKE) -C MOM6-examples/shared/ice_param \
	  BUILD=../../$(BUILD)/main/ice_param \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  CODEBASE=../../src/main/ice_param

MOM6-examples/src/main/ice_param:
	mkdir -p MOM6-examples/src/main
	git -C MOM6-examples/src/main clone https://github.com/NOAA-GFDL/ice_param.git
	git -C $@ checkout master


.PHONY: icebergs.main
icebergs.main: fms.main MOM6-examples/src/main/icebergs
	CPPFLAGS="-DUSE_FMS2_IO" \
	$(MAKE) -C MOM6-examples/shared/icebergs \
	  BUILD=../../$(BUILD)/main/icebergs \
	  FMS_BUILD=../../$(BUILD)/main/fms \
	  CODEBASE=../../src/main/icebergs/src

MOM6-examples/src/main/icebergs:
	mkdir -p MOM6-examples/src/main
	git -C MOM6-examples/src/main clone https://github.com/NOAA-GFDL/icebergs.git
	git -C $@ checkout dev/gfdl


.PHONY: fms.main
fms.main: MOM6-examples/src/FMS_main
	$(MAKE) -C MOM6-examples/shared/fms \
	  BUILD=../../$(BUILD)/main/fms \
	  CODEBASE=../../src/FMS_main

MOM6-examples/src/FMS_main:
	git -C MOM6-examples/src/ clone https://github.com/NOAA-GFDL/FMS.git FMS_main
	git -C $@ checkout main

#---------
#---------


# Libraries

.PHONY: fms
fms: $(BUILD)/fms/libFMS.a

$(BUILD)/fms/libFMS.a:
	$(MAKE) -C MOM6-examples/shared/fms \
	  BUILD=../../../$(BUILD)/fms

.PHONY: atmos_null
atmos_null: fms
	$(MAKE) -C MOM6-examples/shared/atmos_null \
	  BUILD=../../../$(BUILD)/atmos_null \
	  FMS_BUILD=../../../$(BUILD)/fms

.PHONY: AM2
AM2: fms
	$(MAKE) -C MOM6-examples/shared/AM2 \
	  BUILD=../../../$(BUILD)/AM2 \
	  FMS_BUILD=../../../$(BUILD)/fms

.PHONY: land_null
land_null: fms
	$(MAKE) -C MOM6-examples/shared/land_null \
	  BUILD=../../../$(BUILD)/land_null \
	  FMS_BUILD=../../../$(BUILD)/fms

.PHONY: LM3
LM3: fms
	$(MAKE) -C MOM6-examples/shared/LM3 \
	  BUILD=../../../$(BUILD)/LM3 \
	  FMS_BUILD=../../../$(BUILD)/fms

.PHONY: ice_param
ice_param: fms
	$(MAKE) -C MOM6-examples/shared/ice_param \
	  BUILD=../../../$(BUILD)/ice_param \
	  FMS_BUILD=../../../$(BUILD)/fms

.PHONY: icebergs
icebergs: fms
	$(MAKE) -C MOM6-examples/shared/icebergs \
	  BUILD=../../../$(BUILD)/icebergs \
	  FMS_BUILD=../../../$(BUILD)/fms


# Runs
# NOTE: This is not yet implemented, and is only an example of how this could
# look in a future version.

RUNDIR ?= runs

# unused
rwildcard=$(foreach d,$(wildcard $(1:=/*)),\
  $(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

# Build manifest
# TODO: recursive wildcard
PARAM_LIST=$(shell find $1 -name MOM_parameter_doc.all)
EXPT_DIRS=$(patsubst $1/%/MOM_parameter_doc.all,%,$(call PARAM_LIST,$1))

# 1: rundir
# 2: build dir
# 3: expt dir
define EXPT_RULE
$(1)/ocean.stats: ocean_only ;
	$(MAKE) -C ocean_only ../$(1)/ocean.stats \
	  BUILD=../$(2) \
	  OUTPUT=../$(1) \
	  EXPT=$(3)
endef
$(foreach e,$(call EXPT_DIRS,ocean_only),\
  $(eval $(call EXPT_RULE,$(RUNDIR)/ocean_only/symmetric/$e,$(BUILD)/ocean_only/symmetric,$e)))


run.ocean_only: $(foreach e,$(call EXPT_DIRS,ocean_only),\
  $(RUNDIR)/ocean_only/symmetric/$(e)/ocean.stats)


# Cleanup

clean: $(foreach model,$(MODELS),$(model).clean)
	rm -rf build

define MODEL_CLEAN_RULE
.PHONY: $(1).clean
$(1).clean: $(1).symmetric.clean $(1).asymmetric.clean

.PHONY: $(1).symmetric.clean
$(1).symmetric.clean:
	$(MAKE) -C $(1) \
	  BUILD=../$(BUILD)/dynamic_symmetric/$(1) \
	  clean

.PHONY: $(1).asymmetric.clean
$(1).asymmetric.clean:
	$(MAKE) -C $(1) \
	  BUILD=../$(BUILD)/dynamic_nonsymmetric/$(1) \
	  clean
endef
$(foreach model,$(MODELS),$(eval $(call MODEL_CLEAN_RULE,$(model))))

define CLEAN_RULE
.PHONY: $(1).clean
$(1).clean:
	$(MAKE) -C shared/$(1) \
	  BUILD=../../$(BUILD)/$(1) \
	  clean
endef
$(foreach lib,$(LIBS),$(eval $(call CLEAN_RULE,$(lib))))
