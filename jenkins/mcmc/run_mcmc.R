# Run NUTS algorithim in ADMB to make sure still works with stock synthesis

# run the simple model with -hbf option to get the necessary files
system("./ss -hbf")
# run the simple model 30 times using the NUTS algorithim
niters <- 100
for (i in 1:niters) {
  message("Running iteration ", i)
  # run simple model
  system("./ss  -maxfn 0 -phase 40 -nohess -mcmc 10 -nuts -mcseed 1 -max_treedepth 3")
  # read in adaption.csv
  adapt_df <- read.csv("adaptation.csv")
  if(i == 1) {
    compare_val <- adapt_df[nrow(adapt_df), "stepsize__"]
    message("Getting ref value from iteration ", i, ". Ref value is " , 
            compare_val)
  } else {
    message("Checking iteration ", i)
    val_to_check <- adapt_df[nrow(adapt_df), "stepsize__"]
  	if(!identical(val_to_check, compare_val)) {
      stop("First step size for iteration ", i ," (step size =", 
           val_to_check,
           ")", " was not equal to values in the first iteration (",
           compare_val, ").")
  	}
  }
}
message("No differences in step size among stock synthesis runs.")