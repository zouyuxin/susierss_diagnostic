# data

data: misc.R + data.R
  tag: 'full'
  dataset: Shell{head -${n_dataset} ${data_file}}
  plinkfile: file(plink)
  $X: X
  $ld: list(sample = r.sample, ref = r.ref)
  $r_2norm: r.2dist
  $r_maxnorm: r.Mdist
  
get_sumstats: R(res = susieR:::univariate_regression(X, Y))
  X: $X
  Y: $Y
  $sumstats: res