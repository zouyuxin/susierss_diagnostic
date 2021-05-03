# simulate

sim_gaussian: simulate.R + \
                R(res=sim_gaussian(X, pve, n_signal);
                meta = list();
                meta$true_coef = as.matrix(res$beta);
                meta$residual_variance = res$sigma_std)
  X: $X
  pve: 0.1
  n_signal: 1
  $Y: res$Y
  $meta: meta

sim_gaussian_null(sim_gaussian):
  n_signal: 0
  
sim_gaussian_ukb(sim_gaussian):
  pve: 0.02
  