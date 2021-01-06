#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/model
%include modules/score

DSC:
  run:
    default: data * sim_gaussian_null * get_sumstats * susie_rss * score_susie
    signal: data * sim_gaussian * get_sumstats * susie_rss * score_susie
  exec_path: code
  output: output/rss_diagnostic_null
  global:
    n_dataset: 200
    data_file: data/regions.txt
