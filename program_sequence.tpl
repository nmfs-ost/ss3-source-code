When reading the data file, keep track of data occurrence and timing with:
  4darray have_data(1,ALK_time_max,0,Nfleet,0,9,0,60);  //  this can be a i4array in ADMB 11
//    4iarray have_data(1,ALK_time_max,0,Nfleet,0,9,0,60);  //  this can be a i4array in ADMB 11

//  have_data stores the data index of each datum occurring at time ALK_time, for fleet f of observation type k.  Up to 60 data are allowed due to CAAL data
//  have_data(ALK_idx,0,0,0) is overall indicator that some datum requires ALK update in this ALK_time
//  have_data() 3rd element:  0=any; 1=survey/CPUE/effort; 2=discard; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=morphcomp; 9=tags
//  have_data() 4th element;  zero'th element contains N obs for this subseas; allows for 20 observations per datatype per fleet per subseason

  3darray data_time(1,ALK_time_max,1,Nfleet,1,3)
//  data_time():  first value will hold real month; 2nd is timing within season; 3rd is year.fraction
//  for a given fleet x subseas, all observations must have the same specific timing (month.fraction)
//  a warning will be given if subsequent observations have a different month.fraction
//  an observation's real_month is used to assign it to a season and a subseas within that seas, and it is used to calculate the data_timing within the season for mortality 

//  where ALK_idx=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas   This is index to subseas and used to indicate which ALK is being referenced

//  3darray data_ALK_time(1,Nfleet,0,9,1,<nobsperkind/fleet>)   stores ALK_time
  

And then in the time series processing:
{ loop years
  update time-varying parameters
 { loop seasons
   calc spawning biomass if in this season & distribute recruits forward to their settlement times
   update length and age selectivity if necessary
  { loop areas
    {loop fishing fleets and calculate F and Catch
     calc Z and survivors to next season
    }
  }
  call get_expected_values()
  {
    { loop sub_seasons
      if(any_data_in_this_subseason)
      {
        update mean and std.dev. of size-at-this-subseason  for each platoon
        update population age-length matrix for each platoon
        { loop all fishing and survey fleets
          if(any data for this fleet in this subseason)
          {
            recall timing = elapsed time to this observation in this season 
            recall area this fleet operates in and the numbers-at-age for each platoon in this area
            apply timing and Z to get numbers-at-age for each platoon at this point in time
            apply age and length selectivity for this fleet to get sampled numbers at age-length for each platoon
            {  loop the 9 types of data
               calc expected value for this data type summed over platoons
            }
          }
        }
      }
    }
  }  //  end calc on expected values
  if (hermaphroditism)
    {
      move fish from female platoon to corresponding male platoon on age-specific basis
    }
  if (migration)
    {
      for each platoon, move fish among areas
    }
   if (tagging data)
    {
      apply Z, F, and movement rates to the population of tags
    }

 }  //  end season loop
}  //  end year loop

