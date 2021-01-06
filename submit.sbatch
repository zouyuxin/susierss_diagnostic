#!/bin/bash

#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=3000
#SBATCH --job-name=dsc_rss_diagnostic
#SBATCH --mail-type=BEGIN,END,FAIL

# load the openmpi module
module load R

dsc diagnostic.dsc --host yuxin_midway.yml -c 4 &> diagnostic.null.job.log
