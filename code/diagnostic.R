ld_type = ld_setting$ld
ld = ld[[ld_type]]
if(ld_setting$correct_ld){
  N = N[[ld_type]]
  z_ld_weight = 1/N
  ld = susieR:::muffled_cov2cor((1-z_ld_weight)*ld + z_ld_weight * tcrossprod(z))
  ld = (ld + t(ld))/2
}

eigenld = eigen(ld)
eigenld$values[eigenld$values < 1e-8] = 0
colspace = which(eigenld$values > 0)

posterior_cond = function(z, precision){
  postmean = c()
  postvar = c()
  for(i in 1:length(z)){
    postmean = c(postmean, -(1/precision[i,i]) * precision[i,-i] %*% z[-i])
    postvar = c(postvar, 1/precision[i,i])
  }
  prob = pnorm(z, postmean, sd = sqrt(postvar))
  prob = pmin(prob, 1-prob)*2
  logl0 = dnorm(z, postmean, sd = sqrt(postvar), log = T)
  logl1 = dnorm(-z, postmean, sd = sqrt(postvar), log = T)
  logLR = logl1 - logl0
  return(data.frame(z = z, postmean = postmean, postvar = postvar, post_z = (z-postmean)/sqrt(postvar), 
                    logl0 = logl0, logl1 = logl1, logLR = logLR, prob = prob))
}

Uz = crossprod(eigenld$vectors, z)
zcol = crossprod(eigenld$vectors[,colspace], z) # U1^T z
znull = crossprod(eigenld$vectors[,-colspace], z) # U2^T z

## 1. standard
s2 = sum(znull^2)/length(znull)
### option 1: sigma2 = 1-s2
if(length(colspace) == length(z)){
  s2 = 0
  sigma2 = 1
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))
  res1 = list(s2 = s2, sigma2 = sigma2,
              post = posterior_cond(z, precision))
}else{
  sigma2 = 1-s2
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))
  res1 = list(s2 = s2, sigma2 = sigma2,
              post = posterior_cond(z, precision))
}

## option 2: estimate sigma2
likelihood = function(sigma2, s2, y, D){
  0.5 * sum(log(sigma2 * D + s2)) + 0.5 * sum(y^2/(sigma2 * D + s2))
}

likelihood_grad = function(sigma2, s2, y, D){
  -0.5 * sum(y^2*D/((sigma2*D+s2)^2)) + 0.5 * sum(D/(sigma2 * D + s2))
}

sigma2 = optim(1-s2, fn=likelihood, gr = likelihood_grad, 
               s2=s2, y=zcol, D=eigenld$values[colspace], 
               method='Brent', lower=0, upper = 1-s2)$par
precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))
res1.optim = list(s2 = s2, sigma2 = sigma2,
                  post = posterior_cond(z, precision))

## 2. truncated 
s2 = max(0.005, s2)
sigma2 = 1-s2
precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(sigma2*eigenld$values + s2)))
res2 = list(s2 = s2, sigma2 = sigma2, post = posterior_cond(z, precision))

## 3. pseudo likelihood
pseudolikelihood = function(s2, z, eigenld){
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s2)*eigenld$values + s2)))
  postmean = c()
  postvar = c()
  for(i in 1:length(z)){
    postmean = c(postmean, -(1/precision[i,i]) * precision[i,-i] %*% z[-i])
    postvar = c(postvar, 1/precision[i,i])
  }
  -sum(dnorm(z, mean=postmean, sd = sqrt(postvar), log=T))
}
s2 = optim(res1$s2, fn=pseudolikelihood,
           z=z, eigenld=eigenld,
           method = 'Brent', lower=0, upper=1)$par
precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s2)*eigenld$values + s2)))
res3 = list(s2 = s2, sigma2 = 1-s2, post = posterior_cond(z, precision))



