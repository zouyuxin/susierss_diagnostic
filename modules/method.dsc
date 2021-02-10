# method

diagnostic: susie_score.R + R(sc = susie_scores_multiple($(fitted), $(meta)$true_coef)) + diagnostic.R
  ld: $ld
  z: $z
  N: $N
  ld_setting: $ld_setting
  $total: sc$total
  $valid: sc$valid
  $converged: sc$converged
  $signal_pip: sc$signal_pip
  $pip: sc$pip
  $ld_eigenval: eigenld$values
  $U1z: zcol
  $U0z: znull
  $Uz: Uz
  $res1_simple: res1
  $res1_mle: res1.optim
  $res2: res2
  $res3: res3
