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

