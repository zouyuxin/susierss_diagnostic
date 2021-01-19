# model

susie_rss: susie_rss.R
  @CONF: R_libs = (susieR, data.table)
  z: $z
  L: 10
  ld: $ld
  ld_type: "sample", "r.IBS", "r.CLM"
  z_ld_weight: 0, 0.006667, 0.009346
  estimate_residual_variance: TRUE
  $fitted: res$fitted
  $posterior: res$posterior
