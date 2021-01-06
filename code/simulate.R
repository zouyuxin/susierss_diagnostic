sim_gaussian = function(X, pve, effect_num){
  n = dim(X)[1]
  p = dim(X)[2]
  
  beta.idx = sample(p, effect_num)
  beta = rep(0,p)
  beta.values = numeric(0)
  
  if(effect_num > 0){
    beta.values = rnorm(effect_num)
    beta[beta.idx] = beta.values
  }
  
  if (effect_num==1){
    mean_corX = 1
  } else {
    effectX = X[,beta.idx]
    corX = cor(effectX)
    mean_corX = mean(abs(corX[lower.tri(corX)]))
  }
  if(effect_num==0){
    resid_var = 1
    sim.y = rnorm(n, 0, 1)
    y = (sim.y - mean(sim.y))/sd(sim.y)
  } else {
    y_genetic = X %*% beta
    pheno_var = var(y_genetic) / pve
    resid_var = pheno_var - var(y_genetic)
    epsilon = rnorm(n, mean = 0, sd = sqrt(resid_var))
    y = y_genetic + + epsilon
    
    sd_y = sd(y)
    y = t(t(y) / sd_y)
    resid_var = resid_var / (sd_y^2)
    beta = beta / sd_y
  }
  
  return(list(Y = y, sigma2 = resid_var,
              beta = beta, mean_corX = mean_corX))
}
