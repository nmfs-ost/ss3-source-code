# code to run the ss_new models

mod_names <- list.dirs("run_R/model_runs", full.names = FALSE, recursive = FALSE)
mod_paths <- list.dirs("run_R/model_runs", full.names = TRUE, recursive = FALSE)
print(mod_names)

run_ssnew <- function(dir) {
  wd <- getwd()
  print(wd)
  on.exit(system(paste0("cd ", wd)))
  # delete old starter files, rename forecast.ss_new and starter.ss_new files
  file.remove(file.path(dir, "starter.ss"))
  file.remove(file.path("forecast.ss"))
  file.rename(file.path(dir, "starter.ss_new"), file.path(dir,"starter.ss"))
  file.rename(file.path(dir, "forecast.ss_new"), file.path(dir,"forecast.ss"))
  # rename control and data files to standardized names (from the starter files)
  start <- readLines(file.path(dir, "starter.ss"))
  first_val_line <- grep("0=use init values in control file", start, fixed = TRUE)
  datname <- start[first_val_line-2]
  ctlname <- start[first_val_line-1]
  print(datname)
  print(ctlname)
  file.remove(file.path(dir, datname))
  file.remove(file.path(dir, ctlname))
  file.rename(file.path(dir,"data.ss_new"), file.path(dir, datname))
  file.rename(file.path(dir, "control.ss_new"), file.path(dir, ctlname))
  # run the models without estimation
  file.remove(file.path(dir, "Report.sso"))
  # see if model finishes without error
  system(paste0("cd ", dir, " && ../ss -stopph 0 -nohess")) # may need to change path to ss exe
  model_ran <- file.exists(file.path(dir, "control.ss_new"))
  return(model_ran)
}

mod_ran <- lapply(mod_paths, function(x) tryCatch(run_ssnew(x), 
                                       error = function(e) print(e)
                                       )
           )
mod_errors <- mod_names[unlist(lapply(mod_ran, function(x) "simpleError" %in% class(x)))]
success <- TRUE
if(length(mod_errors) > 0) {
  message("Model code with errors were: ", paste0(mod_errors, collapse = ", "), 
          ". See error list above for more details.")
  success <- FALSE
} else {
  message("All code ran without error, but model runs may still have failed.")
}
mod_no_run <- mod_names[unlist(lapply(mod_ran, function(x) isFALSE(x)))] #false means model didn't run
if(length(mod_no_run) > 0) {
  message("Models that didn't run are ", paste0(mod_no_run, collapse = ", "))
  success <- FALSE
} else {
  message("All models ran without error.")
}

# determine if job fails or passes
if(success == FALSE) {
  stop("Job failed due to code with errors or models that didn't run.")
} else {
  message("Job passed! All models successfully ran.")
}