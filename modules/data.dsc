# data

data: misc.R + data.R
  tag: 'full'
  dataset: Shell{head -${n_dataset} ${data_file}}
  plinkfile: file(plink)
  $X: X
  $ld: list(sample = r.sample, r.IBS = r.IBS, r.CLM = r.CLM)
  $r_IBS_2norm: r.IBS.2dist
  $r_CLM_2norm: r.CLM.2dist
  $r_IBS_maxnorm: r.IBS.Mdist
  $r_CLM_maxnorm: r.CLM.Mdist
  
get_sumstats: R(res = susieR:::univariate_regression(X, Y))
  X: $X
  Y: $Y
  $sumstats: res
  
flip_z: flip.R
  sumstats: $sumstats
  meta: $meta
  (flip, flip_pos): (FALSE, "null"),(TRUE, "signal"),(TRUE, "null")
  $z: z
  $idx: idx
  
  