# These commands define a compilation environment for MOM6.
# The "gnu" regression results" correspond to this environment.

module unload PrgEnv-gnu
module unload PrgEnv-intel
module unload PrgEnv-nvhpc

module load PrgEnv-gnu
module switch gcc/12.2.0

module load cray-hdf5
module load cray-netcdf

module unload darshan-runtime
