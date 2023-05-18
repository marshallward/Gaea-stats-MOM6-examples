# These commands define a compilation environment for MOM6.
# The "intel" regression results" correspond to this environment.

module unload PrgEnv-gnu
module unload PrgEnv-intel
module unload PrgEnv-nvhpc

module load PrgEnv-intel
module unload intel
module unload intel-classic
module load intel-classic/2022.0.2

module load cray-hdf5
module load cray-netcdf

module unload darshan-runtime

# NOTE: Perhaps only a temporary requirement
module switch cray-libsci/22.10.1.2
