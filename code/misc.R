filter_X <- function(X, missing_rate_thresh, maf_thresh) {
  rm_col <- which(apply(X, 2, compute_missing) > missing_rate_thresh)
  if (length(rm_col)) X <- X[, -rm_col]
  rm_col <- which(apply(X, 2, compute_maf) < maf_thresh)
  if (length(rm_col)) X <- X[, -rm_col]
  X <- mean_impute(X)
  rm_col <- which(apply(X, 2, is_zero_variance))
  if (length(rm_col)) X <- X[, -rm_col]
  return(X)
}

compute_maf <- function(geno){
  f <- mean(geno,na.rm = TRUE)/2
  return(min(f, 1-f))
}

compute_missing <- function(geno){
  miss <- sum(is.na(geno))/length(geno)
  return(miss)
}

mean_impute <- function(geno){
  f <- apply(geno, 2, function(x) mean(x,na.rm = TRUE))
  for (i in 1:length(f)) geno[,i][which(is.na(geno[,i]))] <- f[i]
  return(geno)
}

is_zero_variance <- function(x) {
  if (length(unique(x[!is.na(x)]))==1) return(T)
  else return(F)
}

get_genotype <- function(k,n,pos=NULL) {
  if (is.null(k)) {
    return(1:n)
  }
  if(is.null(pos)){
    ## For given number k, get the range k surrounding n/2
    ## but have to make sure it does not go over the bounds
    start = floor(n/2 - k/2)
    end = ceiling(n/2 + k/2)
  }else{
    start = floor(pos - k/2)
    end = ceiling(pos + k/2)
  }
  if (start<1) start = 1
  if (end>n) end = n
  return(start:end)
}

center_scale <- function(X){
  X = susieR:::set_X_attributes(as.matrix(X), center=TRUE, scale = TRUE)
  return(t( (t(X) - attr(X, "scaled:center")) / attr(X, "scaled:scale")  ))
}

