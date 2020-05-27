#.libPaths() # see the library paths
install.packages("remotes", lib = "/usr/local/lib/R/site-library")
remotes::install_github("r4ss/r4ss@development", upgrade = "always", 
                        lib = "/usr/local/lib/R/site-library")
						
# get model folder names
mod_names <- list.dirs("run_R/models", full.names = FALSE, recursive = FALSE)
print(mod_names)

for(i in mod_names) {
	out <- tryCatch(r4ss::SS_output(file.path("run_R", "models", i), 
	                  verbose = FALSE), 
					  error = function(e) {
					print(paste0("r4ss::SS_output with model ", i,
       					" had an error. traceback:"))
						traceback(e)
						q(status = 1)
					  }
				   )
	tryCatch(r4ss::SS_plots(out, verbose = FALSE),
			   error = function(e) {
			 print(paste0("r4ss::SS_plots with model ", i, 
			              " had an error. traceback:"))
				 traceback(e)
				 q(status = 1)
			   }
			)
	print(paste0("r4ss functions for model ", i, " completed"))
}
print("all r4ss functions completed")