library(susieR)

susie_rss_analyze = function(z, R, L, z_ld_weight, estimate_residual_variance) {
  fit = tryCatch(susie_rss(z, R, L=L,z_ld_weight=z_ld_weight,
                           estimate_residual_variance = estimate_residual_variance,
                           max_iter = 200),
                 error = function(e) list(sets = NULL, pip=NULL))
  return(fit)
}

susie_rss_multiple = function(Z, R, L, z_ld_weight, estimate_residual_variance) {
  fitted = list()
  posterior = list()
  if (is.null(dim(Z))) Z = matrix(ncol=1, Z)
  for (r in 1:ncol(Z)) {
    fitted[[r]] = susie_rss_analyze(Z[,r], R, L, z_ld_weight,
                                    estimate_residual_variance)
    if(is.null(fitted[[r]]$sets))
      posterior[[r]] = NULL
    else
      posterior[[r]] = summary(fitted[[r]])
  }
  return(list(fitted=fitted, posterior=posterior))
}

library(data.table);
r = ld[[ld_type]]
if(correct_ld){
  N = N[[ld_type]]
  z_ld_weight = 1/N
}else{
  z_ld_weight = 0
}

res = susie_rss_multiple(z, r, L, z_ld_weight, estimate_residual_variance)

