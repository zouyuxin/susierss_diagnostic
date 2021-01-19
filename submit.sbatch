#!/bin/bash

#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10G
#SBATCH --job-name=diag
#SBATCH --mail-type=BEGIN,END,FAIL

# load the openmpi module
module load R

# Run the main DSC
dsc diagnostic.dsc -s existing &> diagnostic.log
