# method

diagnostic: diagnostic.R
  ld: $ld
  z: $z
  ld_type: "sample", "r.IBS", "r.CLM"
  z_ld_weight: 0, 0.006667, 0.009346
  $ld_eigenval: eigenld$values
  $U1z: zcol_sub
  $U0z: znull_sub
  $Uz: Uz
  $res_simple: res1
  $res_mle: res2
