z = sumstats$betahat/sumstats$sebetahat;
idx = NA
if(flip == TRUE){
  b = meta$true_coef
  if(flip_pos == 'signal'){
    if(length(which(b!=0)) == 1){
      idx = which(b!=0)
      z[idx] = -z[idx]
    }else if(length(which(b!=0)) > 1){
      idx = sample(which(b!=0), 1)
      z[idx] = -z[idx]
    }
  }else if(flip_pos == 'null'){
    idx = sample(which(b==0), 1)
    z[idx] = -z[idx]
  }
}

## BBJ z scores
zbbj = BBJsnps$beta/BBJsnps$se
idxbbj = NA
if(flip == TRUE){
  idxbbj = sample(1:length(zbbj), 1)
  zbbj[idxbbj] = -zbbj[idxbbj]
}
