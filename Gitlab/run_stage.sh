#!/bin/bash -f

# This script creates a job script that is launched once and in turns creates tar files
# of the model output after various runs.
# This script *assumes* that it is launched from the root of Gaea_stats-MOM6-examples regression repo.

echo -n "Run stage started at " && date
rm -f job.log

# Make a job script
cat > job.sh << 'EOF'
# Run non-symmetric executables
make -f Gitlab/Makefile.run clean_gnu clean_intel clean_pgi -s
echo -n "Non-symmetric runs started at " && date
make -f Gitlab/Makefile.run gnu_all -s -j
make -f Gitlab/Makefile.run intel_all -s -j
make -f Gitlab/Makefile.run pgi_all -s -j
echo -n "Non-symmetric runs finished at " && date
(cd MOM6-examples; tar cf non_symmetric_gnu.tar `find . -name ocean.stats.gnu`)
(cd MOM6-examples; tar cf non_symmetric_intel.tar `find . -name ocean.stats.intel`)
(cd MOM6-examples; tar cf non_symmetric_pgi.tar `find . -name ocean.stats.pgi`)

# Run static executables
echo -n "Static runs started at " && date
make -f Gitlab/Makefile.run clean_gnu clean_intel clean_pgi -s
make -f Gitlab/Makefile.run gnu_static_ocean_only MEMORY=static -s -j
echo -n "Static runs finished at " && date
(cd MOM6-examples; tar cf static_gnu.tar `find . -name ocean.stats.gnu`)

# Run symmetric executables
make -f Gitlab/Makefile.run clean_gnu clean_intel clean_pgi -s
echo -n "Symmetric runs started at " && date
make -f Gitlab/Makefile.run gnu_all MEMORY=dynamic_symmetric -s -j
make -f Gitlab/Makefile.run intel_all MEMORY=dynamic_symmetric -s -j
make -f Gitlab/Makefile.run pgi_all MEMORY=dynamic_symmetric -s -j
echo -n "Symmetric runs finished at " && date
(cd MOM6-examples; tar cf symmetric_gnu.tar `find . -name ocean.stats.gnu`)
(cd MOM6-examples; tar cf symmetric_intel.tar `find . -name ocean.stats.intel`)
(cd MOM6-examples; tar cf symmetric_pgi.tar `find . -name ocean.stats.pgi`)
EOF

echo -n "Run stage waiting for submitted job as of " && date
msub -l partition=c3,nodes=29,walltime=00:20:00,qos=norm -q debug -S /bin/tcsh -j oe -A gfdl_o -z -o job.log -N mom6_regression -K job.sh

# Show output
echo -n "Submitted job returned control at " && date
cat job.log

echo -n "Run stage finished at " && date
