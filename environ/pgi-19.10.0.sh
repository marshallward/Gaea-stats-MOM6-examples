# These commands define a compilation environment for MOM6.
# The "pgi" regression results" correspond to this environment.
# Platform: ncrc3, ncrc4
source /opt/modules/default/etc/modules.sh
module use -a /ncrc/home2/fms/local/modulefiles
MODULEPATH=/usw/eslogin/modulefiles-c4:/sw/eslogin-c4/modulefiles:/opt/cray/pe/ari/modulefiles:/opt/cray/ari/modulefiles:/opt/cray/pe/modulefiles:/opt/cray/modulefiles:/opt/modulefiles:/sw/common/modulefiles
module unload PrgEnv-intel ; module load PrgEnv-pgi darshan; module unload netcdf pgi; module load pgi/19.10.0 cray-hdf5 cray-netcdf
