#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/method

DSC:
  define:
    simulate: sim_gaussian_null, sim_gaussian_ukb
  run:
    default: data_ukb * simulate * get_sumstats * flip_z * diagnostic
  exec_path: code
  output: output/rss_diagnostic_ukb
  global:
    n_dataset: 200
    data_file: data/regions.txt
    genotype_dir: '/project2/mstephens/yuxin/ukb-bloodcells/genotypes/'
    gwasfile: 'data/BBJ.WBC.autosome.txt.gz'
    GWASsample: 10000
    REFsample: 1000

