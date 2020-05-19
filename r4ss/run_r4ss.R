.libPaths() # see the library paths
install.packages("remotes", lib = "/usr/local/lib/R/library")
remotes::install_github("r4ss/r4ss@development", upgrade = "always", 
                        lib = "/usr/local/lib/R/library")
out <- r4ss::SS_output("simple_run/Simple", verbose = FALSE)
r4ss::SS_plots(out, verbose = FALSE)