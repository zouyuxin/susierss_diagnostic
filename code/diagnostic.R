library(mixsqp)
ld = ld[[ld_type]]

if(z_type == 'ukb'){
  z = z
}else if(z_type == 'bbj'){
  z = zbbj
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
  post_z = (z-postmean)/sqrt(postvar)
  
  a_min = 0.8
  if(max(post_z^2) < 1){
    a_max = 2
  }else{
    a_max = 2*sqrt(max(post_z^2))
  }
  npoint = ceiling(log2(a_max/a_min)/log2(1.05))
  a_grid = 1.05^((-npoint):0) * a_max
  sd_mtx = outer(sqrt(postvar), a_grid)
  matrix_llik = dnorm(z - postmean, sd=sd_mtx, log=T)
  lfactors    <- apply(matrix_llik,1,max)
  matrix_llik <- matrix_llik - lfactors
  w = mixsqp(matrix_llik, log=T, control = list(verbose=FALSE))$x
  
  logl0mix = as.numeric(log(exp(matrix_llik) %*% w)) + lfactors
  matrix_llik = dnorm(z + postmean, sd=sd_mtx, log=T)
  lfactors    <- apply(matrix_llik,1,max)
  matrix_llik <- matrix_llik - lfactors
  logl1mix = as.numeric(log(exp(matrix_llik) %*% w)) + lfactors
  logLRmix = logl1mix - logl0mix
  postvar_mix = (sd_mtx^2) %*% w
  
  return(list(z = z, postmean = postmean, postvar = postvar, post_z = post_z, 
                    logl0 = logl0, logl1 = logl1, logLR = logLR, 
                    w = w, postvarmix = postvar_mix,
                    logl0mix = logl0mix, logl1mix = logl1mix, logLRmix = logLRmix))
}

if(method == 'estimates'){
  Uz = crossprod(eigenld$vectors, z)
  zcol = crossprod(eigenld$vectors[,colspace], z) # U1^T z
  znull = crossprod(eigenld$vectors[,-colspace], z) # U2^T z
  
  sest = sum(znull^2)/length(znull)
  if(length(colspace) == length(z)){
    sest = 0
  }
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/(eigenld$values + sest)))
  res = list(s = sest, post = posterior_cond(z, precision))
}else if(method == 'restricted'){
  Uz = crossprod(eigenld$vectors, z)
  zcol = crossprod(eigenld$vectors[,colspace], z) # U1^T z
  znull = crossprod(eigenld$vectors[,-colspace], z) # U2^T z
  
  sest = sum(znull^2)/length(znull)
  s = min(sest, 1)
  if(length(colspace) == length(z)){
    s = 0
    precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/eigenld$values))
    res = list(s = 0, post = posterior_cond(z, precision))
  }else{
    precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
    res = list(s = s, post = posterior_cond(z, precision))
  }
}else if(method == 'pseudo'){
  pseudolikelihood = function(s, z, eigenld){
    precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
    postmean = c()
    postvar = c()
    for(i in 1:length(z)){
      postmean = c(postmean, -(1/precision[i,i]) * precision[i,-i] %*% z[-i])
      postvar = c(postvar, 1/precision[i,i])
    }
    -sum(dnorm(z, mean=postmean, sd = sqrt(postvar), log=T))
  }
  s = optim(0.5, fn=pseudolikelihood,
             z=z, eigenld=eigenld,
             method = 'Brent', lower=0, upper=1)$par
  s = min(s, 1)
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
  res = list(s = s, post = posterior_cond(z, precision))
}else if(method == 'likelihood'){
  negloglikelihood = function(s, z, eigenld){
    0.5 * sum(log((1-s)*eigenld$values+s)) + 
      0.5 * sum(z * eigenld$vectors %*% ((t(eigenld$vectors) * (1/((1-s)*eigenld$values + s))) %*% z))
  }
  s = optim(0.5, fn=negloglikelihood,
             z=z, eigenld=eigenld,
             method = 'Brent', lower=0, upper=1)$par
  s = min(s, 1)
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
  res = list(s = s, post = posterior_cond(z, precision))
}else if(method == 'pseudoinverse'){
  dinv = 1/eigenld$values
  dinv[which(is.infinite(dinv))] = 0
  precision = eigenld$vectors %*% (t(eigenld$vectors) * dinv)
  res = list(post = posterior_cond(z, precision))
}else if(method == '0.1'){
  s = 0.1
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
  res = list(s = s, post = posterior_cond(z, precision))
}else if(method == '0.5'){
  s = 0.5
  precision = eigenld$vectors %*% (t(eigenld$vectors) * (1/((1-s)*eigenld$values + s)))
  res = list(s = s, post = posterior_cond(z, precision))
}



















