.libPaths # see the library paths
install.packages("remotes")
remotes::install_github("r4ss/r4ss@development")
out <- r4ss::SS_output("simple_run/Simple", verbose = FALSE)
r4ss::SS_plots(out, verbose = FALSE)