#COMPILERS = gnu intel nvidia
COMPILERS = gnu
MODES = debug repro

# TODO: Move to config file?
FC_GNU = gfortran
FCFLAGS_GNU_DEBUG = -g -O0
FCFLAGS_GNU_REPRO = -g -O2

#all: $(foreach COMPILERS,c,$(foreach MODES,m,build/$(c)/$(m)/shared/fms/libFMS.a))
all: $(foreach m,$(MODES),build/gnu/$(m)/shared/fms/libFMS.a)

# GNU
build/gnu/debug/shared/fms/libFMS.a: FC = "$(FC_GNU)"
build/gnu/repro/shared/fms/libFMS.a: FC = "$(FC_GNU)"

build/gnu/debug/shared/fms/libFMS.a: FCFLAGS = "$(FCFLAGS_GNU_DEBUG)"
build/gnu/repro/shared/fms/libFMS.a: FCFLAGS = "$(FCFLAGS_GNU_REPRO)"

build/%/shared/fms/libFMS.a:
	FC=$(FC) \
	FCFLAGS=$(FCFLAGS) \
	$(MAKE) -C MOM6-examples/shared/fms \
	  BUILD=../../../$(@D)

clean:
	rm -rf build
