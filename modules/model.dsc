# model

susie_rss: susie_rss.R + diagnostic.R
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  L: 10
  ld: $ld
  ld_type: "sample", "ref"
  z_ld_weight: 0, 0.0066667
  estimate_residual_variance: TRUE, FALSE
  $fitted: res$fitted
  $posterior: res$posterior
  $ld_eigenval: eigenld$values
  $U1z: zcol_sub
  $U0z: znull_sub
  $Uz: Uz
  $res_simple: res1
  $res_mle: res2


susie_rss_null: susie_rss.R + diagnostic_null.R