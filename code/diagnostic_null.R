ld = ld[[ld_type]]
z = sumstats$betahat/sumstats$sebetahat
if(z_ld_weight > 0){
  ld = susieR:::muffled_cov2cor((1-z_ld_weight)*ld + z_ld_weight * tcrossprod(z))
  ld = (ld + t(ld))/2
}

eigenld = eigen(ld)
eigenld$values[eigenld$values < 1e-8] = 0
sample_colspace = which(eigenld$values > 0)

Uz = crossprod(eigenld$vectors, z)
zcol_sub = crossprod(eigenld$vectors[,sample_colspace], z) # U1^T z
znull_sub = crossprod(eigenld$vectors[,-sample_colspace], z) # U2^T z
s2 = sum(znull_sub^2)/length(znull_sub)

## option 1: sigma2 = 1-s2
sigma2 = 1-s2
precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))

posterior_cond = function(z, precision){
  postmean = c()
  postvar = c()
  prob = c()
  for(i in 1:length(z)){
    postmean = c(postmean, -(1/precision[i,i]) * precision[i,-i] %*% z[-i])
    postvar = c(postvar, 1/precision[i,i])
    p = pnorm(z[i], postmean[i], sd = sqrt(postvar[i]))
    prob = c(prob, min(p, 1-p)*2)
  }
  return(data.frame(z = z, postmean = postmean, postvar = postvar, prob = prob))
}

res1 = list(s2 = s2, sigma2 = sigma2, post = posterior_cond(z, precision))

## option 2: estimate sigma2

likelihood = function(sigma2, s2, y, D){
  0.5 * sum(log(sigma2 * D + s2)) + 0.5 * sum(y^2/(sigma2 * D + s2))
}

likelihood_grad = function(sigma2, s2, y, D){
  -0.5 * sum(y^2*D/((sigma2*D+s2)^2)) + 0.5 * sum(D/(sigma2 * D + s2))
}

sigma2 = optim(1-s2, fn=likelihood, gr = likelihood_grad, 
               s2=s2, y=zcol_sub, D=eigenld$values[sample_colspace], 
               method='Brent', lower=0, upper = 1-s2)$par
precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))
res2 = list(s2 = s2, sigma2 = sigma2, post = posterior_cond(z, precision))

