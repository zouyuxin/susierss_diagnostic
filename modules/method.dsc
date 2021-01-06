# method

diagnostic: diagnostic.R
  ld: $ld
  sumstats: $sumstats
  ld_type: 'sample', 'ref'
  $ld_eigenval: eigenld$values
  $U1z: zcol_sub
  $U0z: znull_sub
  $Uz: Uz
  $res_simple: res1
  $res_mle: res2
