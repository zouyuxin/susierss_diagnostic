#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/model
%include modules/method

DSC:
  define:
    simulate: sim_gaussian_null, sim_gaussian
  run:
    default: data * simulate * get_sumstats * flip_z * susie_rss * diagnostic
  exec_path: code
  output: output/rss_diagnostic
  global:
    n_dataset: 200
    data_file: data/regions.txt
