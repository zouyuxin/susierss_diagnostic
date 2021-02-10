# model

susie_rss: susie_rss.R
  @CONF: R_libs = (susieR, data.table)
  z: $z
  L: 10
  ld: $ld
  N: $N
  ld_type: "sample", "IBS", "CLM"
  correct_ld: FALSE, TRUE
  estimate_residual_variance: TRUE
  $fitted: res$fitted
  $posterior: res$posterior
  $ld_setting: list(ld=ld_type, correct_ld=correct_ld)
