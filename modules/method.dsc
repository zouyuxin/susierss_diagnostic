# method

diagnostic: diagnostic.R
  ld: $ld
  z: $z
  zbbj: $zbbj
  (z_type, ld_type): ('ukb', "sample"),('ukb', "ref"), ('bbj', 'ref')
  method: 'estimates','restricted', 'pseudo', 'likelihood', 'pseudoinverse', '0.1', '0.5'
  $ld_eigenval: eigenld$values
  $res: res
