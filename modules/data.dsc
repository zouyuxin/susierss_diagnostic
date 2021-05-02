# data

data: misc.R + data.R
  tag: 'full'
  dataset: Shell{head -${n_dataset} ${data_file}}
  plinkfile: file(plink)
  $X: X
  $ld: list(sample = r.sample, IBS = r.IBS, CLM = r.CLM)
  $N: list(sample = N.GBR, IBS = N.IBS, CLM = N.CLM)
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
  BBJsnps: $BBJsnps
  meta: $meta
  (flip, flip_pos): (FALSE, "null"),(TRUE, 'null'),(TRUE, "signal")
  $z: z
  $idx: idx
  $zbbj: zbbj
  $idxbbj: idxbbj
  
data_ukb: misc.R + data_ukb.R
  dataset: Shell{head -${n_dataset} ${data_file}}
  genotype_dir: ${genotype_dir}
  gwasfile: ${gwasfile}
  gwasres: file(bbj)
  GWASsample: ${GWASsample}
  REFsample: ${REFsample}
  $X: X.sample
  $ld: list(sample = r.sample, ref = r.ref)
  $BBJsnps: BBJsnps
  
