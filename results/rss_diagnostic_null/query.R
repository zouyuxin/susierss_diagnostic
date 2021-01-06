output_dir = '../../output/rss_diagnostic_null'
output = 'susierss_diagnostic_null_query.rds'

library(tibble)
out = dscrutils::dscquery(output_dir,
                          targets = c("data.dataset",
                                      "data.r_2norm", "data.r_maxnorm",
                                      "susie_rss.ld_type",'susie_rss.z_ld_weight',
                                      'susie_rss.estimate_residual_variance',
                                      'susie_rss.ld_eigenval', 'susie_rss.U1z', 'susie_rss.U0z','susie_rss.Uz',
                                      "susie_rss.res_simple", "susie_rss.res_mle",
                                      'susie_rss',
                                      "score_susie.total", "score_susie.valid",
                                      "score_susie.size", "score_susie.purity", 
                                      "score_susie.avgr2",
                                      "score_susie.top", "score_susie.converged","score_susie.objective",
                                      "score_susie.overlap", "score_susie.signal_pip", "score_susie.pip"),
                          module.output.files = "susie_rss")

saveRDS(out, output)

