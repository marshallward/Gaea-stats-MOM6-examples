# These commands define a compilation environment for MOM6.
# The "pgi" regression results" correspond to this environment.

module unload PrgEnv-gnu
module unload PrgEnv-intel
module unload PrgEnv-nvhpc

module load PrgEnv-nvhpc/8.3.3
module switch nvhpc/22.3

module unload darshan-runtime

module load cray-hdf5
module load cray-netcdf
