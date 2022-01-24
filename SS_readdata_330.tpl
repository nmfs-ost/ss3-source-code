// SS_Label_file  #3. **SS_readdata.tpl**
// SS_Label_file  # * read *data_file* named in starter.ss
// SS_Label_file  #     * create arrays for data with dimensioning defined dynamically
// SS_Label_file  #     * creates link from each data element to area/time/fleet that datum occur, and other arrays with specification of which data types occur in each area/time
// SS_Label_file  #     * uses function found in SS_global:  <u>get_data_timing()</u>
// SS_Label_file  # * read *forecast.ss*
// SS_Label_file  #     * note that this extends the time dimension of some arrays, so is read before readcontrol

//  SS_Label_Flow  read data file named in starter.ss file
//  SS_Label_Info_2.0 #READ DATA FILE
//  SS_Label_Info_2.1 #Read comments and dimension info
//  SS_Label_Info_2.1.1 #Read and save comments at top of data file
  number fif  //  end of file marker

 LOCAL_CALCS
  ad_comm::change_datafile_name(datfilename);
  if(finish_starter==999)
  {N_warn++;  warning<<N_warn<<" "<<"finish_starter=999, so probably used a 3.24 starter.ss; please update"<<endl; finish_starter=3.30;  }
  cout<<" reading from data file"<<endl;
  ifstream Data_Stream(datfilename);   //  even if the global_datafile name is used, there still is a different logical device created
  k=0;
  N_DC=0;
  while(k==0)
  {
    Data_Stream >>  readline;          // reads the line from input stream
    if(length(readline)>2)
    {
      checkchar=readline(1);
      k=strcmp(checkchar,"#");
      checkchar=readline(1,2);
      j=strcmp(checkchar,"#C");
      if(j==0) {N_DC++; Data_Comments+=readline;}
    }
  }
 END_CALCS

!!//  SS_Label_Info_2.1.2 #Read model time dimensions
  int read_seas_mo    //  1=read integer season; 2=read real months
 LOCAL_CALCS
   read_seas_mo=2;
 END_CALCS


  int N_subseas  //  number of subseasons within season; must be even number to get one to be mid_season
  ivector timing_constants(1,6)
 LOCAL_CALCS
  *(ad_comm::global_datafile) >> styr;  //start year of the model
  echoinput<<styr<<" start year "<<endl;

  *(ad_comm::global_datafile) >> endyr; // end year of the model
  echoinput<<endyr<<" end year "<<endl;

  *(ad_comm::global_datafile) >> nseas;  //  number of seasons
  echoinput<<nseas<<" N seasons "<<endl;
 END_CALCS
  init_vector seasdur(1,nseas);  // season duration; enter in units of months, fractions OK; will be rescaled to sum to 1.0 if total is greater than 11.9

 LOCAL_CALCS
  echoinput<<seasdur<<" months/seas (fractions OK) "<<endl;
  *(ad_comm::global_datafile) >> N_subseas;
  echoinput<<N_subseas<<" Number of subseasons (even number only; min 2) for calculation of ALK "<<endl;
  mid_subseas=N_subseas/2 + 1;
  timing_constants(1)=read_seas_mo;
  timing_constants(2)=nseas;
  timing_constants(3)=N_subseas;
  timing_constants(4)=mid_subseas;
  timing_constants(5)=styr;
  timing_constants(6)=endyr;
 END_CALCS

  int TimeMax
  int TimeMax_Fcast_std
  int ALK_time_max
  int eq_yr;
  int bio_yr;
  number sumseas;

  //  SS_Label_Info_2.1.3 #Set up seasons
  vector seasdur_half(1,nseas)   // half a season
  matrix subseasdur(1,nseas,1,N_subseas)   // cumulative time, within season, for each subseas
  vector subseasdur_delta(1,nseas)  //  length of each subseason
  vector azero_seas(1,nseas);   // cumulative time, within year, up until begin of this season

 LOCAL_CALCS
  sumseas=sum(seasdur);
  if(sumseas>=11.9)
    {
      seasdur /=sumseas;
      seas_as_year=0;
      sumseas=12.0;  // to be sure it is exactly 12.
    }
  else
    {
      seasdur /=12.;
      seas_as_year=1;
      //  sumseas will now be used as the duration of the pseudo-year, rather than assuming year has 12 months;
      if(nseas>1) { N_warn++; cout<<"exit with warning"<<endl;  warning<<N_warn<<" "<<"Error.  Can only have 1 season when during seasons as psuedo-years."<<endl;  exit(1);}
    }
  seasdur_half = seasdur*0.5;   // half a season
  subseasdur_delta=seasdur/double(N_subseas);
  TimeMax = styr+(endyr+50-styr)*nseas+nseas-1;
  retro_yr=endyr+retro_yr;
  ALK_time_max=(endyr-styr+51)*nseas*N_subseas;  //  sets maximum size for data array indexing 50 years into forecast
//  ALK_time_max will be redefined after reading forecast's YrMax to accomodate forecasts longer than the 50 year data limit

  azero_seas(1)=0.;
  if(nseas>1)
    for (s=2;s<=nseas;s++)  /* SS_loop: calculate azero_seas from cumulative sum of seasdur(s) */
    {azero_seas(s)=sum(seasdur(1,s-1));}
  subseasdur.initialize();
  for (s=1;s<=nseas;s++)  /* SS_loop: for each season */
  {
    for (subseas=2;subseas<=N_subseas;subseas++)  /* SS_loop: calculate cumulative time within season to start of each subseas */
    {
      subseasdur(s,subseas)=subseasdur(s,subseas-1)+seasdur(s)/double(N_subseas);
    }
  }
  echoinput<<seasdur<<" processed season duration (frac. of year) "<<endl;
  echoinput<<subseasdur_delta<<" processed subseason duration (frac. of year) "<<endl;
  echoinput<<" processed subseason cumulative annual time within season "<<endl<<subseasdur<<endl;
  if(seas_as_year==1)
    {
      echoinput<<"Season durations sum to <11.9, so SS3 assumes you are doing years as pseudo-seasons."<<endl<<
      "There can be only 1 season in this timestep and SS3 will ignore month input and assume all observation occur at middle of this pseudo-year"<<endl<<
      "mortality, growth and movement rates are per annum, so will get multiplied by the duration of this timestep as they are used."<<endl<<
      "What gets reported as age is now age in timesteps; and input of age-specific M or K requires one entry per timestep"<<endl<<
      "Similarly, output of age-specific quantities is in terms of number of timesteps, not real years"<<endl<<
      "spawn_month and settlement_month in control file are best set to 1.0 when doing years as pseudo-seasons"<<endl;
      N_warn++;
       warning<<N_warn<<" "<<"Season durations sum to <11.9, so SS3 assumes you are doing years as pseudo-seasons."<<endl<<
      "There can be only 1 season in this timestep and SS3 will ignore month input and assume all observation occur at middle of this pseudo-year"<<endl<<
      "mortality, growth and movement rates are per annum, so will get multiplied by the duration of this timestep as they are used."<<endl<<
      "What gets reported as age is now age in timesteps; and input of age-specific M or K requires one entry per timestep"<<endl<<
      "Similarly, output of age-specific quantities is in terms of number of timesteps, not real years"<<endl<<
      "spawn_month and settlement_month in control file are best set to 1.0 when doing years as pseudo-seasons"<<endl;
    }

 END_CALCS

//  SPAWN-RECR:   define spawning season
  init_number spawn_rd
   number spawn_month  //  month that spawning occurs
   int spawn_seas    //  spawning occurs in this season
   int spawn_subseas  //
   number spawn_time_seas  //  real time within season for mortality calculation
 LOCAL_CALCS
  if(read_seas_mo==1)  //  so reading values of integer season
    {
      spawn_seas=spawn_rd;
      spawn_month=1.0 + azero_seas(spawn_seas)/sumseas;
      spawn_subseas=1;
      spawn_time_seas=0.0;
    }
  else  //  reading values of month
    {
      spawn_month=spawn_rd;
      temp1=(spawn_month-1.0)/sumseas;  //  spawn_month as fraction of year
      spawn_seas=1;  // earlist possible spawn_seas;
      spawn_subseas=1;  //  earliest possible subseas in spawn_seas
      temp=azero_seas(spawn_seas)+subseasdur_delta(spawn_seas);  //  starting value
      while(temp<=temp1+1.0e-9)
      {
        if(spawn_subseas==N_subseas)
          {spawn_seas++; spawn_subseas=1;}
          else
          {spawn_subseas++;}
          temp+=subseasdur_delta(spawn_seas);
      }
      spawn_time_seas=(temp1-azero_seas(spawn_seas))/seasdur(spawn_seas);  //  remaining fraction of year converted to fraction of season
    }
   echoinput<<"SPAWN month: "<<spawn_month<<"; seas: "<<spawn_seas<<"; subseas_for_ALK: "<<spawn_subseas<<"; timing_in_season: "<<spawn_time_seas<<endl;
   if(spawn_seas>nseas)
   {
     N_warn++;  warning<<N_warn<<" spawn_seas index must be <= nseas "<<endl;
   }
 END_CALCS
  int pop   // number of areas
  int gender_rd
  int gender  //  number of sexes
  int nages  //  maxage as accumulator
  int nages2  //  doubled vector to store males after females = gender*nages+gender-1
  int Nsurvey
  int Nfleet
  int Nfleet1  // used with 3.24 for number of fishing fleets

 LOCAL_CALCS
  {
    *(ad_comm::global_datafile) >> gender_rd;
    gender=abs(gender_rd);
    if(gender_rd<0) echoinput<<"gender read is negative, so total spawnbiomass will be multiplied by frac_female parameter"<<endl;
    *(ad_comm::global_datafile) >> nages;
    echoinput<<gender<<" N sexes "<<endl<<"Accumulator age "<<nages<<endl;
    *(ad_comm::global_datafile) >> pop;
    echoinput<<pop<<" N_areas "<<endl;
    *(ad_comm::global_datafile) >> Nfleet;
    Nfleet1=0;
    Nsurvey=0;
    nages2=gender*nages+gender-1;
    echoinput<<Nfleet<<" total number of fishing fleets and surveys "<<endl;
  }
 END_CALCS

//  SS_Label_Info_2.1.5  #Define fleets, surveys and areas
  imatrix pfleetname(1,Nfleet,1,2)
  ivector fleet_type(1,Nfleet)   // 1=fleet with catch; 2=discard only fleet with F; 3=survey(ignore catch); 4=M2=predator
  int N_bycatch;  //  number of bycatch only fleets
  int N_pred;  //  number of predator fleets
  ivector N_catchfleets(0,pop); //  number of bycatch plus landed catch fleets by area
  imatrix fish_fleet_area(0,pop,0,Nfleet)   // list of catch_fleets that are type 1 or 2, so have a F
  ivector predator(1,Nfleet)   // list of "fleets" that are type 4, so are added to M rather than to F
  ivector predator_rev(1,Nfleet)   // predator given f
  ivector need_catch_mult(1,Nfleet)  // 0=no, 1=need catch_multiplier parameter
  vector surveytime(1,Nfleet)   // (-1, 1) code for fisheries to indicate use of season-wide observations, or specifically timed observations
  ivector fleet_area(1,Nfleet)    // areas in which each fleet/survey operates
  vector catchunits1(1,Nfleet)  // 1=biomass; 2=numbers
//  vector catch_se_rd1(1,Nfleet)  // units are se of log(catch); use -1 to ignore input catch values for discard only fleets
  vector catchunits(1,Nfleet)
//  vector catch_se_rd(1,Nfleet)
  matrix catch_se(styr-nseas,TimeMax,1,Nfleet);
  matrix fleet_setup(1,Nfleet,1,5)  // type, timing, area, units, need_catch_mult
  matrix bycatch_setup(1,Nfleet,1,6)
    // 1:  fleet number; must match fleet definitions"<<endl;
    // 2:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)"<<endl;
    // 3:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=mean bycatch F from range of years"<<endl;
    // 4:  F or first year of range"<<endl;
    // 5:  last year of range"<<endl;
    // 6:  not used"<<endl;

  ivector YPR_mask(1,Nfleet)
  ivector retParmLoc(1,1)
  int N_retParm

 LOCAL_CALCS
  bycatch_setup.initialize();
  YPR_mask.initialize();
  catch_se=0.01;  //  initialize to a small value
  {
    N_bycatch=0;
    N_catchfleets.initialize();
    fish_fleet_area.initialize();
    N_pred=0;
    predator.initialize();
    echoinput<<"rows are fleets; columns are: Fleet_#, fleet_type, timing, area, units, need_catch_mult"<<endl;
    for(f=1;f<=Nfleet;f++)
    {
      *(ad_comm::global_datafile) >> fleet_setup(f)(1,5);
      *(ad_comm::global_datafile) >> anystring;
      fleetname+=anystring;
      fleet_type(f) = int(fleet_setup(f,1));
      if(fleet_type(f)==2) N_bycatch++;
      surveytime(f) = fleet_setup(f,2)/fabs(fleet_setup(f,2));
      fleet_setup(f,2)=surveytime(f);
      p=int(fleet_setup(f,3));  //area
      fleet_area(f)=p;
      catchunits(f) = int(fleet_setup(f,4));
      need_catch_mult(f) = int(fleet_setup(f,5));
      if(fleet_type(f)<=2)
        {
          N_catchfleets(0)++;  //  overall N
          N_catchfleets(p)++;  //  count by area
          fish_fleet_area(0,N_catchfleets(0))=f;  //  to find the original fleet index
          fish_fleet_area(p,N_catchfleets(p))=f;  //  to find the original fleet index
          YPR_mask(f)=1;
          if(surveytime(f)!=-1.)
          {N_warn++;  warning<<N_warn<<" "<<"fishing fleet: "<<f<<" surveytime read as: "<<surveytime(f)<<" normally is -1 for fishing fleet; can override for indiv. obs. using 1000+month"<<endl;}
        }
        else if (fleet_type(f)==3)
          {if(surveytime(f)==-1.)
          {N_warn++;  warning<<N_warn<<" "<<"survey fleet: "<<f<<" surveytime read as: "<<surveytime(f)<<" SS3 resets to 1 for all survey fleets, and always overridden by indiv. obs. month"<<endl;
            surveytime(f)=1.;}
          }
        else if (fleet_type(f)==4)  //  predator, e.g. red tide
          {
            N_pred++;
            predator(N_pred)=f;
            predator_rev(f)=N_pred;
            surveytime(f)=-1.;
          }
      if(fleet_type(f)>1 && need_catch_mult(f)>0)
        {N_warn++; cout<<"exit with warning"<<endl; warning<<N_warn<<" "<<"Need_catch_mult can be used only for fleet_type=1 fleet= "<<f<<endl; exit(1);}
      echoinput<<f<<" # "<<fleet_setup(f)<<" # "<<fleetname(f)<<endl;
      if(f>1){  // check for duplicate fleet names, which will break r4ss
      	for(int f1=1;f1<f;f1++){
      		if(fleetname(f1)==fleetname(f)){
      			N_warn++; cout<<"exit with warning"<<endl;
      			warning<<N_warn<<" duplicate fleet names for fleets: "<<f1<<" and "<<f<<"; "<<fleetname(f)<<"; SS3 will exit"<<endl; exit(1);
      		}
      	}
      }
    }

    if(N_bycatch>0)
    {
      echoinput<<"Now read bycatch fleet characteristics for "<<N_bycatch<<" fleets"<<endl;
    echoinput<<"1:  fleet number; must match fleet definitions"<<endl;
    echoinput<<"2:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)"<<endl;
    echoinput<<"3:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=mean bycatch F from range of years"<<endl;
    echoinput<<"4:  F or first year of range"<<endl;
    echoinput<<"5:  last year of range"<<endl;
    echoinput<<"6:  not used"<<endl;
       for(j=1;j<=N_bycatch;j++)
      {
        *(ad_comm::global_datafile) >> f;
        bycatch_setup(f,1)=f;
        *(ad_comm::global_datafile) >> bycatch_setup(f)(2,6);
        if(fleet_type(f)==2)
        {
          echoinput<<f<<" "<<fleetname(f)<<" bycatch_setup: "<<bycatch_setup(f)<<endl;
          if(bycatch_setup(f,2)==2)  //  omit bycatch fleet catch from YPR optimize
          {
            YPR_mask(f)=0;
          }
          if(bycatch_setup(f,3)==3)  //  check year range
          {
            if(bycatch_setup(f,4)<styr)  bycatch_setup(f,4)=styr;
            if(bycatch_setup(f,5)>retro_yr)  bycatch_setup(f,5)=retro_yr;
          }
        }
        else
        {
          N_warn++; cout<<"exit with warning"<<endl;  warning<<N_warn<<" "<<"fleet "<<f<<" is in bycatch list but not designated as bycatch fleet"<<endl; exit(1);
        }
      }
    }
    echoinput<<"YPR_optimize_mask: "<<YPR_mask<<endl;
    Nfleet1 = N_catchfleets(0);
    N_retParm=0;
  }
 END_CALCS

//  ProgLabel_2.1.5  define genders and max age

  ivector     age_vector(0,nages)
  vector      r_ages(0,nages)
  vector frac_ages(0,nages)
  ivector     years(styr,endyr) // vector of the years of the model
  vector    r_years(styr,endyr);
  ivector ALK_subseas_update(1,nseas*N_subseas);  //  0 means ALK is OK for this subseas, 1 means that recalc is needed

  ivector F_reporting_ages(1,2);

 LOCAL_CALCS
  for (a=0;a<=nages;a++) age_vector(a) = a; /* SS_loop: fill ivector age vector */
  for (a=0;a<=nages;a++) r_ages(a) = double(a); /* SS_loop: fill real vector r_ages */
  frac_ages=r_ages/r_ages(nages);
  for (y=styr;y<=endyr;y++) {years(y)=y; r_years(y)=y;}    //year vector
  if (F_reporting==4 || F_reporting==5)
  {
    F_reporting_ages=F_reporting_ages_R;
    if(F_reporting_ages(1)>(nages-2) || F_reporting_ages(1)<0)
    {N_warn++;  warning<<N_warn<<" reset lower end of F_reporting_ages to be nages-2  "<<endl; F_reporting_ages(1)=nages-2;}
    if(F_reporting_ages(2)>(nages-2) || F_reporting_ages(2)<0)
    {N_warn++;  warning<<N_warn<<" reset upper end of F_reporting_ages to be nages-2  "<<endl; F_reporting_ages(2)=nages-2;}
  }
  else
  {
    F_reporting_ages(1)=nages/2;
    F_reporting_ages(2)=F_reporting_ages(1);
  }
 END_CALCS

//  SS_Label_Info_2.1.6  #Indexes for data timing.  "have_data" and "data_time" hold pointers for data occurrence, timing, and ALK need
  int data_type
  number data_timing
  4iarray have_data(1,ALK_time_max,0,Nfleet,0,9,0,100);
  imatrix have_data_yr(styr,endyr+50,0,Nfleet)

//  have_data stores the data index of each datum occurring at time ALK_time, for fleet f of observation type k.  Up to 150 data are allowed due to CAAL data
//  have_data(ALK_idx,0,0,0) is overall indicator that some datum requires ALK update in this ALK_time
//  have_data() 3rd element:  0=any; 1=survey/CPUE/effort; 2=discard; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=morphcomp; 9=tags
//  have_data() 4th element;  zero'th element contains N obs for this subseas; allows for 150 observations per datatype per fleet per subseason

  3darray data_time(1,ALK_time_max,1,Nfleet,1,3)
//  data_time():  first value will hold real month; 2nd is timing within season; 3rd is year.fraction
//  for a given fleet x subseas, all observations must have the same specific timing (month.fraction)
//  a warning will be given if subsequent observations have a different month.fraction
//  an observation's real_month is used to assign it to a season and a subseas within that seas, and it is used to calculate the data_timing within the season for mortality

//  where ALK_idx=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas   This is index to subseas and used to indicate which ALK is being referenced

//  3darray data_ALK_time(1,Nfleet,0,9,1,<nobsperkind/fleet>)   stores ALK_time

//  ProgLabel_2.2  Read CATCH amount by fleet
  matrix obs_equ_catch(1,nseas,1,Nfleet)    //  initial, equilibrium catch.  now seasonal
 LOCAL_CALCS
   have_data.initialize();
   have_data_yr.initialize();
   obs_equ_catch.initialize();

   for(y=1;y<=ALK_time_max;y++)
   for(f=1;f<=Nfleet;f++)
   {
     data_time(y,f,1)=-1.0;  //  set to illegal value since 0.0 is valid
   }
 END_CALCS
!!//  SS_Label_Info_2.2 #Read CATCH amount by fleet

  int N_ReadCatch;
//  int Catch_read;
  vector tempvec(1,6)  //  vector used for temporary reads
 LOCAL_CALCS

  ender=0;
  do {
    dvector tempvec(1,5);
      *(ad_comm::global_datafile) >> tempvec(1,5);
        if(tempvec(1)==-9999.) ender=1;
    catch_read.push_back (tempvec(1,5));
  } while (ender==0);
  N_ReadCatch=catch_read.size()-1;
   echoinput<<N_ReadCatch<<" records"<<endl;
 END_CALCS

  matrix catch_ret_obs(1,Nfleet,styr-nseas,TimeMax+nseas)
  imatrix do_Fparm(1,Nfleet,styr-nseas,TimeMax+nseas)
  imatrix catch_record_count(1,Nfleet,styr-nseas,TimeMax+nseas)
  3iarray catch_seas_area(styr,TimeMax,1,pop,0,Nfleet)
  matrix totcatch_byarea(styr,TimeMax,1,pop)
  vector totcat(styr-1,endyr)  //  by year, not by t
  int first_catch_yr
  vector catch_by_fleet(1,Nfleet)

  ivector disc_fleet_list(1,Nfleet);
  int N_retain_fleets;
  int catch_warn;

 LOCAL_CALCS
  catch_ret_obs.initialize();
  catch_record_count.initialize();
  catch_warn=0;
  tempvec.initialize();
  for (k=0;k<=N_ReadCatch-1;k++)
  {
    //  do read in list format  y, s, f, catch, catch_se
    tempvec(1,5)=catch_read[k];
    g=tempvec(1); s=tempvec(2); f=tempvec(3);
    if(g==-999)
    {y=styr-1;}  // designates initial equilibrium
    else
    {y=g;}
    if(k==0) echoinput<<"first catch record: "<<tempvec(1,5)<<endl;
    if(k==(N_ReadCatch-1)) echoinput<<"last catch record: "<<tempvec(1,5)<<endl;
    if(y>=styr-1 && y<=endyr && (g==-999 || g>=styr))  //  observation is in date range
    {
      if(s>nseas){
        catch_warn++;
        s=nseas;
        // allows for collapsing multiple season catch data down into fewer seasons
        // typically to collapse to annual because accumulation will all be in the index "nseas"
      }
      if(s>0)
      {
        t=styr+(y-styr)*nseas+s-1;

        {
          catch_ret_obs(f,t) += tempvec(4);
          catch_record_count(f,t)++;
          catch_se(t,f) = tempvec(5);
        }
      }
      else  // distribute catch equally across seasons
      {
        for (s=1;s<=nseas;s++)
        {
          t=styr+(y-styr)*nseas+s-1;
          {
            catch_ret_obs(f,t) += tempvec(4)/nseas;
            catch_record_count(f,t)++;
          }
        }
      }
    }
  }
  if(catch_warn>0){
    N_warn++; warning<<N_warn<<" at least one catch record has seas>nseas; perhaps erroneous entry of month rather than season; SS3 changed them to nseas"<<endl;
  }
//  warn on duplicate catch records
    for(y=styr-1;y<=endyr;y++)
    for(s=1;s<=nseas;s++)
    for(f=1;f<=Nfleet;f++) {
      t=styr+(y-styr)*nseas+s-1;
      if(catch_record_count(f,t)>1)
      	{N_warn++;  warning<<N_warn<<" "<<catch_record_count(f,t)<<" catch records have been accumulated into yr, seas, fleet "<<y<<" "<<s<<" "<<f<<"; total catch= "<<catch_ret_obs(f,t)<<endl;}
    }

    obs_equ_catch.initialize();
    for(s=1;s<=nseas;s++)
    {
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
        {obs_equ_catch(s,f)=catch_ret_obs(f,styr-nseas-1+s);}
      echoinput<<" equ, seas:   -1 "<<s<<" catches: "<<obs_equ_catch(s)<<endl;
    }
    for(y=styr;y<=endyr;y++)
    for(s=1;s<=nseas;s++)
    {
      t=styr+(y-styr)*nseas+s-1;
      echoinput<<"year, seas: "<<y<<" "<<s<<" catches: "<<trans(catch_ret_obs)(t)<<endl;
    }

//  calc total catch by year so can calculate the first year with catch and to omit zero catch years from sdreport
  totcat.initialize();
  catch_seas_area.initialize();
  totcatch_byarea.initialize();
  totcat(styr-1)=sum(obs_equ_catch);  //  sums over all seasons and fleets
  first_catch_yr=0;
  if(totcat(styr-1)>0.0) first_catch_yr=styr-1;

  for (y=styr; y<=endyr; y++)
  {
    for (s=1;s<=nseas;s++)
    {
      t=styr+(y-styr)*nseas+s-1;
      for (p=1;p<=pop;p++)
      for (f=1;f<=Nfleet;f++)
      if(fleet_area(f)==p && catch_ret_obs(f,t) > 0.0 && fleet_type(f)<=2)  //  excludes survey and predator fleets
      {
        catch_seas_area(t,p,f)=1;
        catch_seas_area(t,p,0)=1;
        if(fleet_type(f)==1) totcat(y) += catch_ret_obs(f,t);
        if(fleet_type(f)==1) totcatch_byarea(t,p)+=catch_ret_obs(f,t);
      }
    }
    if(totcat(y)>0.0 && first_catch_yr==0) first_catch_yr=y;
    if(y==endyr && totcat(y)==0.0)
    {
      N_warn++;  warning<<N_warn<<" catch is 0.0 in endyr; this can cause problem in the benchmark and forecast calculations"<<endl;
    }
  }
    echoinput<<endl<<"#_show_total_catch_by_fleet"<<endl;
    catch_by_fleet=rowsum(catch_ret_obs);
    for(f=1;f<=Nfleet;f++)
    {
      echoinput<<f<<" type: "<<fleet_type(f)<<" "<<fleetname(f)<<" catch: "<<catch_by_fleet(f);
      if(fleet_type(f)==3 && catch_by_fleet(f)>0.0)
        {
          echoinput<<"  Catch by survey fleet will be ignored ";
          N_warn++;  warning<<N_warn<<"  Catch by survey fleet will be ignored "<<fleet_type(f)<<endl;
        }
      echoinput<<endl;
    }
 END_CALCS

  //  SS_Label_Info_2.3 #Read fishery CPUE, effort, and Survey index or abundance
  !!echoinput<<endl<<"#_  now read survey characteristics:  fleet_#, svyunits, svyerrtype for each fleet "<<endl;
  int Svy_N_rd
  int Svy_N
  init_imatrix Svy_units_rd(1,Nfleet,1,4)
  ivector Svy_units(1,Nfleet)   //0=num; 1=bio; 2=F; >=30 for special patterns
  ivector Svy_errtype(1,Nfleet)  // -1=normal / 0=lognormal / >0=T
  ivector Svy_sdreport(1,Nfleet)  // 0=no sdreport; 1=enable sdreport
  int Svy_N_sdreport

 LOCAL_CALCS
  data_type=1;  //  for surveys
  echoinput<<"Units:  0=numbers; 1=biomass; 2=F; >=30 for special patterns"<<endl;
  echoinput<<"Errtype:  -1=normal; 0=lognormal; >0=T"<<endl;
  echoinput<<"SD_Report: 0=no sdreport; 1=enable sdreport"<<endl;
  echoinput<<"Fleet Units Err_Type SD_Report"<<endl;
  echoinput<<Svy_units_rd<<endl;
  Svy_units=column(Svy_units_rd,2);
  Svy_errtype=column(Svy_units_rd,3);
  Svy_sdreport=column(Svy_units_rd,4);

  ender=0;
  do {
    dvector tempvec(1,5);
      *(ad_comm::global_datafile) >> tempvec(1,5);
        if(tempvec(1)==-9999.) ender=1;
    Svy_data.push_back (tempvec(1,5));
  } while (ender==0);
  Svy_N_rd=Svy_data.size()-1;
  echoinput<<Svy_N_rd<<" nobs_survey "<<endl;

 END_CALCS

//   init_matrix Svy_data(1,Svy_N_rd,1,5)
//  !!if(Svy_N_rd>0) echoinput<<" Svy_data "<<endl<<Svy_data<<endl;
  ivector Svy_N_fleet(1,Nfleet)  // total N
  ivector Svy_N_fleet_use(1,Nfleet)  // N in likelihood
  int in_superperiod
  ivector Svy_super_N(1,Nfleet)      // N super_yrs per fleet

 LOCAL_CALCS
  //  count the number of observations, exclude those outside the specified year range, count the number of superperiods
  Svy_N=0;
  Svy_N_fleet=0;
  Svy_N_fleet_use=0;
  Svy_super_N=0;
  if(Svy_N_rd>0)
  {
    for (i=0;i<=Svy_N_rd-1;i++)
    {
      echoinput<<Svy_data[i]<<endl;
      y= Svy_data[i](1);
      if(y>=styr)
      {
        f=abs( Svy_data[i](3));  //  negative f turns off observation
        Svy_N_fleet(f)++;
        if( Svy_data[i](5)<0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"cannot use negative se to indicate superperiods in survey data"<<endl; exit(1);}
        if( Svy_data[i](2)<0) Svy_super_N(f)++;  // count the super-periods if seas<0
      }
    }
    Svy_N=sum(Svy_N_fleet);
    for (f=1;f<=Nfleet;f++)
    if(Svy_super_N(f)>0)
    {
      j=Svy_super_N(f)/2;  // because we counted the begin and end
      if(2*j!=Svy_super_N(f))
      {
        N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"unequal number of starts and ends of survey superperiods "<<endl; exit(1);
      }
      else
      {
        Svy_super_N(f)=j;
      }
    }
  }

  // check if there are observations for the index before enabling sdreport
  for (f = 1; f <= Nfleet; ++f)
  {
    if (Svy_N_fleet(f) == 0) Svy_sdreport(f) = 0;
  }

 END_CALCS

  imatrix Svy_time_t(1,Nfleet,1,Svy_N_fleet)  //  stores the continuous season index (t) for each obs
  imatrix Svy_ALK_time(1,Nfleet,1,Svy_N_fleet)  // stores the continuous subseas index (ALK_time) for each obs
  imatrix Svy_use(1,Nfleet,1,Svy_N_fleet)
  matrix  Svy_obs(1,Nfleet,1,Svy_N_fleet)
  matrix  Svy_obs_log(1,Nfleet,1,Svy_N_fleet)
  matrix  Svy_se_rd(1,Nfleet,1,Svy_N_fleet)
  matrix  Svy_se(1,Nfleet,1,Svy_N_fleet)
  matrix  Svy_selec_abund(1,Nfleet,1,Svy_N_fleet);        // Vulnerable biomass
// arrays for Super-years
  imatrix Svy_super(1,Nfleet,1,Svy_N_fleet)  //  indicator used to display start/stop in reports
  imatrix Svy_super_start(1,Nfleet,1,Svy_super_N)  //  where Svy_super_N is a vector
  imatrix Svy_super_end(1,Nfleet,1,Svy_super_N)
  matrix Svy_super_weight(1,Nfleet,1,Svy_N_fleet)
  ivector Svy_styr(1,Nfleet)
  ivector Svy_endyr(1,Nfleet)
  imatrix Svy_yr(1,Nfleet,1,Svy_N_fleet)
  number  real_month
  vector timing_input(1,3)
  vector timing_r_result(1,3)
  vector Svy_minval(1,Nfleet)
  vector Svy_maxval(1,Nfleet)
  ivector timing_i_result(1,6)
    // r_result(1,3) will contain: real_month, data_timing_seas, data_timing_yr,
    // i_result(1,6) will contain y, t, s, f, ALK_time, use_midseas

 LOCAL_CALCS
//  SS_Label_Info_2.3.1  #Process survey observations, move info into working arrays,create super-periods as needed
  Svy_super_N.initialize();
  Svy_N_fleet.initialize();
    Svy_styr.initialize();
    Svy_endyr.initialize();
    Svy_yr.initialize();
    Svy_minval.initialize();
    Svy_minval=999999999.;
    Svy_maxval.initialize();
    Svy_maxval=-999999999.;
  in_superperiod=0;
  if(Svy_N>0)
  {
    for (i=0;i<=Svy_N_rd-1;i++)  // loop all, including those out of yr range
    {
      y= Svy_data[i](1);
      if(y>endyr +50)
      {N_warn++;cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast observations cannot be beyond endyr +50"<<endl; exit(1);}
      if(y>=styr)
      {
//  call a global function to calculate data timing and create various indexes
//  function will return: data_timing, ALK_time, real_month, use_midseas
        timing_input(1,3)=Svy_data[i](1,3);
        get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);
        f=abs( Svy_data[i](3));
        if(y>retro_yr) Svy_data[i](3)=-f;
        Svy_N_fleet(f)++;  //  count obs by fleet again
        j=Svy_N_fleet(f);  //  index of observation as stored in working array
        t=timing_i_result(2);
        ALK_time=timing_i_result(5);
//  some fleet specific indexes and working versions of the data and se
        Svy_time_t(f,j)=t;
        Svy_ALK_time(f,j)=ALK_time;  //  continuous subseas counter in which jth obs from fleet f occurs
        Svy_se_rd(f,j)= Svy_data[i](5);   // later adjust with varadjust, copy to se_cr_use, then adjust with extra se parameter
        if( Svy_data[i](3)<0) {Svy_use(f,j)=-1;} else {Svy_use(f,j)=1;Svy_N_fleet_use(f)++;}
        Svy_obs(f,j)= Svy_data[i](4);
          Svy_yr(f,j)=y;
          if(Svy_styr(f)==0 || (y>=styr && y<Svy_styr(f)) )  Svy_styr(f)=y;  //  for dimensioning survey q devs
          if(Svy_endyr(f)==0 || (y<=endyr && y>Svy_endyr(f)) )  Svy_endyr(f)=y;  //  for dimensioning survey q devs
        if(y>=styr && Svy_data[i](3)>0)
        	{
        		Svy_minval(f)=min(Svy_minval(f),Svy_obs(f,j));
        		Svy_maxval(f)=max(Svy_maxval(f),Svy_obs(f,j));
        	}
//  some all fleet indexes
        if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
          {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
        else if (timing_r_result(1) ==  data_time(ALK_time,f,1))
          {N_warn++; cout<<"fatal input error, see warning"<<endl;
          	warning<<N_warn<<" SURVEY: duplicate survey obs for this time-fleet: y,s,f: "<<y<<" "<<s<<" "<<f<<" SS3 will exit "<<endl;
          exit(1);}

        have_data(ALK_time,0,0,0)=1;
        have_data(ALK_time,f,0,0)=1;  //  so have data of some type in this subseas, for this fleet
        have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
        p=have_data(ALK_time,f,data_type,0);  //  current number of observations
        have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
        have_data_yr(y,f)=1;  have_data_yr(y,0)=1;  //  survey or comp data exist this year
        //  create super_year indexes
        if( Svy_data[i](2)<0) // start or stop a super-period;  ALL observations must be continguous in the file
        {
          Svy_super(f,j)=-1;
         if(in_superperiod==0) // start superperiod
         {Svy_super_N(f)++; Svy_super_start(f,Svy_super_N(f))=j; in_superperiod=1;}
          else
          {
            if(in_superperiod==1)  // end superperiod
            {
              Svy_super_end(f,Svy_super_N(f))=j;
              in_superperiod=0;
            }
            else
            {
            }
          }
        }
        else
        {
          Svy_super(f,j)=1;
        }
      }
    }

  echoinput<<"Successful read of survey data; total N:  "<<Svy_N<<endl;
  echoinput<<"Index Survey_name       N   Super_Per    Min_val   max_val  //  Observations:"<<endl;
    for (f=1;f<=Nfleet;f++)
    {
    	if (Svy_N_fleet(f)>0)
    		{
    			echoinput<<f<<"    "<<fleetname(f)<<"   "<<Svy_N_fleet(f)<<"     "<<Svy_super_N(f)<<"      "<<Svy_minval(f)<<" "<<Svy_maxval(f)<<" // "<<Svy_obs(f)<<endl;
    			if(Svy_errtype(f)==0 && Svy_minval(f)<=0.)
    				{N_warn++; cout<<" exit with bad survey obs "<<endl;  warning<<N_warn<<" "<<"error, SS3 has exited. A fleet uses lognormal error and has an observation <=0.0; fleet: "<<f<<endl; exit(1);}
      	}
    }
  }
  Svy_N_sdreport = 0;
  for (f = 1; f <= Nfleet; ++f)
  {
    if (Svy_sdreport(f) > 0)
    {
      Svy_N_sdreport += Svy_N_fleet(f);
    }
  }
  if (Svy_N_sdreport < 0) Svy_N_sdreport = 0;
  echoinput<<"Number of sdreport index values: "<<Svy_N_sdreport<<endl;

 END_CALCS

   init_int Ndisc_fleets
   int nobs_disc  //  number of discard records kept in active array
   int disc_N_read  //  number of records read
   ivector disc_N_fleet(1,Nfleet)  //  kept obs per fleet
   ivector disc_N_fleet_use(1,Nfleet)  //  kept obs per fleet
   ivector N_suprper_disc(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
  //  SS_Label_Info_2.4 #read Discard data
  echoinput<<" note order of discard read is now: N fleets with disc, then if Ndisc_fleets>0 read:  fleet, disc_units, disc_error(for 1,Ndisc_fleets), then read obs "<<endl;
  echoinput<<Ndisc_fleets<<" N fleets with discard "<<endl;

  if(Ndisc_fleets>0) {j=Nfleet;} else {j=0;}
  data_type=2;  //  for discard
 END_CALCS
  init_imatrix disc_units_rd(1,Ndisc_fleets,1,3)
  ivector disc_units(1,j)  //  formerly scalar disc_type
  ivector disc_errtype(1,j)  // formerly scalar DF_disc
  vector disc_errtype_r(1,j)  // real version for T-dist
  vector disc_minval(1,j)
  vector disc_maxval(1,j)

 LOCAL_CALCS
  disc_units.initialize();
  disc_errtype.initialize();
  disc_minval.initialize();
  disc_minval=999999999.;
  disc_maxval.initialize();
  disc_maxval=-999999999.;
  nobs_disc=0;
  disc_N_fleet=0;
  disc_N_fleet_use=0;
  N_suprper_disc=0;
  if(Ndisc_fleets>0)
  {
    echoinput<<"#_discard_units (1=same_as_catchunits(bio/num);2=fraction; 3=numbers)"<<endl;
    echoinput<<"#_discard_error:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV"<<endl;
    echoinput<<"#Fleet Units Err_Type"<<endl;
    echoinput<<disc_units_rd<<endl;
    for (j=1;j<=Ndisc_fleets;j++)
    {
      f=disc_units_rd(j,1);
      disc_units(f)=disc_units_rd(j,2);
      disc_errtype(f)=disc_units_rd(j,3);
      disc_errtype_r(f)=float(disc_errtype(f));
    }

    ender=0;
    do {
      dvector tempvec(1,5);
        *(ad_comm::global_datafile) >> tempvec(1,5);
          if(tempvec(1)==-9999.) ender=1;
      discdata.push_back (tempvec(1,5));
    } while (ender==0);
    disc_N_read=discdata.size()-1;
    echoinput<<disc_N_read<<" N discard obs "<<endl;

    if(disc_N_read>0)
    {
      for (i=0;i<=disc_N_read-1;i++)  // get count of observations in date range
      {
        echoinput<<discdata[i]<<endl;
        y= discdata[i](1);
        if(y>=styr)
        {
          f=abs( discdata[i](3));
          disc_N_fleet(f)++;
          if( discdata[i](5)<0) {N_warn++; cout<<"EXIT - see warning"<<endl;  warning<<N_warn<<" "<<"Cannot use negative se as indicator of superperiod in discard data"<<endl;}
          if( discdata[i](2)<0) N_suprper_disc(f)++;  // count the super-periods if seas<0 or se<0
        }
      }
      nobs_disc=sum(disc_N_fleet);  // sum of obs in the date range
      for (f=1;f<=Nfleet;f++)
      if(N_suprper_disc(f)>0)
      {
        j=N_suprper_disc(f)/2;  // because we counted the begin and end
        if(2*j!=N_suprper_disc(f))
        {
          N_warn++; cout<<"EXIT - see warning"<<endl;  warning<<N_warn<<" "<<"unequal number of starts and ends of discard superperiods "<<endl; exit(1);
        }
        else
        {
          N_suprper_disc(f)=j;
        }
      }
    }
  }
 END_CALCS

  imatrix disc_time_t(1,Nfleet,1,disc_N_fleet)
  imatrix disc_time_ALK(1,Nfleet,1,disc_N_fleet)  // stores the continuous subseas index (ALK_time) for each obs
  imatrix yr_disc_use(1,Nfleet,1,disc_N_fleet)
  matrix  obs_disc(1,Nfleet,1,disc_N_fleet)
  matrix  cv_disc(1,Nfleet,1,disc_N_fleet)
  matrix  sd_disc(1,Nfleet,1,disc_N_fleet)
// arrays for Super-years
  imatrix yr_disc_super(1,Nfleet,1,disc_N_fleet)
  imatrix suprper_disc1(1,Nfleet,1,N_suprper_disc)
  imatrix suprper_disc2(1,Nfleet,1,N_suprper_disc)
  matrix suprper_disc_sampwt(1,Nfleet,1,disc_N_fleet)
 LOCAL_CALCS
  //  SS_Label_Info_2.4.1 #Process discard data and create super periods as needed
    disc_N_fleet.initialize();                        // redo the counter to provide pointer for below
    N_suprper_disc.initialize();
    in_superperiod=0;
    if(nobs_disc>0)
    {
      for (i=0;i<=disc_N_read-1;i++)
      {
        y= discdata[i](1);
        if(y>endyr +50)
        {N_warn++;cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast observations cannot be beyond endyr +50"<<endl; exit(1);}
        if(y>=styr)
        {
         timing_input(1,3)=discdata[i](1,3);
         get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);

         f=abs( discdata[i](3));
         if(y>retro_yr) discdata[i](3)=-f;
         disc_N_fleet(f)++;
         j=disc_N_fleet(f);  //  index number for data that are in date range
         t=timing_i_result(2);
         ALK_time=timing_i_result(5);
         disc_time_t(f,j)=t;
         disc_time_ALK(f,j)=ALK_time;  //  subseas that this observation is in

         if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
         {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
         else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
         {N_warn++;  warning<<N_warn<<" "<<"DISCARD: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<timing_r_result(1)<<endl;}

         have_data(ALK_time,0,0,0)=1;
         have_data(ALK_time,f,0,0)=1;  //  so have data of some type
         have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
         p=have_data(ALK_time,f,data_type,0);
         have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas

         cv_disc(f,j)= discdata[i](5);
         obs_disc(f,j)=fabs( discdata[i](4));
         disc_minval(f)=min(disc_minval(f),obs_disc(f,j));
         disc_maxval(f)=max(disc_maxval(f),obs_disc(f,j));
         if( discdata[i](4)<0.0)  discdata[i](3)=-fabs( discdata[i](3));  //  convert to new format using negative fleet
         if( discdata[i](3)<0) {yr_disc_use(f,j)=-1;} else {yr_disc_use(f,j)=1;disc_N_fleet_use(f)++;}
         if(fleet_type(f)<3 && catch_ret_obs(f,t)<=0.0)
         {
           N_warn++;  warning<<N_warn<<" discard observation: "<<i<<" has no corresponding catch "<<discdata[i]<<endl;
         }

  //  create super_year indexes
         if( discdata[i](2)<0)  // start/stop a super-year  ALL observations must be continguous in the file
         {
          yr_disc_super(f,j)=-1;
         if(in_superperiod==0)  // start a super-year
           {N_suprper_disc(f)++; suprper_disc1(f,N_suprper_disc(f))=j; in_superperiod=1;}
         else if(in_superperiod==1)  // end a super-year
           {suprper_disc2(f,N_suprper_disc(f))=j; in_superperiod=0;}
         }
         else
         {
            yr_disc_super(f,j)=1;
         }
        }
      }
    }
  echoinput<<"Successful read of discard data  "<<endl;
  echoinput<<"Index Survey_name       N   Super_Per    Min_val   max_val  //  Observations:"<<endl;
    for (f=1;f<=Nfleet;f++)
    {
    	if (disc_N_fleet(f)>0)
    		{
    			echoinput<<f<<"    "<<fleetname(f)<<"   "<<disc_N_fleet(f)<<"     "<<N_suprper_disc(f)<<
    			"      "<<disc_minval(f)<<" "<<disc_maxval(f)<<" // "<<obs_disc(f)<<endl;
    			if(disc_minval(f)<0.)
    				{N_warn++; cout<<" exit with bad discard obs "<<endl;  warning<<N_warn<<" "<<"error, SS3 has exited. A discard observation is <0.0; fleet: "<<f<<endl; exit(1);}
      	}
    }
 END_CALCS


!!//  SS_Label_Info_2.5 #Read Mean Body Weight data
//  note that syntax for storing this info internally is done differently than for surveys and discard
  init_int do_meanbodywt
  int nobs_mnwt_rd
  int nobs_mnwt
  ivector mnwt_N_fleet(1,Nfleet)
  ivector mnwt_N_fleet_use(1,Nfleet)
  number DF_bodywt  // DF For meanbodywt T-distribution
  !!echoinput<<do_meanbodywt<<" Use mean body size (weight or length); If 0, then no additional input in 3.30 "<<endl;

 LOCAL_CALCS
    nobs_mnwt=0;
    mnwt_N_fleet.initialize();
    mnwt_N_fleet_use.initialize();
  if(do_meanbodywt>0)
  {
    *(ad_comm::global_datafile) >> DF_bodywt;
    echoinput<<DF_bodywt<<" degrees of freedom for bodywt T-distribution "<<endl;
    echoinput<<"#_yr month fleet part type obs stderr"<<endl;
    echoinput<<"# type is a required new input with 3.30.12"<<endl;
    echoinput<<"# type makes explicit the infor previously contained in the sign of partition, e.g. "<<endl;
    echoinput<<"# type=1 is for mean length, type=2 is for mean weight, (future, type=3 is for mean true age)"<<endl;
    ender=0;
    z=0;
    do {
     dvector tempvec(1,7);
     *(ad_comm::global_datafile) >> tempvec(1,7);
     if(tempvec(1)==-9999.) ender=1;
     z++;
     if(z<=2) echoinput<<"meansize_obs_#:"<<z<<" # "<<tempvec<<endl;
     mnwtdata1.push_back (tempvec(1,7));
     if(tempvec(1)>=styr) nobs_mnwt++;
    } while (ender==0);
    nobs_mnwt_rd=mnwtdata1.size()-1;
    echoinput<<nobs_mnwt_rd<<" nobs for mean body size"<<endl;
    if(nobs_mnwt_rd>0) echoinput<<"meansize_obs_#:"<<nobs_mnwt_rd<<" # "<<mnwtdata1[nobs_mnwt_rd-1]<<endl;
  }
 END_CALCS
  matrix mnwtdata(1,11,1,nobs_mnwt)  //  working matrix for the mean size data
//  10 items are:  1yr, 2seas, 3fleet, 4part, 5type, 6obs, 7se, then three intermediate variance quantities, then ALKtime

 LOCAL_CALCS
  mnwtdata.initialize();
  j=0;
  data_type=3;
  if(nobs_mnwt>0)
  for (i=0;i<=nobs_mnwt_rd-1;i++)  //   loop all obs
  {
    y=mnwtdata1[i](1);
      if(y>endyr +50)
      {N_warn++;cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"mnwt forecast observations cannot be beyond endyr +50"<<endl; exit(1);}
    if(y>=styr)
    {
      if(mnwtdata1[i](2)<0.0) {N_warn++;  warning<<N_warn<<" "<<"negative season not allowed for mnwtdata because superperiods not implemented "<<endl;}
      timing_input(1,3)=mnwtdata1[i](1,3);
      get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);
      j++;
      f=abs(mnwtdata1[i](3));
      if(y>retro_yr) mnwtdata1[i](3)=-f;
      mnwt_N_fleet(f)++;
      if(mnwtdata1[i](3)>0) {mnwt_N_fleet_use(f)++;}
      t=timing_i_result(2);
      ALK_time=timing_i_result(5);
//      disc_time_ALK(f,j)=ALK_time;  //  subseas that this observation is in

      if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
      {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
      else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
      {
        N_warn++;
         warning<<N_warn<<" "<<"MEAN_WEIGHT: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<timing_r_result(1)<<endl;
      }
      have_data(ALK_time,0,0,0)=1;
      have_data(ALK_time,f,0,0)=1;  //  so have data of some type
      have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
      p=have_data(ALK_time,f,data_type,0);
      have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas

      z=mnwtdata1[i](4);  // z is partition (0, 1, 2)

      for (k=1;k<=7;k++) mnwtdata(k,j)=mnwtdata1[i](k);
      mnwtdata(1,j)=t;  //  note:  saving t, not y so have direct access to t later
      mnwtdata(11,j)=ALK_time;
    }
  }
  echoinput<<"Successful pre-processing of mean-bodysize data"<<endl;
 END_CALCS

!!//  SS_Label_Info_2.6 #Setup population Length bins
  number binwidth2  //  width of length bins in population
  number minLread  // input minimum size in population; this is used as the mean size at age 0.00
  number maxLread  //  input maximum size to be considered; should be divisible by binwidth2
  int nlen_bin2  //number of length bins in length comp data doubled for males
  int nlen_binP   //number of length bins in length comp data +1 as needed
  number minL               // minL and maxL store ends of the sizevector and are used as bounds later
  number minL_m  // mean size in first pop bin
  number maxL  // set to the midsize of last population bin for selex calc
  int nlength  // N pop lenbins
  int nlength1  //  +1 as needed
  int nlength2  // doubled for males
  number startbin  // population length bin that matches first data length bin

  init_int LenBin_option  // 1=set to data bins; 2 generate uniform; 3 = read custom
  !!echoinput<<LenBin_option<<" LenBin_option:  1=set to data bins; 2 generate uniform; 3 = read custom"<<endl;
 LOCAL_CALCS
   if(LenBin_option==1)
   {k=0;}
   else if(LenBin_option==2)
   {k=3;}
   else if(LenBin_option==3)
   {k=1;}
   else
   {N_warn++;  warning<<N_warn<<" LenBin_option must be 1, 2 or 3"<<LenBin_option<<endl;}
 END_CALCS

  init_vector PopBin_Read(1,k);
  !!if( k>0) echoinput<<PopBin_Read<<" input for setup of pop length bins "<<endl;
 LOCAL_CALCS
   nlength=0;  // later will be read or calculated
   if(LenBin_option==2)
   {binwidth2=PopBin_Read(1); minLread=PopBin_Read(2); maxLread=PopBin_Read(3);}
   else if(LenBin_option==3)
   {nlength=PopBin_Read(1);}  // number of bins to read
 END_CALCS
  init_vector len_bins_rd(1,nlength)
  !!if(nlength>0) echoinput<<len_bins_rd<<" population length bins as read "<<endl;

!!//  SS_Label_Info_2.7 #Start length data section
  init_int use_length_data  //  0/1 to indicate whether there is any reading of length data
  !!echoinput<<use_length_data<<" indicator for length data  "<<endl;

  number min_tail  //min_proportion_for_compressing_tails_of_observed_composition
  number min_comp  //  small value added to each composition bins
  int CombGender_l  //  combine genders through this length bin
!!//  SS_Label_Info_2.7.1 #Read and process data length bins
  int nlen_bin //number of length bins in length comp data
  vector min_tail_L(1,Nfleet)  //min_proportion_for_compressing_tails_of_observed_composition
  vector min_comp_L(1,Nfleet)  //  small value added to each composition bins
  ivector CombGender_L(1,Nfleet)  //  combine genders through this length bin (0 or -1 for no combine)
  ivector AccumBin_L(1,Nfleet)  //  collapse bins down to this bin number (0 for no collapse; positive value for number to accumulate)
  ivector Comp_Err_L(1,Nfleet)  //  composition error type
  ivector Comp_Err_L2(1,Nfleet)  //  composition error type parameter location
  vector min_sample_size_L(1,Nfleet)  // minimum sample size
  int Comp_Err_ParmCount;  // counts number of fleets that need a parameter for the error estimation
  ivector DM_parmlist(1,2*Nfleet);
 LOCAL_CALCS
  Comp_Err_ParmCount=0;
  min_tail_L.initialize();
  CombGender_L.initialize();
  AccumBin_L.initialize();
  Comp_Err_L.initialize();
  Comp_Err_L2.initialize();
  min_sample_size_L.initialize();
  DM_parmlist.initialize();

  if(use_length_data>0)
  {
    echoinput<<"#_now read for each fleet info for processing the length comps:"<<endl;
    echoinput<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
    echoinput<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
    echoinput<<"#_males and females treated as combined gender below this bin number "<<endl;
    echoinput<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
    echoinput<<"#_Comp_Error:  0=multinomial, 1=Dirichlet"<<endl;
    echoinput<<"#_Comp_ERR-2:  index of Dirichlet parameter to use"<<endl;
    echoinput<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, set to 0 for no minimum"<<endl;

    for (f=1;f<=Nfleet;f++)
    {
    *(ad_comm::global_datafile) >> min_tail_L(f);
    *(ad_comm::global_datafile) >> min_comp_L(f);
    *(ad_comm::global_datafile) >> CombGender_L(f);
    *(ad_comm::global_datafile) >> AccumBin_L(f);
    *(ad_comm::global_datafile) >> Comp_Err_L(f);
    *(ad_comm::global_datafile) >> Comp_Err_L2(f);
    *(ad_comm::global_datafile) >> min_sample_size_L(f);
    echoinput<<min_tail_L(f)<<" "<<min_comp_L(f)<<" "<<CombGender_L(f)<<" "<<AccumBin_L(f)<<" "<<Comp_Err_L(f)<<" "<<Comp_Err_L2(f)<<" "<<min_sample_size_L(f)<<"  #_fleet: "<<f<<" "<<fleetname(f)<<endl;

      if (min_sample_size_L(f) < 0.001)
      {
        N_warn++;  warning<<N_warn<<" minimum sample size for length comps must be > 0; minimum sample size set to 0.001 "<<endl;
        min_sample_size_L(f) = 0.001;
      }

      if (Comp_Err_L2(f) >2*Nfleet)
      {
        N_warn++; cout<<"fatal input error, see warning "<<endl; warning<<N_warn<<"; length D-M index for fleet: "<<f<<" is: "<<Comp_Err_L2(f)<<" but must be an integer <=2*Nfleet "<<endl;
        exit(1);
      }
      else if(Comp_Err_L2(f)>Comp_Err_ParmCount+1)
      {
        N_warn++; cout<<"fatal input error, see warning "<<endl;
        warning<<N_warn<<"; length D-M must refer to existing parm num, or increment by 1:  "<<Comp_Err_L2(f)<<endl;
        exit(1);
      }
      else if(Comp_Err_L2(f)>Comp_Err_ParmCount)
      {
        Comp_Err_ParmCount++;
        DM_parmlist(f)=1;
      }
      //  else OK because refers to existing parameter
    }
    //  the count for age data will be added after reading the age data setup
    echoinput<<"number of D-M parameters needed for length comp data: "<<Comp_Err_ParmCount<<endl<<endl;

    *(ad_comm::global_datafile) >> nlen_bin;
    echoinput<<nlen_bin<<" nlen_bin_for_data "<<endl;
  }
  else
  {
    nlen_bin=2;
    nlen_bin2=2*gender;
  }
 END_CALCS
  vector len_bins_dat(1,nlen_bin) // length bin lower boundaries
 LOCAL_CALCS
  if(use_length_data>0)
  {
  *(ad_comm::global_datafile) >> len_bins_dat;
  echoinput<<" len_bins_dat "<<endl<<len_bins_dat<<endl;

  for (f=1;f<=Nfleet;f++)
  {
  if(CombGender_L(f)>nlen_bin)
  {
    N_warn++;  warning<<N_warn<<" "<<"Combgender_L(f) cannot be greater than nlen_bin; resetting for fleet: "<<f<<endl;  CombGender_L(f)=nlen_bin;
  }
  }
  nlen_binP=nlen_bin+1;
  nlen_bin2=gender*nlen_bin;
  }
  else
    {
    }
 END_CALCS

  vector len_bins_dat2(1,nlen_bin2)  //; doubled for males; for output only
  vector len_bins_dat_m(1,nlen_bin)  //; midbin; for output only
  vector len_bins_dat_m2(1,nlen_bin2)  //; doubled for males; for output only

 LOCAL_CALCS
  //  SS_Label_Info_2.7.2 #Process population length bins, create mean length per bin, etc.
  //  note this is after reading the len_bin_for data in case population is mirrored to data
   if(LenBin_option==1)
   {
     nlength = nlen_bin;  // set N pop bins same as data bins
   }
   else if(LenBin_option==2)
   {
     nlength = (maxLread-minLread)/binwidth2+1;   // number of population length bins
   }
   else if(LenBin_option==3)
   {
    // nlength was read
   }
   nlength1 = nlength+1;          //  +1 when needed
   nlength2 = gender*nlength;    // doubled for males
 END_CALCS

  vector len_bins(1,nlength)  //vector with lower edge of population length bins
  vector log_len_bins(1,nlength)  //vector with log of lower edge of population length bins
  vector len_bins2(1,nlength2)  //vector with lower edge of population length bins
  vector binwidth(1,nlength2)  //ve
  vector len_bins_m(1,nlength)  //vector with mean size in bin
  vector len_bins_m2(1,nlength2)  //vector with all length bins; doubled for males
  vector len_bins_sq(1,nlength2)  //vector with all length bins; doubled for males
  vector male_offset(1,nlength2)  // used to calculate retained@length as population quantity

 LOCAL_CALCS
  male_offset.initialize();  //  initialize
   if(LenBin_option==1)
   {len_bins=len_bins_dat;}
   else if(LenBin_option==2)
   {
     len_bins(1)=minLread;
     for (z=2;z<=nlength;z++)  {len_bins(z)=len_bins(z-1)+binwidth2;}
   }
   else
   {len_bins=len_bins_rd;}

  if(len_bins(1)==0.0) len_bins(1)=0.001;
  for (z=1;z<=nlength;z++)
  {
    len_bins2(z)=len_bins(z);
    log_len_bins(z)=log(len_bins(z));
    if(z<nlength)
    {
      len_bins_m(z) = (len_bins(z+1)+len_bins(z))/2.;
      binwidth(z)=len_bins(z+1)-len_bins(z);
    }
    else
    {
      len_bins_m(z) = len_bins(z)+binwidth(z-1)/2.;
      binwidth(z)=binwidth(z-1);
    }

    len_bins_m2(z) = len_bins_m(z);     // for use in calc mean size at binned age
    len_bins_sq(z) = len_bins_m2(z)*len_bins_m2(z);        //  for use in calc std dev of size at binned age
    if(gender==2)
    {
      len_bins2(z+nlength)=len_bins(z);
      male_offset(z+nlength)=1.;
      binwidth(z+nlength)=binwidth(z);
      len_bins_m2(z+nlength)=len_bins_m2(z);
      len_bins_sq(z+nlength)=len_bins_sq(z);
    }
  }
  echoinput<<endl<<"Processed Population length bin info "<<endl<<len_bins<<endl;

  maxL=len_bins_m(nlength);
  minL=len_bins(1);
  minL_m=len_bins_m(1);
  if(LenBin_option!=2) binwidth2=binwidth(nlength/2);  // set a reasonable value in case LenBin_option !=2
  startbin=1;

  if(use_length_data>0)
  {
  while(len_bins(startbin)<len_bins_dat(1))
  {startbin++;}

  for (z=1;z<=nlen_bin;z++)
  {
    len_bins_dat2(z) = len_bins_dat(z);
    if(gender==2) len_bins_dat2(z+nlen_bin)=len_bins_dat(z);
    if(z<nlen_bin)
    {
      len_bins_dat_m(z)=0.5*(len_bins_dat(z)+len_bins_dat(z+1));  //  this is not gender specific
    }
    else
    {
      len_bins_dat_m(z)=len_bins_dat_m(z-1)+ (len_bins_dat(z)-len_bins_dat(z-1));
    }
    len_bins_dat_m2(z)=len_bins_dat_m(z);
    if(gender==2) len_bins_dat_m2(z+nlen_bin)=len_bins_dat_m(z);
  }
  if(len_bins_dat(nlen_bin)>len_bins(nlength))
  {
    N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Data length bins extend beyond pop len bins "<<len_bins_dat(nlen_bin)<<" "<<len_bins(nlength)<<endl; exit(1);
  }
  if(len_bins_dat(nlen_bin)<len_bins(nlength))
  {
    N_warn++;  warning<<N_warn<<" NOTE:  Max data length bin: "<<len_bins_dat(nlen_bin)<<"  < max pop len bins: "<<len_bins(nlength)<<"; so will accumulate larger pop len bins"<<endl;
  }
  echoinput<<endl<<"Processed Data length bin info "<<endl<<len_bins_dat<<endl;
  }
 END_CALCS

  matrix make_len_bin(1,nlen_bin2,1,nlength2);

  int ibin;
  int ibinsave;
  int fini;
  number topbin;
  number botbin;

 LOCAL_CALCS
  //  SS_Label_Info_2.7.3 #Create conversion of pop length bins to data length bins
  make_len_bin.initialize();
  ibin=0;
  topbin=0.;
  botbin=0.;
  if(use_length_data>0)
  {
  for (z=1;z<=nlength;z++)
  {
    if(ibin==nlen_bin)
    {  //checkup<<" got to last ibin, so put rest of popbins here"<<endl;
      make_len_bin(ibin,z)=1.;
    }
    else
    {
      if(len_bins(z)>=topbin) {ibin++; }  //checkup<<" incr ibin ";

      if(ibin>1)  {botbin=len_bins_dat(ibin);}
      if(ibin<nlen_bin) {topbin=len_bins_dat(ibin+1);} else {topbin=99999.;}

      if(ibin==nlen_bin)  // checkup<<" got to last ibin, so put rest of popbins here"<<endl;
      {make_len_bin(ibin,z)=1.;}
      else if(len_bins(z)>=botbin && len_bins(z+1)<=topbin )  //checkup<<" pop inside dat, put here"<<endl;
      {make_len_bin(ibin,z)=1.;}
      else
      {
      make_len_bin(ibin+1,z)=(len_bins(z+1)-topbin)/(len_bins(z+1)-len_bins(z));
      if(ibin!=1) make_len_bin(ibin,z)=1.-make_len_bin(ibin+1,z);
      }
    }
  }
  if(gender==2)
  {
    for (i=1;i<=nlen_bin;i++)
    for (j=1;j<=nlength;j++)
    make_len_bin(i+nlen_bin,j+nlength)=make_len_bin(i,j);
  }
   if(docheckup==1)
   {
    echoinput<<"pop_len_bin: "<<len_bins<<endl;
    for (ibin=1;ibin<=nlen_bin;ibin++) echoinput<<len_bins_dat(ibin)<<make_len_bin(ibin)(1,nlength)<<endl;
   }
  echoinput<<endl<<"Processed Population to Data length bin conversion matrix"<<endl;
  }
 END_CALCS


!!//  SS_Label_Info_2.7.4 #Read Length composition data
   int nobsl_rd
   int Nobs_l_tot
  ivector Nobs_l(1,Nfleet)
  ivector Nobs_l_use(1,Nfleet)
  ivector N_suprper_l(1,Nfleet)      // N super_yrs per obs

//   vector tempvec_lenread(1,6+nlen_bin2);

 LOCAL_CALCS
    k=6+nlen_bin2;
    Nobs_l.initialize();
    Nobs_l_use.initialize();
    N_suprper_l.initialize();
    if(use_length_data>0)
    {
    ender=0;
    z=0;
    do {
      dvector tempvec(1,k);
      *(ad_comm::global_datafile) >> tempvec(1,k);
      if(sum(tempvec)==0.0)
      	{N_warn++; cout<<"exit; see warning"<<endl; warning<<N_warn<<" reading past end of file for length data; exit "<<endl;exit(1);}
      if(tempvec(1)==-9999.) ender=1;
      z++;
      if(z<=2) echoinput<<"len_obs_#:"<<z<<" # "<<tempvec(1,k)<<endl;
      lendata.push_back (tempvec(1,k));
    } while (ender==0);
    nobsl_rd=lendata.size()-1;
    echoinput<<nobsl_rd<<" N length comp observations "<<endl;
    if(nobsl_rd>0) echoinput<<"len_obs_#:"<<nobsl_rd<<" # "<<lendata[nobsl_rd-1]<<endl;

    data_type=4;
    if(nobsl_rd>0)
    for (i=0;i<=nobsl_rd-1;i++)
    {
      y= lendata[i](1);
      if(y>=styr)
      {
      f=abs( lendata[i](3));
      if( lendata[i](6)<0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error in length data: negative sample size no longer valid as indicator of skip data or superperiods "<<endl; exit(1);}
      if( lendata[i](2)<0) N_suprper_l(f)++;     // count the number of starts and ends of super-periods if seas<0
      Nobs_l(f)++;
      }
    }
    Nobs_l_tot=sum(Nobs_l);
  for (f=1;f<=Nfleet;f++)
  {
    s=N_suprper_l(f)/2.;
    if(s*2!=N_suprper_l(f))
    {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error: unequal number of length superperiod starts and stops "<<endl; exit(1);}
    else
    {N_suprper_l(f)=s;}// to get the number of superperiods
  }

    echoinput<<"Lendata Nobs by fleet "<<Nobs_l<<endl;
    echoinput<<"Lendata superperiods by fleet "<<N_suprper_l<<endl;
    }
    else
    {
      nobsl_rd=0;
      Nobs_l=0;
      Nobs_l_tot=0;
      N_suprper_l=0;
    }
 END_CALCS

  imatrix Len_time_t(1,Nfleet,1,Nobs_l)
  imatrix Len_time_ALK(1,Nfleet,1,Nobs_l)
  3darray obs_l(1,Nfleet,1,Nobs_l,1,nlen_bin2)
  4darray obs_l_all(1,4,0,nseas,1,Nfleet,1,nlen_bin)  //  for the sum of all length comp data
  matrix offset_l(1,Nfleet,1,Nobs_l) // Compute OFFSET for multinomial (i.e, value for the multinonial function
  matrix  nsamp_l(1,Nfleet,1,Nobs_l)
  matrix  nsamp_l_read(1,Nfleet,1,Nobs_l)
  imatrix  gen_l(1,Nfleet,1,Nobs_l)
  imatrix  mkt_l(1,Nfleet,1,Nobs_l)
  3darray header_l_rd(1,Nfleet,1,Nobs_l,0,3)
  3darray header_l(1,Nfleet,1,Nobs_l,0,3)
  3darray tails_l(1,Nfleet,1,Nobs_l,1,4)   // min-max bin for females; min-max bin for males
  ivector tails_w(1,4)

// arrays for Super-years
  imatrix suprper_l1(1,Nfleet,1,N_suprper_l)
  imatrix suprper_l2(1,Nfleet,1,N_suprper_l)
  matrix  suprper_l_sampwt(1,Nfleet,1,Nobs_l)  //  will contain calculated weights for obs within super periods
  int floop
  int tloop

 LOCAL_CALCS
  //  SS_Label_Info_2.7.5 #Process length comps, compress tails, add constant, scale to 1.0
  N_suprper_l=0;
  Nobs_l=0;
  in_superperiod=0;
  suprper_l1.initialize();
  suprper_l2.initialize();
  obs_l_all.initialize();

  if(Nobs_l_tot>0)
  {
     echoinput<<"process length comps "<<endl;
    for (floop=1;floop<=Nfleet;floop++)    //  loop fleets
    for (i=0;i<=nobsl_rd-1;i++)   //  loop all observations to find those for this fleet/time
    {
      y= lendata[i](1);
      if(y>endyr +50)
      {N_warn++;cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast length obs cannot be beyond endyr +50;"<<endl; exit(1);}
      if(y>=styr)
      {
        f=abs( lendata[i](3));
        if(f==floop)
        {
          timing_input(1,3)=lendata[i](1,3);
          get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);

          Nobs_l(f)++;
          j=Nobs_l(f);
          f=abs( lendata[i](3));
          t=timing_i_result(2);
          s=timing_i_result(3);
          ALK_time=timing_i_result(5);

          Len_time_t(f,j)=t;     // sequential time = year+season
          Len_time_ALK(f,j)=ALK_time;
          if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
          {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
          else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
          {N_warn++;  warning<<N_warn<<" "<<"LENGTH: data_month already set for y,m,f: "<<y<<" "<<timing_r_result(1)<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  so treat as replicate"<<endl;}

            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
            have_data_yr(y,f)=1;  have_data_yr(y,0)=1;  //  survey or comp data exist this year

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Critical error, season for length obs "<<i<<" is > nseas"<<endl; exit(1);}

          if( lendata[i](6)<0.0)
            {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"negative values not allowed for lengthcomp sample size, use -fleet to omit from -logL"<<endl; exit(1);}
          header_l(f,j,1) = y;
          if( lendata[i](2)<0)
          {
            header_l(f,j,2) = -timing_r_result(1);  // month with sign to indicate super period
          }
          else
          {
            header_l(f,j,2) = timing_r_result(1);  // month
          }

          header_l_rd(f,j)(1,3) =  lendata[i](1,3);   // values as in input file
          header_l(f,j,3)=lendata[i](3);
          if(y>retro_yr) header_l(f,j,3)=-f;
          if(header_l(f,j,3)>0) Nobs_l_use(f)++;
          //  note that following storage is redundant with Show_Time(t,3) calculated later
          header_l(f,j,0) = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));  //
          gen_l(f,j)= lendata[i](4);         // gender 0=combined, 1=female, 2=male, 3=both
          mkt_l(f,j)= lendata[i](5);         // partition: 0=all, 1=discard, 2=retained
          nsamp_l_read(f,j)= lendata[i](6);  // assigned sample size for observation
          nsamp_l(f,j)=nsamp_l_read(f,j);
  //  SS_Label_Info_2.7.6 #Create super-periods for length compositions
          if( lendata[i](2)<0)  // start/stop a super-period  ALL observations must be continguous in the file
          {
            if(in_superperiod==0)  // start a super-period  ALL observations must be continguous in the file
            {N_suprper_l(f)++; suprper_l1(f,N_suprper_l(f))=j; in_superperiod=1;}
            else if(in_superperiod==1)  // end a super-year
            {suprper_l2(f,N_suprper_l(f))=j; in_superperiod=0;}
          }

          for (z=1;z<=nlen_bin2;z++)   // get the composition vector
           {obs_l(f,j,z)= lendata[i](6+z);}

          if(sum(obs_l(f,j))<=0.0) {N_warn++;  warning<<N_warn<<" zero fish in size comp (fleet, year) "<<f<<" "<<y<<endl; cout<<" EXIT - see warning "<<endl; exit(1);}
          if(nsamp_l_read(f,j)<=0.0)
          {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Input N is <=0.0 in length comp "<<header_l_rd(f,j)<<endl;  exit(1);}
          tails_l(f,j,1)=1;
          tails_l(f,j,2)=nlen_bin;
          tails_l(f,j,3)=nlen_binP;
          tails_l(f,j,4)=nlen_bin2;
          if(gen_l(f,j)==3 && gender==2 && CombGender_L(f)>0)
          {
            for (z=1;z<=CombGender_L(f);z++)
            {
              obs_l(f,j,z)+=obs_l(f,j,z+nlen_bin);  obs_l(f,j,z+nlen_bin)=0.0;
            }
            tails_l(f,j,3)=nlen_binP+CombGender_L(f);
          }
          if(gen_l(f,j)==2) obs_l(f,j)(1,nlen_bin) = 0.;   //  zero out females for male-only obs
          if(gen_l(f,j)<=1 && gender==2) obs_l(f,j)(nlen_binP,nlen_bin2) = 0.;   //  zero out males for female-only or combined gender obs
          obs_l(f,j) /= sum(obs_l(f,j));                  // make sum to 1.00

          if(gen_l(f,j)!=2)                      // do females, unless Male-only observation
          {
            k=0;
            temp=sum(obs_l(f,j)(1,nlen_bin));  //  sum of females proportions
            for (z=1;z<=nlen_bin;z++)
            if(obs_l(f,j,z)>0.)   //  find Number of bins with data
            {k++;}
            if(temp>0.0 && k>1)     // only compress tail if obs exist for this gender and there is more than 1 bin with data
            {
              k=0;
              for (z=1;z<=nlen_bin-1;z++)             // compress Female lower tail until exceeds min_tail
              {
                if(obs_l(f,j,z)<=min_tail_L(f)&& k==0)
                {
                  obs_l(f,j,z+1)+=obs_l(f,j,z);
                  obs_l(f,j,z)=0.00;
                  tails_l(f,j,1)=z+1;
                }
                else
                {k=1;}
              }

              k=0;
              for (z=nlen_bin;z>=tails_l(f,j,1);z--)  // compress Female upper tail until exceeds min_tail
              {
                if((obs_l(f,j,z)<=min_tail_L(f) && k==0) || z>(nlen_bin-AccumBin_L(f)))
                {
                  obs_l(f,j,z-1)+=obs_l(f,j,z);
                  obs_l(f,j,z)=0.00;
                  tails_l(f,j,2)=z-1;
                }
                else
                {k=1;}
              }
            }
            obs_l(f,j)(tails_l(f,j,1),tails_l(f,j,2)) += min_comp_L(f);    // add min_comp to bins in range
          }

          if(gen_l(f,j)>=2 && gender==2) // process males
          {
            k=0;
            temp=sum(obs_l(f,j)(nlen_binP,nlen_bin2));
            for (z=nlen_binP;z<=nlen_bin2;z++)
            if(obs_l(f,j,z)>0.)
            {k++;}
            if(temp>0.0 && k>1)     // only compress tail if obs exist for this gender and there is more than 1 bin with data
            {
              k=0;
              k1=tails_l(f,j,3);
              for (z=k1;z<=nlen_bin2-1;z++)
              {
                if(obs_l(f,j,z)<=min_tail_L(f) && k==0)
                {
                  obs_l(f,j,z+1)+=obs_l(f,j,z);
                  obs_l(f,j,z)=0.00;
                  tails_l(f,j,3)=z+1;
                }
                else
                {k=1;}
              }

              k=0;
              for (z=nlen_bin2;z>=tails_l(f,j,3);z--)  // compress Male upper tail until exceeds min_tail
              {
                if((obs_l(f,j,z)<=min_tail_L(f) && k==0) || z>(nlen_bin2-AccumBin_L(f)))
                {
                  obs_l(f,j,z-1)+=obs_l(f,j,z);
                  obs_l(f,j,z)=0.00;
                  tails_l(f,j,4)=z-1;
                }
                else
                {k=1;}
              }
            }
            obs_l(f,j)(tails_l(f,j,3),tails_l(f,j,4)) += min_comp_L(f);  // add min_comp to bins in range
          }   // end doing males
          obs_l(f,j) /= sum(obs_l(f,j));                  // make sum to 1.00 again after adding min_comp
          if(gender==1 || gen_l(f,j)!=2) {obs_l_all(1,s,f)(1,nlen_bin)+=obs_l(f,j)(1,nlen_bin);}  //  females or combined
          if(gender==2)
          {
            if(gen_l(f,j)==1 || gen_l(f,j)==3)  // put females into female only
            {
              obs_l_all(3,s,f)(1,nlen_bin)+=obs_l(f,j)(1,nlen_bin);
            }
            if(gen_l(f,j)>=2)  //  put males into combined and into male only
            {
              for(z=1;z<=nlen_bin;z++)
              {
                obs_l_all(1,s,f,z)+=obs_l(f,j,nlen_bin+z);
                obs_l_all(4,s,f,z)+=obs_l(f,j,nlen_bin+z);
              }
            }
          }
        }
      }
    }
  }

     echoinput<<"Overall_Compositions"<<endl<<"Seas Fleet len_bins "<<len_bins_dat<<endl;
     for (f=1;f<=Nfleet;f++)
     for(s=1;s<=nseas;s++)
     {
       for(j=1;j<=4;j++)
       {
          if(j!=2)
          {
            temp=sum(obs_l_all(j,s,f));
            if(temp>0.0)
            {
               obs_l_all(j,s,f)/=temp;
            }
            else
            {
              obs_l_all(j,s,f)=float(1./nlen_bin);
            }
          }
       }
       obs_l_all(2,s,f,1)=obs_l_all(1,s,f,1); // first bin
       for (z=2;z<=nlen_bin;z++)
       {
         obs_l_all(2,s,f,z)=obs_l_all(2,s,f,z-1)+obs_l_all(1,s,f,z);
       }
       if(Nobs_l(f)>0)
       {
         echoinput<<s<<" "<<f<<" freq"<<obs_l_all(1,s,f)<<endl;
         echoinput<<s<<" "<<f<<" cuml"<<obs_l_all(2,s,f)<<endl;
         echoinput<<s<<" "<<f<<" female"<<obs_l_all(3,s,f)<<endl;
         echoinput<<s<<" "<<f<<" male"<<obs_l_all(4,s,f)<<endl;
       }
     }

  echoinput<<"Successful processing of length data"<<endl<<endl;
 END_CALCS


!!//  SS_Label_Info_2.8 #Start age composition data section
!!//  SS_Label_Info_2.8.1 #Read Age bin and ageing error vectors
  int n_abins // age classes for data
  int n_abins1;
  int n_abins2;
  int Use_AgeKeyZero;  //  set to ageerr_type for the age data that use parameter approach
  int AgeKeyParm;  //  holds starting parm number for age error parameters
  int store_agekey_add;  //  when parameter based key uses blocks, this stores dimension
  int save_agekey_count;  //  counter for storing those keys
  int AgeKey_StartAge;
  int AgeKey_Linear1;
  int AgeKey_Linear2;
  int N_ageerr   // number of ageing error matrices to be calculated
  vector min_tail_A(1,Nfleet)  //min_proportion_for_compressing_tails_of_observed_composition
  vector min_comp_A(1,Nfleet)  //  small value added to each composition bins
  ivector CombGender_A(1,Nfleet)  //  combine genders through this age bin (0 or -1 for no combine)
  ivector AccumBin_A(1,Nfleet)  //  collapse bins down to this bin number (0 for no collapse; positive value for N to accumulate)
  ivector Comp_Err_A(1,Nfleet)  //  composition error type
  ivector Comp_Err_A2(1,Nfleet)  //  composition error parameter location
  vector min_sample_size_A(1,Nfleet)  // minimum sample size
  int Nobs_a_tot
  int nobsa_rd
  int Lbin_method  //#_Lbin_method: 1=poplenbins; 2=datalenbins; 3=lengths
  int CombGender_a  //  combine genders through this age bin
  ivector Nobs_a(1,Nfleet)
  ivector Nobs_a_use(1,Nfleet)
  ivector N_suprper_a(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
    Use_AgeKeyZero=0;
    N_ageerr=0;
    n_abins1=0;
    n_abins2=0;
  nobsa_rd=0;
  store_agekey_add=0;
  Nobs_a.initialize();
  Nobs_a_use.initialize();
  N_suprper_a.initialize();
  Comp_Err_A.initialize();
  Comp_Err_A2.initialize();
  echoinput<<"Enter the number of agebins, or 0 if no age data"<<endl;
  *(ad_comm::global_datafile) >> n_abins;
  echoinput<<n_abins<<" N age bins "<<endl;
  n_abins1=n_abins+1;
  n_abins2=gender*n_abins;
 END_CALCS

  vector age_bins1(1,n_abins) // age classes for data
  vector age_bins(1,n_abins2) // age classes for data  female then male end-to-end
  vector age_bins_mean(1,n_abins2)  //  holds mean age for each data age bin
  3darray age_err_rd(1,1,1,1,0,0)

 LOCAL_CALCS
  age_bins1.initialize();
  age_bins.initialize();
  age_bins_mean.initialize();

  if(n_abins>0)
  {
    *(ad_comm::global_datafile) >> age_bins1;
    echoinput << age_bins1<< " agebins "  << endl;

    *(ad_comm::global_datafile) >> N_ageerr;   // number of ageing error matrices to be calculated
    echoinput<<N_ageerr<<" N age error defs "<<endl;

    age_err_rd.deallocate();
    age_err_rd.allocate(1,N_ageerr,1,2,0,nages);
    age_err_rd.initialize();
    for(j=1;j<=N_ageerr;j++)
    {
      *(ad_comm::global_datafile) >> age_err_rd(j,1)(0,nages);
      *(ad_comm::global_datafile) >> age_err_rd(j,2)(0,nages);
    }
    Nobs_a=0;
    N_suprper_a=0;
    if(n_abins>0)
    {
      echoinput<<"ageerror_definitions_as_read"<<endl<<age_err_rd<<endl;
      Use_AgeKeyZero=0;
      if(N_ageerr>0)
      {
        for (i=1;i<=N_ageerr;i++)
        {
          if(age_err_rd(i,2,0)<0.) {  //  set flag for setup of age error parameters
            if (Use_AgeKeyZero>0)
            {
              N_warn++;  warning<<N_warn<<" "<<"SS3 can only create 1 age error definition from parameters, ";
               warning<<N_warn<<" "<<"but there are > 1 negative sd values for age 0 in age error definitions."<<endl;
  			echoinput<<"Error: There are > 1 negative sd values for age 0 in age error definitions."<<endl;
              cout<<" EXIT - see warning "<<endl; exit(1);
            }
            Use_AgeKeyZero=i;
          }
        }
      }

      echoinput<<"#_now read for each fleet info for processing the age comps:"<<endl;
      echoinput<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
      echoinput<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
      echoinput<<"#_males and females treated as combined gender below this bin number "<<endl;
      echoinput<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
      echoinput<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
      echoinput<<"#_Comp_ERR-2:  index of parameter to use, cumulative count after DM parms for length comp"<<endl;
      echoinput<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, set to 0 for no minimum"<<endl;

      for (f=1;f<=Nfleet;f++)
      {
        *(ad_comm::global_datafile) >> min_tail_A(f);
        *(ad_comm::global_datafile) >> min_comp_A(f);
        *(ad_comm::global_datafile) >> CombGender_A(f);
        *(ad_comm::global_datafile) >> AccumBin_A(f);
        *(ad_comm::global_datafile) >> Comp_Err_A(f);
        *(ad_comm::global_datafile) >> Comp_Err_A2(f);
        *(ad_comm::global_datafile) >> min_sample_size_A(f);
        echoinput<<min_tail_A(f)<<" "<<min_comp_A(f)<<" "<<CombGender_A(f)<<" "<<AccumBin_A(f)<<" "<<Comp_Err_A(f)<<" "<<Comp_Err_A2(f)<<" "<<min_sample_size_A(f)<<"  #_fleet: "<<f<<" "<<fleetname(f)<<endl;

        if (min_sample_size_A(f) < 0.001)
        {
          N_warn++;  warning<<N_warn<<" minimum sample size for age comps must be > 0; minimum sample size set to 0.001 "<<endl;
          min_sample_size_A(f) = 0.001;
        }
      if (Comp_Err_A2(f) >2*Nfleet)
      {
        N_warn++; cout<<"fatal input error, see warning "<<endl; warning<<N_warn<<"; Age D-M index for fleet: "<<f<<" is: "<<Comp_Err_A2(f)<<" but must be an integer <=2*Nfleet "<<endl;
        exit(1);
      }
      else if(Comp_Err_A2(f)>Comp_Err_ParmCount+1)
      {
        N_warn++; cout<<"fatal input error, see warning "<<endl;
        warning<<N_warn<<"; Age D-M must refer to existing parm num, or increment by 1:  "<<Comp_Err_A2(f)<<endl;
        exit(1);
      }
      else if(Comp_Err_A2(f)>Comp_Err_ParmCount)
      {
        Comp_Err_ParmCount++;
        DM_parmlist(f+Nfleet)=1;
      }
      //  else OK because refers to existing parameter
      }
      echoinput<<"number of D-M parameters needed for length and age comp data: "<<Comp_Err_ParmCount<<endl;

      *(ad_comm::global_datafile) >> Lbin_method;
      echoinput << Lbin_method<< " Lbin method for defined size ranges "  << endl;

      if(nobsa_rd>0 && N_ageerr==0)
      {
        N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" must define ageerror vectors because age data exist"<<endl; exit(1);
      }
      for (f=1;f<=Nfleet;f++)
      {
        if(CombGender_A(f)>n_abins2)
        {
        N_warn++;  warning<<N_warn<<" "<<"Combgender_A(f) cannot be greater than n_abins for fleet:_"<<f<<"; resetting"<<endl;  CombGender_A(f)=n_abins2;
        }
      }
      for (b=1;b<=n_abins;b++)
      {
       age_bins(b) = age_bins1(b);

       if(b<n_abins)
       {age_bins_mean(b) =(age_bins1(b)+age_bins1(b+1))*0.5;}
       else if (b>1)
       {age_bins_mean(b) =age_bins1(b)+0.5*(age_bins1(b)-age_bins1(b-1));}
       else
       {age_bins_mean(b) =age_bins1(b) + 0.5;}

       if(gender==2)
        {
          age_bins(b+n_abins)=age_bins1(b);
          age_bins_mean(b+n_abins)=age_bins_mean(b);
        }
      }
  //  SS_Label_Info_2.8.2 #Read Age data
    k=9+n_abins2;
    ender=0;
    z=0;
    do {
      dvector tempvec(1,k);
      *(ad_comm::global_datafile) >> tempvec(1,k);
      if(sum(tempvec)==0.0)
      	{N_warn++; cout<<"exit; see warning"<<endl; warning<<N_warn<<" reading past end of file for age data; exit "<<endl;exit(1);}
      if(tempvec(1)==-9999.) ender=1;
      z++;
      if(z<=2) echoinput<<"age_obs_#:"<<z<<" # "<<tempvec(1,k)<<endl;
      Age_Data.push_back (tempvec(1,k));
    } while (ender==0);
    nobsa_rd=Age_Data.size()-1;
    echoinput<<nobsa_rd<<" N age comp observations "<<endl;
    if(nobsa_rd>0) echoinput<<"age_obs_#:"<<nobsa_rd<<" # "<<Age_Data[nobsa_rd-1]<<endl;

    data_type=5;  //  for age data

    for (i=0;i<=nobsa_rd-1;i++)
    {
      y=Age_Data[i](1);
      if(y>=styr)
      {
       f=abs(Age_Data[i](3));
       if(Age_Data[i](9)<0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error: negative sample size in age data no longer valid as indicator of skip data or superperiods "<<endl; exit(1);}
       if(Age_Data[i](6)==0 || Age_Data[i](6)>N_ageerr) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error: undefined age_error type: "<<Age_Data[i](6)<<"  in obs: "<<i<<endl; exit(1);}
       if(Age_Data[i](2)<0) N_suprper_a(f)++;     // count the number of starts and ends of super-periods if seas<0 or sampsize<0

       Nobs_a(f)++;
      }
    }
    for (f=1;f<=Nfleet;f++)
    {
      s=N_suprper_a(f)/2.;
      if(s*2!=N_suprper_a(f))
      {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error: unequal number of age superperiod starts and stops "<<endl; exit(1);}
      else
      {N_suprper_a(f)/=2;}
    }
    echoinput<<endl<<"Age_Data Nobs by fleet "<<Nobs_a<<endl;
    echoinput<<"Age_Data superperiods by fleet "<<N_suprper_a<<endl;
    Nobs_a_tot=sum(Nobs_a);

    }
  }
  else
  {
    echoinput<<"N bins set to zero, so no more reading of age data inputs"<<endl;
  }

 END_CALCS

  matrix offset_a(1,Nfleet,1,Nobs_a) // Compute OFFSET for multinomial (i.e, value for the multinonial function
  imatrix Age_time_t(1,Nfleet,1,Nobs_a)
  imatrix Age_time_ALK(1,Nfleet,1,Nobs_a)
  3darray obs_a(1,Nfleet,1,Nobs_a,1,gender*n_abins)
  4darray obs_a_all(1,4,0,nseas,1,Nfleet,1,n_abins)  //  for the sum of all age comp data
  matrix  nsamp_a(1,Nfleet,1,Nobs_a)
  matrix  nsamp_a_read(1,Nfleet,1,Nobs_a)
  imatrix  ageerr_type_a(1,Nfleet,1,Nobs_a)
  imatrix  gen_a(1,Nfleet,1,Nobs_a)
  imatrix  mkt_a(1,Nfleet,1,Nobs_a)
  3darray  Lbin_filter(1,Nfleet,1,Nobs_a,1,nlength2)
  imatrix  use_Lbin_filter(1,Nfleet,1,Nobs_a)
  imatrix  Lbin_lo(1,Nfleet,1,Nobs_a)
  imatrix  Lbin_hi(1,Nfleet,1,Nobs_a)
  3darray tails_a(1,Nfleet,1,Nobs_a,1,4)   // min-max bin for females; min-max bin for males
  3darray header_a(1,Nfleet,1,Nobs_a,1,9)
  3darray header_a_rd(1,Nfleet,1,Nobs_a,2,3)

// arrays for Super-years
  matrix  suprper_a_sampwt(1,Nfleet,1,Nobs_a)  //  will contain calculated weights for obs within super periods
  imatrix suprper_a1(1,Nfleet,1,N_suprper_a)
  imatrix suprper_a2(1,Nfleet,1,N_suprper_a)

  //  SS_Label_Info_2.8.3 #Pre-process age comps, compress tails, define length bin filters
 LOCAL_CALCS
  Lbin_filter=1.;
  use_Lbin_filter.initialize();     // have to use initialize; imatrix cannot be set to a constant
  suprper_a1.initialize();
  suprper_a2.initialize();
  obs_a_all.initialize();
  N_suprper_a=0;
  Nobs_a=0;
  in_superperiod=0;

  if(Nobs_a_tot>0)
   {
     echoinput<<"process age comps "<<endl;
     for (floop=1;floop<=Nfleet;floop++)
     for (i=0;i<=nobsa_rd-1;i++)
     {
       y=Age_Data[i](1);
       if(y>endyr +50)
       {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast age obs cannot be beyond endyr +50; SS3 will exit"<<endl; exit(1);}
       if(y>=styr)
       {
         f=abs(Age_Data[i](3));
         if(f==floop)
         {
           timing_input(1,3)=Age_Data[i](1,3);
           get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);
           Nobs_a(f)++;  //  redoing this pointer just to create index j used below
           j=Nobs_a(f);

           f=abs(Age_Data[i](3));
           t=timing_i_result(2);
           s=timing_i_result(3);
           ALK_time=timing_i_result(5);
           Age_time_t(f,j)=t;                     // sequential time = year+season
           Age_time_ALK(f,j)=ALK_time;
           if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
           {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
           else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
           {N_warn++;  warning<<N_warn<<" "<<"AGE: data_month already set for y,m,f: "<<y<<" "<<timing_r_result(1)<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  so treat as replicate"<<endl;}
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            if(p>100)
            	{N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"fatal:  max agecomp obs per fleet*time is 100; you requested "<<p<<" for fleet x year "<<f<<" "<<y<<endl;exit(1);}
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
            have_data_yr(y,f)=1;  have_data_yr(y,0)=1;  //  survey or comp data exist this year

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Critical error, season for age obs "<<i<<" is > nseas"<<endl; exit(1);}

          if(Age_Data[i](6)<0.0)
            {N_warn++;  warning<<N_warn<<" "<<"negative values not allowed for age comp sample size, use -fleet to omit from -logL"<<endl;}
          header_a(f,j)(1,9)=Age_Data[i](1,9);
          header_a_rd(f,j)(2,3)=Age_Data[i](2,3);
          if(Age_Data[i](2)<0)
          {
            header_a(f,j,2) = -timing_r_result(1);  //  month with sign for super periods
          }
          else
          {
            header_a(f,j,2) = timing_r_result(1);  // month
          }
          if(y>retro_yr) header_a(f,j,3)=-f;
          if(header_a(f,j,3)>0) Nobs_a_use(f)++;
          gen_a(f,j)=Age_Data[i](4);         // gender 0=combined, 1=female, 2=male, 3=both
          mkt_a(f,j)=Age_Data[i](5);         // partition: 0=all, 1=discard, 2=retained
          nsamp_a_read(f,j)=Age_Data[i](9);  // assigned sample size for observation
          nsamp_a(f,j)=nsamp_a_read(f,j);

           if(Age_Data[i](6)>N_ageerr)
           {
              N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" ageerror type must be <= "<<N_ageerr<<endl; exit(1);
           }
           ageerr_type_a(f,j)=Age_Data[i](6);

  //  SS_Label_Info_2.8.4 #Create super-periods for age compositions
           if(in_superperiod==0 && Age_Data[i](2)<0)  // start a super-year  ALL observations must be continguous in the file
           {N_suprper_a(f)++; suprper_a1(f,N_suprper_a(f))=j; in_superperiod=1;}
           else if(in_superperiod==1 && Age_Data[i](2)<0)  // end a super-year
           {suprper_a2(f,N_suprper_a(f))=j; in_superperiod=0;}

           for (b=1;b<=gender*n_abins;b++)   // get the composition vector
           {obs_a(f,j,b)=Age_Data[i](9+b);}
           if(sum(obs_a(f,j))<=0.0)
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" zero fish in age comp "<<header_a(f,j)<<endl;  exit(1);}
           if(nsamp_a_read(f,j)<=0.0)
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Input N is <=0.0 in age comp "<<header_a_rd(f,j)<<endl;  exit(1);}

           Lbin_lo(f,j)=Age_Data[i](7);
           Lbin_hi(f,j)=Age_Data[i](8);
           switch (Lbin_method)   //  here all 3 methods are converted to poplenbins for use internally
           {
             case 1:  // values are population length bin numbers
             {
               if(Lbin_lo(f,j)<=0) Lbin_lo(f,j)=1;
               if(Lbin_hi(f,j)<=0 || Lbin_hi(f,j)>nlength) Lbin_hi(f,j)=nlength;
               break;
             }
             case 2:  // values are data length bin numbers
             {
               if(Lbin_lo(f,j)<=0) Lbin_lo(f,j)=1;
               if(Lbin_hi(f,j)<=0 || Lbin_hi(f,j)>nlen_bin) Lbin_hi(f,j)=nlen_bin;
               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==len_bins_dat(Lbin_lo(f,j)) ) s=k;  //  find poplen bin that matches data len bin
               }
               if(s==0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" L_bin_lo no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_lo(f,j)=s;

               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==len_bins_dat(Lbin_hi(f,j)) ) s=k;   //  find poplen bin that matches data len bin
               }
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl;  warning<<N_warn<<" L_bin_hi no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_hi(f,j)=s;
               break;
             }
             case 3:   // values are lengths
             {
               if(Lbin_lo(f,j)<=0) Lbin_lo(f,j)=len_bins(1);
               if(Lbin_hi(f,j)<=0 || Lbin_hi(f,j)>len_bins(nlength)) Lbin_hi(f,j)=len_bins(nlength);
               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==Lbin_lo(f,j) ) s=k;  //  find poplen bin that matches input length for lbin_lo
               }
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl;  warning<<N_warn<<" "<<"L_bin_lo no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_lo(f,j)=s;

               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==Lbin_hi(f,j) ) s=k;
               }
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl;  warning<<N_warn<<" "<<"L_bin_hi no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_hi(f,j)=s;
               break;
             }
           }

           //  lbin_lo and lbin_hi are now in terms of poplenbins; their original values are retained in header_a
           if(Lbin_lo(f,j)>nlength || Lbin_lo(f,j)>Lbin_hi(f,j))
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" L_bin_lo is too high in age comp.  Are you using lengths or bin numbers? "<<header_a(f,j)<<endl;  exit(1);}
           if(Lbin_lo(f,j)==1 && Lbin_hi(f,j)==nlength) {use_Lbin_filter(f,j)=0;} else {use_Lbin_filter(f,j)=1;}

           if(use_Lbin_filter(f,j)==1)
           {                                                   // use Lbin_filter for this obs
             Lbin_filter(f,j)=0.;
             Lbin_filter(f,j)(Lbin_lo(f,j),Lbin_hi(f,j)) = 1;
             if(gender==2)
             {
              k=int(Lbin_lo(f,j))+nlength; z=int(Lbin_hi(f,j))+nlength;
              Lbin_filter(f,j)(k,z) = 1.;
             }
           }

           if(gen_a(f,j)==2) obs_a(f,j)(1,n_abins) = 0.;   //  zero out females for male-only obs
           if(gen_a(f,j)<=1&&gender==2) obs_a(f,j)(n_abins1,gender*n_abins) = 0.;   //  zero out males for female-only or combined gender obs
           tails_a(f,j,1)=1;
           tails_a(f,j,2)=n_abins;
           tails_a(f,j,3)=1+(gender-1)*n_abins;
           tails_a(f,j,4)=gender*n_abins;
           if(gender==2)
           {
             if(gen_a(f,j)==3 && CombGender_A(f)>0)
             {
              for (z=1;z<=CombGender_A(f);z++)
              {
                obs_a(f,j,z)+=obs_a(f,j,z+n_abins);  obs_a(f,j,z+n_abins)=0.0;
              }
              tails_a(f,j,3)=n_abins+1+CombGender_A(f);
             }
           }

           obs_a(f,j) /= sum(obs_a(f,j));

           if(gen_a(f,j)!=2)                     // do females, unless Male-only observation
           {
             k=0;
             temp=sum(obs_a(f,j)(1,n_abins));
             for (z=1;z<=n_abins;z++)
             if(obs_a(f,j,z)>0.)
             {k++;}
             if(temp>0.0 && k>1)     // only compress tail if obs exist for this gender and there is more than 1 bin with data
             {
               k=0;
               for (z=1;z<=n_abins-1;z++)             // compress Female lower tail until exceeds min_tail
               {
                 if(obs_a(f,j,z)<=min_tail_A(f) && k==0)
                 {
                   obs_a(f,j,z+1)+=obs_a(f,j,z);
                   obs_a(f,j,z)=0.00;
                   tails_a(f,j,1)=z+1;
                 }
                 else
                 {k=1;}
               }

               k=0;
               for (z=n_abins;z>=tails_a(f,j,1);z--)  // compress Female upper tail until exceeds min_tail
               {
                 if((obs_a(f,j,z)<=min_tail_A(f) && k==0) || (z>(n_abins-AccumBin_A(f))))
                 {
                   obs_a(f,j,z-1)+=obs_a(f,j,z);
                   obs_a(f,j,z)=0.00;
                   tails_a(f,j,2)=z-1;
                 }
                 else
                 {k=1;}
               }
             }
             obs_a(f,j)(tails_a(f,j,1),tails_a(f,j,2)) += min_comp_A(f);    // add min_comp to bins in range
           }                            // done with females

           if(gen_a(f,j)>=2 && gender==2) // compress Male tails until exceeds min_tail
           {
             k=0;
             temp=sum(obs_a(f,j)(n_abins1,n_abins2));
             for (z=n_abins1;z<=n_abins2;z++)
             if(obs_a(f,j,z)>0.)
             {k++;}
             if(temp>0.0 && k>1)     // only compress tail if obs exist for this gender and there is more than 1 bin with data
             {
               k=0;

              for (z=n_abins1;z<=n_abins2-1;z++)
              {
                if(obs_a(f,j,z)<=min_tail_A(f) && k==0)
                {
                  obs_a(f,j,z+1)+=obs_a(f,j,z);
                  obs_a(f,j,z)=0.00;
                  tails_a(f,j,3)=z+1;
                }
                else
                {k=1;}
              }

              k=0;
              for (z=n_abins2;z>=tails_a(f,j,3);z--)  // compress Male upper tail until exceeds min_tail
              {
                if((obs_a(f,j,z)<=min_tail_A(f) && k==0) || (z>(n_abins2-AccumBin_A(f))))
                {
                  obs_a(f,j,z-1)+=obs_a(f,j,z);
                  obs_a(f,j,z)=0.00;
                  tails_a(f,j,4)=z-1;
                }
                else
                {k=1;}
              }
            }
            obs_a(f,j)(tails_a(f,j,3),tails_a(f,j,4)) += min_comp_A(f);  // add min_comp to bins in range
           }
           if(sum(obs_a(f,j))>0.) obs_a(f,j) /= sum(obs_a(f,j));                  // make sum to 1.00 again after adding min_comp
           s=timing_i_result(3);
           if(gender==1 || gen_a(f,j)!=2) obs_a_all(1,s,f)(1,n_abins)+=obs_a(f,j)(1,n_abins);  //  females or combined
           if(gender==2)
           {
            if(gen_a(f,j)==1 || gen_a(f,j)==3)  // put females into female only
             {obs_a_all(3,s,f)(1,n_abins)+=obs_a(f,j)(1,n_abins);}
            if(gen_a(f,j)>=2)  //  put males into combined and into male only
            {
             for (a=1;a<=n_abins;a++)
             {
               obs_a_all(1,s,f,a)+=obs_a(f,j,n_abins+a);  //  males into combined
               obs_a_all(4,s,f,a)+=obs_a(f,j,n_abins+a);  //  males
             }
            }
           }
       }
       }
     }

     echoinput<<"area seas fleet age_bins "<<age_bins<<endl;
     for(s=1;s<=nseas;s++)
     for(f=1;f<=Nfleet;f++)
     {
       if(Nobs_a(f)>0)
       {
         obs_a_all(1,s,f)/=sum(obs_a_all(1,s,f));
       }
       else
       {
         obs_a_all(1,s,f)=0.0;
       }
       obs_a_all(2,s,f,1)=obs_a_all(1,s,f,1); // first bin
       for (a=2;a<=n_abins;a++)
       {
         obs_a_all(2,s,f,a)=obs_a_all(2,s,f,a-1)+obs_a_all(1,s,f,a);
       }
       echoinput<<fleet_area(f)<<" "<<s<<" "<<f<<" freq "<<obs_a_all(1,s,f)<<endl;
       echoinput<<fleet_area(f)<<" "<<s<<" "<<f<<" cuml "<<obs_a_all(2,s,f)<<endl;
     }
     echoinput<<endl<<"Successful processing of age data "<<endl;
  }
 END_CALCS

!!//  SS_Label_Info_2.9 #Read mean Size_at_Age data
  init_int use_meansizedata
  int nobs_ms_tot
  int nobs_ms_rd
  !!echoinput<<use_meansizedata<<" (0/1) use mean size-at-age data "<<endl;
//  init_matrix sizeAge_Data(1,nobs_ms_rd,1,7+2*n_abins2)
  ivector Nobs_ms(1,Nfleet)
  ivector Nobs_ms_use(1,Nfleet)
  ivector N_suprper_ms(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
   Nobs_ms.initialize();
   Nobs_ms_use.initialize();
   N_suprper_ms.initialize();
  if(use_meansizedata>0)
  {
    k=7+2*n_abins2;
    ender=0;
    z=0;
    do {
      dvector tempvec(1,k);
      *(ad_comm::global_datafile) >> tempvec(1,k);
      if(sum(tempvec)==0.0)
      	{N_warn++; cout<<"exit; see warning"<<endl; warning<<N_warn<<" reading past end of file for size-at-age data; exit "<<endl;exit(1);}
      if(tempvec(1)==-9999.) ender=1;
      z++;
      if(z<=2) echoinput<<"meansize@age_obs_#:"<<z<<" # "<<tempvec(1,k)<<endl;
      sizeAge_Data.push_back (tempvec(1,k));
  } while (ender==0);
  nobs_ms_rd=sizeAge_Data.size()-1;
  echoinput<<nobs_ms_rd<<" N size@age obs read "<<endl;
  if(nobs_ms_rd>0) echoinput<<"meansize@age_obs_#:"<<nobs_ms_rd<<" # "<<sizeAge_Data[nobs_ms_rd-1]<<endl;

  data_type=7;  //  for size (length or weight)-at-age data
  Nobs_ms=0;
  N_suprper_ms=0;
  if(nobs_ms_rd>0)
  for (i=0;i<=nobs_ms_rd-1;i++)
  {
    y=sizeAge_Data[i](1);
    if(y>=styr)
    {
      f=abs(sizeAge_Data[i](3));
      if(sizeAge_Data[i](7)<0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"error.  cannot use negative sampsize for meansize data ";exit(1);;}
      if(sizeAge_Data[i](2)<0) N_suprper_ms(f)++;     // count the number of starts and ends of super-periods if seas<0 or sampsize<0
      Nobs_ms(f)++;
    }
  }
  for (f=1;f<=Nfleet;f++)
  {
    s=N_suprper_ms(f)/2.;
    if(s*2!=N_suprper_ms(f))
    {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Error: unequal number of meansize superperiod starts and stops "<<endl; exit(1);}
    else
    {N_suprper_ms(f)/=2;}
  }
  echoinput<<endl<<"meansize data Nobs by fleet "<<Nobs_ms<<endl;
  echoinput<<"meansize superperiods by fleet "<<N_suprper_ms<<endl;

  nobs_ms_tot=sum(Nobs_ms);
  }
  else
  {
    Nobs_ms=0;
    N_suprper_ms=0;
    nobs_ms_tot=0;
  }
 END_CALCS

  imatrix msz_time_t(1,Nfleet,1,Nobs_ms)
  imatrix msz_time_ALK(1,Nfleet,1,Nobs_ms)
  3darray obs_ms(1,Nfleet,1,Nobs_ms,1,n_abins2)
  3darray obs_ms_n(1,Nfleet,1,Nobs_ms,1,n_abins2)
  3darray obs_ms_n_read(1,Nfleet,1,Nobs_ms,1,n_abins2)
  imatrix  ageerr_type_ms(1,Nfleet,1,Nobs_ms)
  imatrix  gen_ms(1,Nfleet,1,Nobs_ms)
  imatrix  mkt_ms(1,Nfleet,1,Nobs_ms)
  3darray header_ms(1,Nfleet,1,Nobs_ms,0,7)
  3darray header_ms_rd(1,Nfleet,1,Nobs_ms,2,3)
  matrix suprper_ms_sampwt(1,Nfleet,1,Nobs_ms)
  imatrix suprper_ms1(1,Nfleet,1,N_suprper_ms)
  imatrix suprper_ms2(1,Nfleet,1,N_suprper_ms)

//  note:  sizeAge_Data[i](6) has age error method used; sign is positive to indicate mean length-at-age; negative for mean weight-at-age
 LOCAL_CALCS
   Nobs_ms=0;
   suprper_ms1.initialize();
   suprper_ms2.initialize();
   N_suprper_ms.initialize();
   if(nobs_ms_tot>0)
   {
     in_superperiod=0;
     for (floop=1;floop<=Nfleet;floop++)
     for (i=0;i<=nobs_ms_rd-1;i++)
     {
       y=sizeAge_Data[i](1);
       if(y>endyr +50)
       {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast meansize obs cannot be beyond endyr +50"<<endl; exit(1);}
       if(y>=styr)
       {
         f=abs(sizeAge_Data[i](3));
         if(f==floop)
         {
           timing_input(1,3)=sizeAge_Data[i](1,3);
           get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);
           Nobs_ms(f)++;
           j=Nobs_ms(f);  //  observation counter
           t=timing_i_result(2);
           s=timing_i_result(3);
           real_month=timing_r_result(1);
           ALK_time=timing_i_result(5);
           msz_time_t(f,j)=t;
            msz_time_ALK(f,j)=ALK_time;
           if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
           {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
           else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
           {N_warn++;  warning<<N_warn<<" "<<"LEN@AGE: data_month already set for y,m,f: "<<y<<" "<<timing_r_result(1)<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  so treat as replicate"<<endl;}
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Critical error, season for size-age obs "<<i<<" is > nseas"<<endl; exit(1);}

          header_ms(f,j)(1,7)=sizeAge_Data[i](1,7);
          header_ms_rd(f,j)(2,3)=sizeAge_Data[i](2,3);

          //  note that following storage is redundant with Show_Time(t,3) calculated later
          if(y>retro_yr) header_ms(f,j,3)=-f;
          if(sizeAge_Data[i](3)<0) header_ms(f,j,3)=-f;
          if(header_ms(f,j,3)>0) Nobs_ms_use(f)++;
          header_ms(f,j,0) = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));  //

           gen_ms(f,j)=sizeAge_Data[i](4);
           mkt_ms(f,j)=sizeAge_Data[i](5);
           if(abs(sizeAge_Data[i](6))>N_ageerr)
           {
              N_warn++;cout<<" EXIT - see warning "<<endl;
               warning<<N_warn<<" in meansize-at-age, ageerror type must be <= "<<N_ageerr<<endl; exit(1);
           }
           ageerr_type_ms(f,j)=sizeAge_Data[i](6);

  //  SS_Label_Info_2.9.1 #Create super-periods for meansize data
           if(sizeAge_Data[i](2)<0)  // start/stop a super-period  ALL observations must be continguous in the file
           {
             header_ms(f,j,2) = -real_month;  //month
             if(in_superperiod==0)  //  start superperiod
             {N_suprper_ms(f)++; suprper_ms1(f,N_suprper_ms(f))=j; in_superperiod=1;}
             else
             if(in_superperiod==1)  // end a super-period
             {suprper_ms2(f,N_suprper_ms(f))=j; in_superperiod=0;}
           }
           else
           {
             header_ms(f,j,2) = real_month;  //month
           }

           for (b=1;b<=n_abins2;b++)
           {obs_ms(f,j,b)=sizeAge_Data[i](7+b);}
           for (b=1;b<=n_abins2;b++)
           {
             obs_ms_n(f,j,b)=sizeAge_Data[i](7+b+n_abins2);
             obs_ms_n_read(f,j,b)=sizeAge_Data[i](7+b+n_abins2);
           }
         }
       }
     }
     echoinput<<"Successful read of size-at-age data; N kept = "<<Nobs_ms<<endl;
   }

 END_CALCS


!!//  SS_Label_Info_2.10 #Read environmental data that will be used to modify processes and expected values
  init_int N_envvar
  int N_envdata
 LOCAL_CALCS
  echoinput<<N_envvar<<" N_envvar "<<endl;

  ender=0;
  N_envdata=0;
  if(N_envvar>0)
  {
    do {
      dvector tempvec(1,3);
      *(ad_comm::global_datafile) >> tempvec(1,3);
      if(tempvec(1)==-9999.) ender=1;
      if(sum(tempvec)==0.0)
      	{N_warn++; cout<<"exit; see warning"<<endl; warning<<N_warn<<" reading past end of file for env data; exit "<<endl;exit(1);}
      env_temp.push_back (tempvec(1,3));
    } while (ender==0);
    N_envdata=env_temp.size()-1;
    echoinput<<" successful read of "<<N_envdata<<" environmental observations "<<endl;
  }
 END_CALCS

!!//  SS_Label_Info_2.11 #Start generalized size composition section
!!//  SS_Label_Info_2.11.1 #Read generalized size frequency data (aka wt frequency)
  int SzFreqMethod;
  int iobs;
  init_int SzFreq_Nmeth;                                   // number of sizefreq methods to be read
  !!echoinput<<SzFreq_Nmeth<<" N sizefreq methods to read "<<endl;
  imatrix SzFreq_HaveObs2(1,SzFreq_Nmeth,1,ALK_time_max)
  init_ivector SzFreq_Nbins(1,SzFreq_Nmeth);               //  number of bins for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_Nbins<<" Sizefreq N bins per method"<<endl;
  init_ivector SzFreq_units(1,SzFreq_Nmeth);               //  units for proportions (1 = biomass; 2=numbers ) for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_units<<" Sizetfreq units(1=bio/2=num) per method"<<endl;
  init_ivector SzFreq_scale(1,SzFreq_Nmeth);               //  bin scale (1=kg; 2=lbs; 3=cm; 4=in) for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_scale<<" Sizefreq scale(1=kg/2=lbs/3=cm/4=inches) per method"<<endl;
  init_vector SzFreq_mincomp(1,SzFreq_Nmeth);               //  mincomp to add for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_mincomp<<" Sizefreq:  add small constant to comps, per method "<<endl;
  init_ivector SzFreq_nobs(1,SzFreq_Nmeth);
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_nobs<<" Sizefreq N obs per method"<<endl;
  ivector SzFreq_Nbins_seas_g(1,SzFreq_Nmeth*nseas);   //  array dimensioner used only for the SzFreqTrans array
  ivector SzFreq_Nbins3(1,SzFreq_Nmeth)        // doubles the Nbins if gender==2
  int SzFreqMethod_seas;

 LOCAL_CALCS
  SzFreq_units_label+="bio";
  SzFreq_units_label+="numbers";
  SzFreq_scale_label+="kg";
  SzFreq_scale_label+="lbs";
  SzFreq_scale_label+="cm";
  SzFreq_scale_label+="inches";
  g=0;
  data_type=6;  //  for generalized size composition data

  if(SzFreq_Nmeth>0)
  {
    SzFreq_HaveObs2.initialize();
    for (k=1;k<=SzFreq_Nmeth;k++)
    {
      if(SzFreq_units(k)==1 && SzFreq_scale(k)>2)
      {
        N_warn++; cout<<" EXIT - see warning "<<endl;
         warning<<N_warn<<" error:  cannot accumulate biomass into length-based szfreq scale for method: "<<k<<endl;
        exit(1);
      }
      SzFreq_Nbins3(k)=gender*SzFreq_Nbins(k);
    for (s=1;s<=nseas;s++)
    {
      g++;
      SzFreq_Nbins_seas_g(g)=SzFreq_Nbins(k)*gender;
    }
  }
  }
 END_CALCS

  init_matrix SzFreq_bins1(1,SzFreq_Nmeth,1,SzFreq_Nbins);    // lower edge of wt bins
  !!if(SzFreq_Nmeth>0) echoinput<<" SizeFreq bins-raw "<<endl<<SzFreq_bins1<<endl;
  matrix SzFreq_bins(1,SzFreq_Nmeth,1,SzFreq_Nbins3);     //  szfreq bins as processed and doubled for the males if necessary
  matrix SzFreq_bins2(1,SzFreq_Nmeth,0,SzFreq_Nbins3+1);   //  as above, but one more bin to aid in the search for bin boundaries
  ivector SzFreq_Omit_Small(1,SzFreq_Nmeth);
  int SzFreq_totobs
  int SzFreq_N_Like
  matrix SzFreq_means(1,SzFreq_Nmeth,1,SzFreq_Nbins3);     //  szfreq mean size in bins as processed and doubled for the males if necessary

 LOCAL_CALCS
  SzFreq_totobs = 0;
  //  SS_Label_Info_2.11.1 #Size comp bins according to scaling method
  if(SzFreq_Nmeth>0)
  {
  for (k=1;k<=SzFreq_Nmeth;k++)
  {
// set flag for accumulating, or not, fish from small pop len bins up into first SzFreq data bin
// if first bin is positive, then fish smaller than that bin are ignored (omitsmall set =1)
// if first bin is negative, then smaller fish are accumulated up into that first bin

    SzFreq_Omit_Small(k)=1;
    if(SzFreq_bins1(k,1)<0)
    {
      SzFreq_Omit_Small(k)=-1;
      SzFreq_bins1(k,1)*=-1;  // make this positive for use in model, then write out as negative in data.ss_new
    }

    SzFreq_bins(k)(1,SzFreq_Nbins(k))=SzFreq_bins1(k)(1,SzFreq_Nbins(k));
    if(gender==2)
    {
      for (j=1;j<=SzFreq_Nbins(k);j++)
      {
        SzFreq_bins(k,j+SzFreq_Nbins(k))=SzFreq_bins1(k,j);
      }
    }
    if(SzFreq_scale(k)==2)  // convert from lbs to kg
    {
      SzFreq_bins(k)*=0.4536;
    }
    else if (SzFreq_scale(k)==4)  // convert from inches to cm
    {
      SzFreq_bins(k)*=2.54;
    }
    SzFreq_bins2(k,0)=0.;
    SzFreq_bins2(k)(1,SzFreq_Nbins(k))=SzFreq_bins(k)(1,SzFreq_Nbins(k));
    if(gender==2)
    {
      SzFreq_bins2(k,SzFreq_Nbins(k)+1)=0.;
      for (j=1;j<=SzFreq_Nbins(k);j++)
      {SzFreq_bins2(k,j+SzFreq_Nbins(k)+1)=SzFreq_bins2(k,j);}
    }

    for (z=1;z<=SzFreq_Nbins(k);z++)
    {
      if(z<SzFreq_Nbins(k))
      {
        SzFreq_means(k,z)=0.5*(SzFreq_bins2(k,z)+SzFreq_bins2(k,z+1));  //  this is not gender specific
      }
      else
      {
        SzFreq_means(k,z)=SzFreq_means(k,z-1)+ (SzFreq_bins2(k,z)-SzFreq_bins2(k,z-1));
      }
      if(gender==2) SzFreq_means(k,z+SzFreq_Nbins(k))=SzFreq_means(k,z);
    }
    echoinput<<"Processed_SizeFreqMethod_bins for method: "<<k<<endl<<"low: "<<SzFreq_bins(k)<<endl<<"mean: "<<SzFreq_means(k)<<endl;
  }
  SzFreq_totobs=sum(SzFreq_nobs);
  }
 END_CALCS

//  NOTE:  for the szfreq data, which are stored in one list and not by fleet, it is not possible to exclude from the working array on basis of before styr or after retroyr
  ivector SzFreq_Setup(1,SzFreq_totobs);  //  stores the number of bins plus header info to read into ragged array
  ivector SzFreq_Setup2(1,SzFreq_totobs);   //  stores the number of bins for each obs to create the ragged array
  ivector SzFreq_time_t(1,SzFreq_totobs)
  ivector SzFreq_time_ALK(1,SzFreq_totobs)

 LOCAL_CALCS
  if(SzFreq_Nmeth>0)
  {
  g=0;
  for (k=1;k<=SzFreq_Nmeth;k++)
  for (j=1;j<=SzFreq_nobs(k);j++)
  {g++; SzFreq_Setup(g)=7+gender*SzFreq_Nbins(k); SzFreq_Setup2(g)=gender*SzFreq_Nbins(k);}
  }
 END_CALCS

!!//  SS_Label_Info_2.11.2 #Read size comp observations into a ragged array
!!// , with the number of elements for each obs stored in sizefreq_setup
!!//   unlike the size and agecomp, obs from all fleets are in one dimension, rather than having a dimension for fleet
!!//  to do super-period, obs must be sorted by fleet and time within each method
  init_matrix SzFreq_obs1(1,SzFreq_totobs,1,SzFreq_Setup);
   !!if(SzFreq_totobs>0) echoinput<<" first sizefreq obs "<<endl<<SzFreq_obs1(1)<<endl<<" last obs"<<endl<<SzFreq_obs1(SzFreq_totobs)<<endl;;
  imatrix SzFreq_obs_hdr(1,SzFreq_totobs,1,9);
  // SzFreq_obs1:     Method, Year, season, Fleet, Gender, Partition, SampleSize, <data>
  // SzFreq_obs_hdr:     1=y; 2=month; 3=f; 4=gender; 5=partition; 6=method&skip flag; 7=first bin to use; 8=last bin(e.g. to include males or not); 9=flag to indicate transition matrix needs calculation
  vector SzFreq_sampleN(1,SzFreq_totobs);
  vector SzFreq_effN(1,SzFreq_totobs)
  vector SzFreq_eachlike(1,SzFreq_totobs);
  matrix SzFreq_obs(1,SzFreq_totobs,1,SzFreq_Setup2);
  imatrix SzFreq_LikeComponent(1,Nfleet,1,SzFreq_Nmeth)
  number N_suprper_SzFreq   //  no real need to keep track of these by method, so just use a number
 LOCAL_CALCS
  SzFreq_N_Like=0;
  N_suprper_SzFreq=0;
  if(SzFreq_Nmeth>0)
  {
    SzFreq_LikeComponent.initialize();
    SzFreq_obs.initialize();
    iobs=0;
    for (k=1;k<=SzFreq_Nmeth;k++)
    {
      for (j=1;j<=SzFreq_nobs(k);j++)
      {
//       if(y>=styr && y<=retro_yr)  // not used because all obs in one list
        iobs++;
        for (z=1;z<=5;z++)
        {SzFreq_obs_hdr(iobs,z) = SzFreq_obs1(iobs,z+1);}
        SzFreq_sampleN(iobs) = SzFreq_obs1(iobs,7);
        if(SzFreq_obs1(iobs,3)<0) N_suprper_SzFreq++;  //  count the number of superperiod start/stops
        if(SzFreq_obs_hdr(iobs,4)==3)  // both genders
        {
          for (z=1;z<=SzFreq_Setup2(iobs);z++) {SzFreq_obs(iobs,z)=SzFreq_obs1(iobs,7+z);}
        }
        else if(SzFreq_obs_hdr(iobs,4)<=1)  // combined gender or female only
        {
          for (z=1;z<=SzFreq_Nbins(k);z++) {SzFreq_obs(iobs,z)=SzFreq_obs1(iobs,7+z);}
        }
        else  // male only
        {
          for (z=SzFreq_Nbins(k)+1;z<=SzFreq_Setup2(iobs);z++) {SzFreq_obs(iobs,z)=SzFreq_obs1(iobs,7+z);}
        }
        if(gender==1) SzFreq_obs_hdr(iobs,4)=1;  // just in case
        if(sum(SzFreq_obs(iobs))<=0.0)
        {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" zero fish in size comp "<<SzFreq_obs_hdr(iobs)<<endl;  exit(1);}
        if(SzFreq_sampleN(iobs)<=0.0)
        {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Input N is <=0.0 in size comp "<<SzFreq_obs_hdr(iobs)<<endl;  exit(1);}

        f=abs(SzFreq_obs_hdr(iobs,3));
        SzFreq_obs(iobs)/=sum(SzFreq_obs(iobs));
        SzFreq_obs(iobs)+=SzFreq_mincomp(k);
        SzFreq_obs(iobs)/=sum(SzFreq_obs(iobs));
        y=SzFreq_obs_hdr(iobs,1);
        if(y>endyr +50)
        {N_warn++; warning<<N_warn<<" "<<"forecast sizefreq obs cannot be beyond endyr +50"<<endl; exit(1);}

        timing_input(1,3)=SzFreq_obs_hdr(iobs)(1,3);
        timing_input(2)=SzFreq_obs1(iobs,3);
        get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);

        f=abs(SzFreq_obs_hdr(iobs,3));
        if(y>retro_yr) SzFreq_obs_hdr(iobs,3)=-f;
        t=timing_i_result(2);
         if(gender==1) {SzFreq_obs_hdr(iobs,4)=0;}
        z=SzFreq_obs_hdr(iobs,4);  // gender
// get min and max index according to use of 0, 1, 2, 3 gender index
        if(z!=2) {SzFreq_obs_hdr(iobs,7)=1;} else {SzFreq_obs_hdr(iobs,7)=SzFreq_Nbins(k)+1;}
        if(z<=1) {SzFreq_obs_hdr(iobs,8)=SzFreq_Nbins(k);} else {SzFreq_obs_hdr(iobs,8)=2*SzFreq_Nbins(k);}
  //      SzFreq_obs_hdr(iobs,5);  // partition
        SzFreq_obs_hdr(iobs,6)=k;
        if(k!=SzFreq_obs1(iobs,1)) {N_warn++;  warning<<N_warn<<" sizefreq ID # doesn't match "<<endl; } // save method code for later use
        if(y>=styr)
        {
          ALK_time=timing_i_result(5);
          real_month=timing_r_result(1);

          SzFreq_time_t(iobs)=t;
          SzFreq_time_ALK(iobs)=ALK_time;
          SzFreq_LikeComponent(f,k)=1;    // indicates that this combination is being used
          if(SzFreq_HaveObs2(k,ALK_time)==0)  //  transition matrix needs calculation
            {
            	SzFreq_HaveObs2(k,ALK_time)=1;  // flad showing condition met
            	SzFreq_obs_hdr(iobs,9)=1;  //  flag that will be ehecked in ss_expval
            }

           if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
           {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
           else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
           {N_warn++;  warning<<N_warn<<" "<<"SIZE: data_month already set for y,m,f: "<<y<<" "<<timing_r_result(1)<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  so treat as replicate"<<endl;}
          have_data(ALK_time,0,0,0)=1;
          have_data(ALK_time,f,0,0)=1;  //  so have data of some type
          have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
          p=have_data(ALK_time,f,data_type,0);
          have_data(ALK_time,f,data_type,p)=iobs;  //  store data index for the p'th observation in this subseas
          have_data_yr(y,f)=1;  have_data_yr(y,0)=1;  //  survey or comp data exist this year

          if(SzFreq_obs_hdr(iobs,7)<0) SzFreq_obs_hdr(iobs,3)=-abs(SzFreq_obs_hdr(iobs,3));  //  old method for excluding from logL
        }
        else
        {
          SzFreq_obs_hdr(iobs,3)=-abs(SzFreq_obs_hdr(iobs,3));  //  flag for skipping this obs
          SzFreq_time_t(iobs)=styr;
          SzFreq_time_ALK(iobs)=1;
        }
      }
    }
    SzFreq_N_Like=sum(SzFreq_LikeComponent);
    if(N_suprper_SzFreq>0)
    {
      j=N_suprper_SzFreq/2;  // because we counted the begin and end
      if(2*j!=N_suprper_SzFreq)
      {
        N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"unequal number of starts and ends of sizefreq superperiods "<<endl; exit(1);
      }
      else
      {
        N_suprper_SzFreq=j;
      }
      echoinput<<"N superperiods for sizecomp "<<N_suprper_SzFreq<<endl;
    }
  }
 END_CALCS

!!//  SS_Label_Info_2.11.3 #Calc logL for a perfect fit to the sizefreq data as an offset
    vector SzFreq_like_base(1,SzFreq_N_Like)  // this is a constant offset, so can be declared in data section
    ivector suprper_SzFreq_start(1,N_suprper_SzFreq)
    ivector suprper_SzFreq_end(1,N_suprper_SzFreq)
    vector suprper_SzFreq_sampwt(1,SzFreq_totobs)  //  will contain calculated weights for obs within super periods

 LOCAL_CALCS
  if(SzFreq_Nmeth>0)
  {
    SzFreq_like_base.initialize();
    suprper_SzFreq_start.initialize();
    suprper_SzFreq_end.initialize();
    suprper_SzFreq_sampwt.initialize();
//     N_suprper_SzFreq=0;  // redo this counter so can use the counter
//  count the number of type x methods being used to create vector length for the likelihoods
    g=0;
    for (f=1;f<=Nfleet;f++)
    for (k=1;k<=SzFreq_Nmeth;k++)
    {
      if(SzFreq_LikeComponent(f,k)>0) {g++; SzFreq_LikeComponent(f,k)=g;}  //  so stored value g gives index in list of logL elements
    }
//     in_superperiod=0;
//     for (iobs=1;iobs<=SzFreq_totobs;iobs++)
//     {
//       k=SzFreq_obs_hdr(iobs,6);  //  get the method
//       f=abs(SzFreq_obs_hdr(iobs,3));
//       s=SzFreq_obs_hdr(iobs,2);  // sign used to indicate start/stop of super period
//       if(SzFreq_obs_hdr(iobs,3)>0)  // negative for out of range or skip
//       {
//         z1=SzFreq_obs_hdr(iobs,7);
//         z2=SzFreq_obs_hdr(iobs,8);
//         g=SzFreq_LikeComponent(f,k);
//         SzFreq_like_base(g)-=SzFreq_sampleN(iobs)*SzFreq_obs(iobs)(z1,z2)*log(SzFreq_obs(iobs)(z1,z2));
//       }

// identify super-period starts and stops
//       if(s<0) // start/stop a super-period  ALL observations must be continguous in the file
//       {
//         if(in_superperiod==0)
//         {
//           N_suprper_SzFreq++;
//           suprper_SzFreq_start(N_suprper_SzFreq)=iobs;
//           in_superperiod=1;
//         }
//         else if(in_superperiod==1)  // end a super-period
//         {
//           suprper_SzFreq_end(N_suprper_SzFreq)=iobs;
//           in_superperiod=0;
//         }
//       }
//     }
  }
  echoinput<<" finished processing sizefreq data "<<endl;
//   if(N_suprper_SzFreq>0) echoinput<<"sizefreq superperiod start obs: "<<suprper_SzFreq_start<<endl<<"sizefreq superperiod end obs:   "<<suprper_SzFreq_end<<endl;
 END_CALCS

!!//  SS_Label_Info_2.12 #Read tag release and recapture data
  init_int Do_TG
  !!echoinput<<Do_TG<<" Do_TagData(0/1) "<<endl;

  init_vector TG_temp(1,4*Do_TG)
  int TG;
  int N_TG   // N tag groups
  int N_TG2;
  int TG_timestart;
  int N_TG_recap;   //  N recapture events
  int TG_mixperiod; //  First period (seasons) to start comparing obs to expected recoveries; period=0 is the release period
  int TG_maxperiods; //  max number of periods (seasons) to track recoveries; period=0 is the release period
 LOCAL_CALCS
  if(Do_TG>0)
  {
    Do_TG=1;
    N_TG=TG_temp(1);
    N_TG_recap=TG_temp(2);
    TG_mixperiod=TG_temp(3);
    TG_maxperiods=TG_temp(4);
    N_TG2=N_TG;
    TG_timestart=9999;
    echoinput<<N_TG<<" N tag groups "<<endl
    <<N_TG_recap<<" N recapture events"<<endl
    <<TG_mixperiod<<"  Latency period for mixing"<<endl
    <<TG_maxperiods<<" N periods to track recoveries"<<endl;
  }
  else
  {
    N_TG=0;
    N_TG_recap=0;
    TG_mixperiod=0;
    TG_maxperiods=0;
    N_TG2=1;
    TG_timestart=1;
  }
 END_CALCS

  ivector TG_endtime(1,N_TG2)
  init_matrix TG_release(1,N_TG,1,8)
  // TG area  year season tindex gender age N_released
 LOCAL_CALCS
   TG_endtime(1)=0;
   if(N_TG>0)
   {
   echoinput<<" Tag Releases "<<endl<<"TG area year seas tindex gender age N_released "<<endl<<TG_release<<endl;
   for (TG=1;TG<=N_TG;TG++)
   {
     t=styr+int((TG_release(TG,3)-styr)*nseas+TG_release(TG,4)-1);
     TG_release(TG,5)=t;
     if(t<TG_timestart) TG_timestart=t;
     k=TG_maxperiods;
     if((t+TG_maxperiods)>TimeMax) k-=(t+TG_maxperiods-TimeMax);
      TG_endtime(TG)=k;
   }
  }
 END_CALCS

!!//  SS_Label_Info_2.12.1 #Store recapture info by TG group and time to follow it as a cohort
  init_matrix TG_recap_data(1,N_TG_recap,1,5)
  //  TG, year, season, fleet, gender, Number
  3darray TG_recap_obs(1,N_TG2,0,TG_endtime,0,Nfleet);   //  no area index because each fleet is in just one area
 LOCAL_CALCS
   if(N_TG>0)
   {
   echoinput<<"First row of tag-recapture data "<<TG_recap_data(1)<<endl;
   echoinput<<"Last  row of tag-recapture data "<<TG_recap_data(N_TG_recap)<<endl;
   TG_recap_obs.initialize();
   for (j=1;j<=N_TG_recap;j++)
   {
     TG=TG_recap_data(j,1);  // TG is the tag group
     t=styr+int((TG_recap_data(j,2)-styr)*nseas+TG_recap_data(j,3)-1) - TG_release(TG,5); // find elapsed time in terms of number of seasons
     if(t>TG_maxperiods) t=TG_maxperiods;
     if(t<0)
     {
       N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" recapture is before tag release for recap: "<<j<<endl;  exit(1);
     }
     TG_recap_obs(TG,t,TG_recap_data(j,4))+=TG_recap_data(j,5);  //   save N recaptures by TG, fleet of recapture, elapsed time
   }
   for (TG=1;TG<=N_TG;TG++)
   {
     for (TG_t=0;TG_t<=TG_endtime(TG);TG_t++)
     {
       TG_recap_obs(TG,TG_t,0) = sum(TG_recap_obs(TG,TG_t)(1,Nfleet));
       if(TG_recap_obs(TG,TG_t,0)>0.) TG_recap_obs(TG,TG_t)(1,Nfleet)/=TG_recap_obs(TG,TG_t,0);
     }
   }
  }
 END_CALCS

!!//  SS_Label_Info_2.13 #Morph composition data
   init_int Do_Morphcomp
  !!echoinput<<Do_Morphcomp<<" Do_Morphcomp(0/1) "<<endl;
   int Morphcomp_nobs
   int Morphcomp_nobs_rd
   int Morphcomp_nmorph
   number Morphcomp_mincomp
   matrix Morphcomp_obs_rd(1,1,1,1)  //  reallocate if needed
   matrix Morphcomp_obs(1,1,1,1)  //  reallocate if needed
 LOCAL_CALCS
  if(Do_Morphcomp==0)
  {
    Morphcomp_nobs=0;
    Morphcomp_nobs_rd=0;
    Morphcomp_nmorph=0;
    Morphcomp_mincomp=0.00001;
  }
  else
  {
    *(ad_comm::global_datafile) >> Morphcomp_nobs_rd;
    *(ad_comm::global_datafile) >> Morphcomp_nmorph;   // later compare this value to the n morphs in the control file and exit if different
    *(ad_comm::global_datafile) >> Morphcomp_mincomp;
    echoinput<<Morphcomp_nobs_rd<<" Morphcomp_nobs "<<endl;
    echoinput<<Morphcomp_nmorph<<" Morphcomp_nmorph "<<endl;
    echoinput<<Morphcomp_mincomp<<" Morphcomp_mincomp "<<endl;

    Morphcomp_obs.deallocate();
    Morphcomp_obs.allocate(1,Morphcomp_nobs_rd,1,5+Morphcomp_nmorph+1);  // terminal +1 will contain computed value of ALK_time
    Morphcomp_obs.initialize();
    Morphcomp_obs_rd.deallocate();
    Morphcomp_obs_rd.allocate(1,Morphcomp_nobs_rd,1,5+Morphcomp_nmorph);  //  but will only get filled with the used obs
    Morphcomp_obs_rd.initialize();
//    yr, seas, fleet, partition, Nsamp, datavector
    data_type=8;  //  for morphcomp

    echoinput<<" morph composition data"<<endl<<"yr month fleet null Nsamp datavector"<<endl;
    Morphcomp_nobs=0;
    for (i=1;i<=Morphcomp_nobs_rd;i++)
    {
     *(ad_comm::global_datafile) >> Morphcomp_obs_rd(i);
      echoinput<<Morphcomp_obs_rd(i)<<endl;
      timing_input(1,3)=Morphcomp_obs_rd(i)(1,3);
      y=timing_input(1);
      if(y>=styr && y<=endyr +50)  //  obs is in year range
      {
        if(timing_input(2)<0.0)
        {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"negative month not allowed for morphcomp because superperiods not implemented "<<endl; exit(1);}
        get_data_timing(timing_input, timing_constants, timing_i_result, timing_r_result, seasdur, subseasdur_delta, azero_seas, surveytime);

        s=timing_input(2); f=abs(timing_input(3)); t=timing_i_result(2);
        ALK_time=timing_i_result(5);

        Morphcomp_nobs++;
        Morphcomp_obs(Morphcomp_nobs)(1,5+Morphcomp_nmorph)=Morphcomp_obs_rd(i)(1,5+Morphcomp_nmorph);  //  save observations to be used
        Morphcomp_obs(Morphcomp_nobs,5+Morphcomp_nmorph+1)=ALK_time;  //  for reporting
        if(y>retro_yr) Morphcomp_obs(Morphcomp_nobs,3)=-f;  //  set to dummy observation
        if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
        {data_time(ALK_time,f)(1,3)=timing_r_result(1,3);}  // real_month,fraction of season, year.fraction
        else if (timing_r_result(1) !=  data_time(ALK_time,f,1))
        {
          N_warn++;
           warning<<N_warn<<" "<<"morph_comp: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<timing_r_result(1)<<endl;
        }
        have_data(ALK_time,0,0,0)=1;
        have_data(ALK_time,f,0,0)=1;  //  so have data of some type
        have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
        p=have_data(ALK_time,f,data_type,0);
        have_data(ALK_time,f,data_type,p)=Morphcomp_nobs;  //  store data index for the p'th observation in this subseas

        Morphcomp_obs(Morphcomp_nobs)(6,5+Morphcomp_nmorph) /= sum(Morphcomp_obs(Morphcomp_nobs)(6,5+Morphcomp_nmorph));
        Morphcomp_obs(Morphcomp_nobs)(6,5+Morphcomp_nmorph) += Morphcomp_mincomp;
        Morphcomp_obs(Morphcomp_nobs)(6,5+Morphcomp_nmorph) /= sum(Morphcomp_obs(Morphcomp_nobs)(6,5+Morphcomp_nmorph));
      }
    }
    echoinput<<"processed morphcomp: Nread:"<<Morphcomp_nobs_rd<<" N save: "<<Morphcomp_nobs<<endl<<Morphcomp_obs<<endl;
  }
 END_CALCS

  int Do_SelexData;
 LOCAL_CALCS
  *(ad_comm::global_datafile) >> Do_SelexData;
   echoinput<<"Do dataread for selectivity priors(0/1):  "<<Do_SelexData<<endl;
   echoinput<<"Yr  Seas Fleet  Age/Size  Bin  selex_prior  prior_sd"<<endl;
   echoinput<<"feature not yet implemented"<<endl;
 END_CALCS

!!//  SS_Label_Info_2.14 #End of datafile indicator
  init_int fid
  !! if(fid!=999) {cout<<" final data value in error "<<fid<<endl; exit(1);}
  !! cout<<"Data read sucessful "<<fid<<endl<<endl;
  !!echoinput<<" data read successful"<<endl<<endl;

 LOCAL_CALCS
//  SS_Label_Info_3.0 #Read forecast.ss
// /*  SS_Label_Flow  #read forecast.ss */
//  note that forecast.ss is read before control file in order to st up length of some time dimension arrays
  ad_comm::change_datafile_name("forecast.ss");
  cout<<" reading forecast file "<<endl;
  ifstream Forecast_Stream("forecast.ss");   //  even if the global_datafile name is used, there still is a different logical device created
  k=0;
  N_FC=0;
  while(k==0)
  {
    Forecast_Stream >>  readline;          // reads the line from input stream
    if(length(readline)>2)
    {
      checkchar=readline(1);
      k=strcmp(checkchar,"#");
      checkchar=readline(1,2);
      j=strcmp(checkchar,"#C");
      if(j==0) {N_FC++; Forecast_Comments+=readline;}
    }
  }
 END_CALCS
  int Do_Benchmark  // 0=skip; 1= do Fspr, Fbtgt, Fmsy; 2=do Fspr, F0.1, Fmsy
  int Do_MSY   //  1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr)
  int did_MSY;
  int show_MSY;
  int wrote_bigreport;
  ivector Bmark_Yr_rd(1,10)
  ivector Bmark_Yr(1,10)
  ivector Bmark_t(1,2)  //  for range of time values for averaging body size
  number SPR_target
  number BTGT_target
  number Blim_frac

  int MSY_units // 1=dead catch, 2=retained catch, 3=retained catch profits
  vector CostPerF(1,Nfleet);
  vector PricePerF(1,Nfleet);

 LOCAL_CALCS
  echoinput<<"read Do_Benchmark(0=skip; 1= do Fspr, Fbtgt, Fmsy; 2=do Fspr, F0.1, Fmsy;  3=Fspr, Fbtgt, Fmsy, F_Blimit)"<<endl;
  *(ad_comm::global_datafile) >> Do_Benchmark;
  echoinput<<Do_Benchmark<<" echoed Do_Benchmark "<<endl;
  echoinput<<"read Do_MSY (1=F_SPR,2=F_Btarget,3=calcMSY,4=mult*F_endyr (disabled);5=calcMEY)"<<endl;
  *(ad_comm::global_datafile) >> Do_MSY;
  echoinput<<Do_MSY<<" echoed Do_MSY basis"<<endl;

    CostPerF=0.0;
    PricePerF=1.0;  // default value per mt
    MSY_units=2;  //  default to YPR_opt = dead catch without non-optimized bycatch
    if(Do_MSY==5)  //  doing advanced MSY options, including MEY
    {
      echoinput<<"enter quantity to be maximized: (1) dead catch biomass; (2) dead catch biomass w/o non-opt bycatch; or (3) retained catch profits"<<endl;
      *(ad_comm::global_datafile) >> MSY_units;
      echoinput<<MSY_units<<" # MSY_units as entered"<<endl;
      
      CostPerF.initialize();
      PricePerF.initialize();
      echoinput<<"enter fleet ID and cost per fleet; negative fleet ID fills for all higher fleet IDs, -999 exits list"<<endl;
      int fleet_ID=100;
      double tempcost;
      double tempprice;
      while(fleet_ID>-999)
      {
        *(ad_comm::global_datafile) >> fleet_ID;
        *(ad_comm::global_datafile) >> tempcost;
        *(ad_comm::global_datafile) >> tempprice;
        echoinput<<fleet_ID<<" "<<tempcost<<" "<<tempprice<<endl;
        if(fleet_ID>Nfleet)
          {N_warn++; warning<<"fleetID > Nfleet"<<endl;}
        else if(fleet_ID>0) 
          {CostPerF(fleet_ID)=tempcost; PricePerF(fleet_ID)=tempprice;}
        else if(fleet_ID>-9999)
          {
            for(f=-fleet_ID;f<=Nfleet;f++)
            {
              if(fleet_type(f)==1 || (fleet_type(f)==2 && bycatch_setup(f,3)==1)) 
               {CostPerF(f)=tempcost; PricePerF(f)=tempprice;}
            }
          }
        }
      echoinput << "# Cost-per-unit fishing mortality: " << CostPerF << endl<<"Price per kg: "<<PricePerF<<endl;
    }

  show_MSY=0;
  did_MSY=0;
  wrote_bigreport=0;
  Blim_frac=0.5;  //  default
  echoinput<<"next read SPR target and Biomass target as fractions"<<endl;
  *(ad_comm::global_datafile) >>  SPR_target;
  echoinput<<SPR_target<<" echoed SPR_target "<<endl;
  *(ad_comm::global_datafile) >>  BTGT_target;
  echoinput<<BTGT_target<<" echoed B_target "<<endl;

  if(Do_Benchmark==3)
    {
      echoinput<<"if Do_Benchmark==3, read Blimit as fraction of Bmsy (neg value to use as frac of Bzero)"<<endl;
      *(ad_comm::global_datafile) >>  Blim_frac;
      echoinput<<Blim_frac<<" echoed Blim_frac "<<endl;
    }

  echoinput<<"next read 10 Benchmark years for:  beg-end bio; beg-end selex; beg-end relF; beg-end recr_dist; beg-end SRparm"<<endl;
  echoinput<<"codes: -999 means start year; >0 is an actual year; <=0 is relative to endyr"<<endl;
  *(ad_comm::global_datafile) >> Bmark_Yr_rd(1,10);

  Bmark_Yr=0;
  if(Do_Benchmark==2 && N_bycatch>0)
  	{N_warn++;  warning<<N_warn<<" "<<"F0.1 does not work well with bycatch fleets; check output carefully"<<endl;}
  echoinput<<Bmark_Yr_rd<<" echoed Benchmark years"<<endl;
  for (i=1;i<=10;i++)  //  beg-end bio; beg-end selex; beg-end relF
  {
    if(Bmark_Yr_rd(i)==-999)
    {Bmark_Yr(i)=styr;}
    else if(Bmark_Yr_rd(i)<=0)
    {Bmark_Yr(i)=Bmark_Yr_rd(i)+endyr;}
    else if(Bmark_Yr_rd(i)<styr)
    {N_warn++; warning<<N_warn<<" "<<Bmark_Yr_rd(i)<<"benchmark year < styr; change to styr"<<endl;Bmark_Yr(i)=styr;}
    else if(Bmark_Yr_rd(i)>endyr)
    {N_warn++; warning<<N_warn<<" "<<Bmark_Yr_rd(i)<<"  benchmark year > endyr; change to endyr"<<endl; Bmark_Yr(i)=endyr;}
    else
    {Bmark_Yr(i)=Bmark_Yr_rd(i);}
  }
  Bmark_t(1)=styr+(Bmark_Yr(1)-styr)*nseas;
  Bmark_t(2)=styr+(Bmark_Yr(2)-styr)*nseas;

  echoinput<<Bmark_Yr<<" Benchmark years as processed"<<endl;
  echoinput<<"next read:  1=use range of years as read for relF; 2 = set same as forecast relF below"<<endl;
 END_CALCS
  init_int Bmark_RelF_Basis
  !!echoinput<<Bmark_RelF_Basis<<"  echoed Bmark_RelF_year basis"<<endl;

  !!echoinput<<endl<<"next read forecast basis: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (enter yrs); 5=read Fmult"<<endl;

  init_int Do_Forecast_rd
  int Do_Forecast
  !! Do_Forecast=Do_Forecast_rd;
  !!echoinput<<Do_Forecast<<" echoed Forecast basis"<<endl;

  vector Fcast_Input(1,24);

  int N_Fcast_Yrs
  ivector Fcast_yr(1,6)  // yr range for selex, then yr range for either allocation or for average F
  ivector Fcast_yr_rd(1,6)
  int Fcast_Sel_yr1
  int Fcast_Sel_yr2
  int Fcast_RelF_yr1
  int Fcast_RelF_yr2
  int Fcast_Rec_yr1
  int Fcast_Rec_yr2
  int Fcast_RelF_Basis  // 1=use year range; 2=read below
  number Fcast_Flevel
  int Do_Rebuilder
  int Rebuild_Ydecl
  int Rebuild_Yinit
  int HarvestPolicy  // 0=none; 1=west coast adjust catch; 2=AK to adjust F
  number H4010_top
  number H4010_bot
  number H4010_scale
  number H4010_scale_rd
  int Do_Impl_Error
  number Impl_Error_Std
  vector Fcast_Loop_Control(1,5)
  int N_Fcast_Input_Catches
  int Fcast_InputCatch_Basis  //  2=dead catch; 3=retained catch;  99=F; -1=read fleet/time specific  (biomass vs numbers will match catchunits(fleet)
  int Fcast_Catch_Basis  //  2=dead catch bio, 3=retained catch bio, 5= dead catch numbers 6=retained catch numbers;   Same for all fleets

  int Fcast_Catch_Allocation_Groups;
  int Fcast_Do_Fleet_Cap;
  int Fcast_Do_Area_Cap;
  int Fcast_Cap_FirstYear;
  vector Fcast_MaxFleetCatch(1,Nfleet)
  vector Fcast_MaxAreaCatch(1,pop)
  ivector Allocation_Fleet_Assignments(1,Nfleet)
  matrix Fcast_RelF_Input(1,nseas,1,Nfleet)
  int Fcast_Specify_Selex   // 0=do not use; 1=specify one selectivity for all fishing fleets for forecasts (not implemented); 2=specify selectivity per fishing fleet for forecasts (not implemented)

 LOCAL_CALCS
  Fcast_MaxFleetCatch.initialize();
  Fcast_MaxAreaCatch.initialize();
  Allocation_Fleet_Assignments.initialize();
  Fcast_Catch_Allocation.initialize();
  Fcast_RelF_Input.initialize();
  Fcast_yr.initialize();
 END_CALCS
//  init_vector Fcast_Input_rd(1,k)

 LOCAL_CALCS
  Fcast_Specify_Selex = 0;  // default

  if(Do_Forecast_rd>0)
  {
//    Fcast_Input(1,k)=Fcast_Input_rd(1,k);
//  k=0;
//  k++;
  echoinput<<endl<<"#next read N forecast years"<<endl;
  *(ad_comm::global_datafile) >> N_Fcast_Yrs;
  echoinput<<N_Fcast_Yrs<<" #echoed N_Fcast_Yrs "<<endl;
  if(Do_Forecast_rd>0 && N_Fcast_Yrs<=0) {N_warn++; cout<<"Critical error in forecast input, see warning"<<endl;  warning<<N_warn<<" "<<"ERROR: cannot do a forecast of zero years: "<<N_Fcast_Yrs<<endl; exit(1);}
  if(Do_Forecast_rd>0 && STD_Yr_max==-1) {N_warn++;  warning<<N_warn<<" "<<"note: Std_yrmax=-1 in starter, so no variance output for forecast quantities after endyr+1 "<<endl;}

  YrMax=endyr+N_Fcast_Yrs;

  echoinput<<endl<<"# next read Fmult value to be used only if Forecast basis==5"<<endl;
//  k++; Fcast_Flevel=Fcast_Input(k);
  *(ad_comm::global_datafile) >> Fcast_Flevel;
  echoinput<<Fcast_Flevel<<" # echoed Fmult value"<<endl;

  echoinput<<endl<<"# next enter Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits"<<endl<<
    "# enter actual year, or values of 0 or -integer to be relative to endyr)"<<endl;
  *(ad_comm::global_datafile) >> Fcast_yr_rd(1,6);
//  k++; Fcast_yr(1)=int(Fcast_Input(k));
//  k++; Fcast_yr(2)=int(Fcast_Input(k));
//  k++; Fcast_yr(3)=int(Fcast_Input(k));
//  k++; Fcast_yr(4)=int(Fcast_Input(k));
//  k++; Fcast_yr(5)=int(Fcast_Input(k));
//  k++; Fcast_yr(6)=int(Fcast_Input(k));

  echoinput<<Fcast_yr_rd<<" # echoed Fcast years as read"<<endl;
  Fcast_yr=Fcast_yr_rd;
  for (i=1;i<=6;i++)
  {
    if(Fcast_yr(i)==-999)
    {Fcast_yr(i)=styr;}
    else if(Fcast_yr(i)<=0)
    {Fcast_yr(i)+=endyr;}
    else if(Fcast_yr(i)<styr)
    {Fcast_yr(i)=styr;}
    else if(Fcast_yr(i)>endyr)
    {Fcast_yr(i)=endyr;}
    else
    {}//  OK in range
  }
  Fcast_Sel_yr1=Fcast_yr(1);
  Fcast_Sel_yr2=Fcast_yr(2);
  Fcast_RelF_yr1=Fcast_yr(3);
  Fcast_RelF_yr2=Fcast_yr(4);
  Fcast_Rec_yr1=Fcast_yr(5);
  Fcast_Rec_yr2=Fcast_yr(6);
  echoinput<<Fcast_yr<<"  # After Transformation"<<endl;

  echoinput<<endl<<"# next read flag for specifying selectivity used in forecasts; 0 is value that mimics 3.24, 1 is experimental"<<endl;
  *(ad_comm::global_datafile) >> Fcast_Specify_Selex;
  echoinput<<Fcast_Specify_Selex<<" # echoed Fcast_Specify_Selex value"<<endl;

  echoinput<<endl<<"next read 4 values for:  control rule shape(0, 1, 2, 3 or 4), inflection (like 0.40), cutoff(like 0.10), scale(like 0.75)"<<endl;
  *(ad_comm::global_datafile) >> HarvestPolicy;
  if(HarvestPolicy==0) echoinput<<"HarvestPolicy=0, so values for top, bottom, buffer will be ignored"<<endl;

  echoinput<<HarvestPolicy<<"  # echoed HarvestPolicy "<<endl;
  *(ad_comm::global_datafile) >> H4010_top;
  echoinput<<H4010_top<<"   # echoed harvest policy inflection "<<endl;
  *(ad_comm::global_datafile) >> H4010_bot;
  echoinput<<H4010_bot<<"   # echoed harvest policy cutoff "<<endl;
  *(ad_comm::global_datafile) >> H4010_scale_rd;
    H4010_scale=H4010_scale_rd;
  echoinput<<H4010_scale<<"   # echoed harvest policy scalar "<<endl;
  if(H4010_top<=H4010_bot) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" control rule inflection: "<<H4010_top<<" must be > control rule bottom "<<H4010_bot<<endl; exit(1);}
  if(H4010_scale>1.0) {N_warn++;  warning<<N_warn<<" Sure you want control rule scalar > 1.0? "<<H4010_scale<<endl;}

  if(H4010_scale<0.0)
  {
     echoinput<<"# now read pairs of year,H4010scale; each read fills from that year to YrMax; end with year<0.0 "<<endl;
     ender=0;
     do {
        dvector tempvec(1,2);
        *(ad_comm::global_datafile) >> tempvec(1,2);
        if(tempvec(1)<0.0) ender=1;
        H4010_scale_vec_rd.push_back (tempvec(1,2));
        echoinput<<" H4010 read: "<<tempvec(1,2)<<endl;
      } while (ender==0);
  }

  echoinput<<endl<<"# next enter 2 values that control looping through the forecast (see manual), then 3 placeholder values"<<endl;
  echoinput<<"# first does F_msy or proxy; 2nd applies control rule; 3rd applies caps and allocations"<<endl;
  *(ad_comm::global_datafile) >> Fcast_Loop_Control(1,5);
  echoinput<<Fcast_Loop_Control(1)<<" #echoed N forecast loops (1-3) (recommend 3)"<<endl;
  echoinput<<Fcast_Loop_Control(2)<<" #echoed First forecast loop with stochastic recruitment (recommend 3)"<<endl;
  echoinput<<Fcast_Loop_Control(3)<<" #echoed Forecast recruitment:  0=spawn_recr; 1=value*spawn_recr; 2=value*VirginRecr; 3=mean from year range"<<endl;
  if(Fcast_Loop_Control(3)==0)
    {echoinput<<Fcast_Loop_Control(4)<<" #echoed Forecast loop control #4 (not used) "<<endl;}
  else if(Fcast_Loop_Control(3)==1)
    {echoinput<<Fcast_Loop_Control(4)<<" #echoed Forecast loop control #4:  multiplier on spawn_recr"<<endl;}
  else if(Fcast_Loop_Control(3)==2)
    {echoinput<<Fcast_Loop_Control(4)<<" #echoed Forecast loop control #4:  multiplier on virgin recr"<<endl;}
  else if(Fcast_Loop_Control(3)==3)
    {echoinput<<" #mean recruitment and recrdist from years: "<<Fcast_Rec_yr1<<" to "<<Fcast_Rec_yr2<<endl;}
  else //  input probably was a -1 from pre 3.30.15, so convert to 0
    {  Fcast_Loop_Control(3)=0; Fcast_Loop_Control(4)=1.0;
    	echoinput<<Fcast_Loop_Control(4)<<" #echoed Forecast loop control #4:  multiplier on spawn_recr"<<endl;}

  echoinput<<Fcast_Loop_Control(5)<<" #echoed Forecast loop control #5 (reserved for future use) "<<endl;

  echoinput<<endl<<"#next enter year in which Fcast loop 3 caps and allocations begin to be applied"<<endl;
  *(ad_comm::global_datafile) >> Fcast_Cap_FirstYear;
  echoinput<<Fcast_Cap_FirstYear<<" # echoed value"<<endl;

  echoinput<<endl<<"#next enter 0, or stddev of implementation error"<<endl;
  *(ad_comm::global_datafile) >> Impl_Error_Std;
  echoinput<<Impl_Error_Std<<" # echoed value"<<endl;
  if(Impl_Error_Std>0.0){
  	if(Do_Forecast_rd>0){
  	 Do_Impl_Error=1;  //  OK to do impl error because forecast occurs
  	}
  	else
  	{N_warn++; warning<<N_warn<<"; changing Imple_Error to 0 because no forecast "<<endl; Impl_Error_Std=0.0; Do_Impl_Error=0;}
  }

  echoinput<<endl<<"#next select rebuilding program output (0/1)"<<endl;
  *(ad_comm::global_datafile) >> Do_Rebuilder;
  echoinput<<Do_Rebuilder<<" # echoed value"<<endl;

  echoinput<<endl<<"#next select rebuilding program:  year declared overfished"<<endl;
  *(ad_comm::global_datafile) >> Rebuild_Ydecl;
  echoinput<<Rebuild_Ydecl<<" # echoed value"<<endl;

  echoinput<<endl<<"#next select rebuilding program:  year rebuilding plan started"<<endl;
  *(ad_comm::global_datafile) >> Rebuild_Yinit;
  echoinput<<Rebuild_Yinit<<" # echoed value"<<endl;

  echoinput<<endl<<"#next select fleet relative F:  1=use first-last alloc year read above; 2=read list of seas, fleet, relF below"<<endl;
  echoinput<<"# Note that fleet allocation is used directly as average F if Do_Forecast=4 "<<endl;
  *(ad_comm::global_datafile) >> Fcast_RelF_Basis;
  echoinput<<Fcast_RelF_Basis<<" # echoed value"<<endl;
  if(Do_Forecast_rd==4 && Fcast_RelF_Basis==2)
  {
    N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Cannot specify forecast fleet relative F because Do_Forecast==4 specifies relative F directly as F;"<<endl;
    echoinput<<"Cannot specify forecast fleet relative F because Do_Forecast==4 specifies relative F directly as F;"<<endl;
    echoinput<<"exit:  need to align choice of forecast basis and forecast relative F basis"<<endl;
    exit(1);
  }

  echoinput<<endl<<"#next read Catch Basis for caps and allocations;  Same for all fleets"<<endl;
  echoinput<<"2=dead catch bio, 3=retained catch bio, 5= dead catch numbers 6=retained catch numbers"<<endl;
  *(ad_comm::global_datafile) >> Fcast_Catch_Basis;
  echoinput<<Fcast_Catch_Basis<<" # echoed value"<<endl;
  if(Fcast_Catch_Basis<2 || Fcast_Catch_Basis>6)
    {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"illegal value for Fcast_Catch_Basis"<<endl; echoinput<<"exit:  illegal value for Fcast_Catch_Basis"<<endl; exit(1);}

  if(Fcast_RelF_Basis==2)
  {
    ivector  checkfleet(1,Nfleet);
    checkfleet.initialize();
    echoinput<<endl<<"Fcast_RelF_Basis==2, so now read list of seas, fleet#, relF_value"<<endl<<
    "Terminate with -9999 for season"<<endl<<"Will be re-scaled to sum to 1.0"<<endl;
    ender=0;
    do {
      dvector tempvec(1,3);
      *(ad_comm::global_datafile) >> tempvec(1,3);
      echoinput<<tempvec<<endl;
      if(tempvec(1)==-9999.)
      {ender=1;}
      else
      {
        s=int(tempvec(1));
        f=int(tempvec(2));
        if(fleet_type(f)<=2)
        {Fcast_RelF_Input(s,f)=tempvec(3);  checkfleet(f)=1;}
        else
        {cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"forecast exit for fleet "<<f<<"  ;cannot set fcast relF for survey fleets"<<endl; exit(1);}
      }
    } while (ender==0);
    echoinput<<" fleet relative F by season and fleet as read"<<endl<<Fcast_RelF_Input<<endl;
    for(f=1;f<=Nfleet;f++)
    {
      if(fleet_type(f)==1 && checkfleet(f)==0)
        {N_warn++;  warning<<N_warn<<" "<<"fleet: "<<f<<" "<<fleetname(f)<<"  is a fishing fleet but forecast relF not read"<<endl;}
    }
  }
  else
  {}
  }

  else  //  set forecast defaults
  {
    N_warn++;  warning<<N_warn<<" "<<"Forecast=0 or -1, so rest of forecast file will not be read and can be omitted;"<<endl;
    if(Bmark_RelF_Basis==2) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Fatal stop:  no forecast, but bmark set to use fcast"<<endl;  exit(1);}
  if(Do_Forecast==0)
  	{
       warning<<N_warn<<" "<<"A one year forecast using recent F will be done automatically"<<endl;
  		Do_Forecast=4;  //  sets simple forecast; else Do_Forecast==-1 causes no forecast
      N_Fcast_Yrs=1;
      YrMax=endyr+1;
    }
    else
  	{
  		Do_Forecast=-1;  //  no forecast
      N_Fcast_Yrs=0;
      YrMax=endyr;
    }

  Fcast_Flevel=1.;
  Fcast_yr=0;
  Fcast_yr_rd=0;
  Fcast_RelF_Basis=1;
  Fcast_Sel_yr1=endyr;
  Fcast_Sel_yr2=endyr;
  Fcast_RelF_yr1=endyr;
  Fcast_RelF_yr2=endyr;
  Fcast_Rec_yr1=styr;
  Fcast_Rec_yr2=endyr;
  HarvestPolicy=0;
  H4010_top=0.001;
  H4010_bot=0.0001;
  H4010_scale_rd=1.0;
  H4010_scale=1.0;
  Fcast_Loop_Control.fill("{2,1,0,0,0}");
  Fcast_Cap_FirstYear=endyr+1;
  Impl_Error_Std=0.0;
  Do_Impl_Error=0;
  Do_Rebuilder=0;
  Rebuild_Ydecl=endyr;
  Rebuild_Yinit=endyr;
  Fcast_RelF_Basis=1;
  Fcast_Catch_Basis=2;
  }  //  end of defaults for do_forecast = 0

 END_CALCS

  matrix Fcast_Catch_Allocation(1,N_Fcast_Yrs,1,Nfleet);  //   dimension to Nfleet but use only to N alloc groups
  vector H4010_scale_vec(endyr+1,YrMax);

 LOCAL_CALCS
  if(Do_Forecast_rd>0)
  {
    echoinput<<endl<<"# next read list of fleet ID and max annual catch;  end with fleet=-9999"<<endl;
    for(f=1;f<=Nfleet;f++) Fcast_MaxFleetCatch(f)=-1;
    Fcast_Do_Fleet_Cap=0;
    ender=0;
    do {
      dvector tempvec(1,2);
      *(ad_comm::global_datafile) >> tempvec(1,2);
      echoinput<<tempvec<<endl;
      if(tempvec(1)==-9999.)
      {ender=1;}
      else
      {
        f=int(tempvec(1));
        if(fleet_type(f)<=2)
        {Fcast_MaxFleetCatch(f)=tempvec(2);}
        else
        {cout<<" EXIT - see warning "<<endl; warning<<"exit for fleet "<<f<<"  ;  can only set max catch for retained or discard catch fleets"<<endl; exit(1);}
        Fcast_Do_Fleet_Cap=1;
      }
    } while (ender==0);
    echoinput<<" Processed Max totalcatch by fleet "<<endl<<Fcast_MaxFleetCatch<<endl;

    echoinput<<endl<<"Read list of area ID and max annual catch;  end with area=-9999"<<endl;
    for(p=1;p<=pop;p++) Fcast_MaxAreaCatch(p)=-1;
    Fcast_Do_Area_Cap=0;
    ender=0;
    do {
      dvector tempvec(1,2);
      *(ad_comm::global_datafile) >> tempvec(1,2);
      echoinput<<tempvec<<endl;
      if(tempvec(1)==-9999.)
      {ender=1;}
      else
      {
        p=int(tempvec(1));
        Fcast_MaxAreaCatch(p)=tempvec(2);
        Fcast_Do_Area_Cap=1;
      }
    } while (ender==0);
    echoinput<<" processed Max totalcatch by area "<<endl<<Fcast_MaxAreaCatch<<endl;

    echoinput<<endl<<"Read list of fleet ID and assignment to allocation group;  end with fleet ID=-9999"<<endl;
    echoinput<<"fishing fleets not assigned to allocation group are processed normally"<<endl;
    Allocation_Fleet_Assignments.initialize();
    Fcast_Catch_Allocation_Groups=0;
    ender=0;
    do {
      dvector tempvec(1,2);
      *(ad_comm::global_datafile) >> tempvec(1,2);
      echoinput<<tempvec<<endl;
      if(tempvec(1)==-9999.)
      {ender=1;}
      else
      {
        f=int(tempvec(1));
        if(fleet_type(f)==1)
        {Allocation_Fleet_Assignments(f)=tempvec(2);}
        else
        {cout<<" EXIT - see warning "<<endl; N_warn++; warning<<N_warn<<" exit for fleet "<<f<<"  ;  can only put retained catch fleets in allocation groups"<<endl; exit(1);}
      }
    } while (ender==0);

    Fcast_Catch_Allocation_Groups=max(Allocation_Fleet_Assignments);
    echoinput<<" Processed Fleet allocation group assignments "<<endl<<Allocation_Fleet_Assignments<<endl;

    Fcast_Catch_Allocation.initialize();
    if(Fcast_Catch_Allocation_Groups>0)
    {
      echoinput<<"# now read fraction of catch for each identified allocation group "<<endl;
      ender=0;
      k=Fcast_Catch_Allocation_Groups+1;
      do {
        dvector tempvec(1,k);
        *(ad_comm::global_datafile) >> tempvec(1,k);
        if(tempvec(1)==-9999.) ender=1;
        Fcast_Catch_Allocation_list.push_back (tempvec(1,k));
        echoinput<<" allocation assignment: "<<tempvec(1,k)<<endl;
      } while (ender==0);
      j=Fcast_Catch_Allocation_list.size()-1;

      if (j == 0)
      {
        N_warn++;
        cout<<" EXIT - see warning "<<endl;
         warning<<N_warn<<" "<<"Error: there are no allocation fractions specified and there are "<<Fcast_Catch_Allocation_Groups<<" allocation groups"<<endl;
        echoinput<<"Error: there are no allocation fractions specified and there are "<<Fcast_Catch_Allocation_Groups<<" allocation groups"<<endl;

        exit(1);
      }

        for(k=0;k<=j-1;k++)
        {
          for(y=Fcast_Catch_Allocation_list[k](1)-endyr;y<=N_Fcast_Yrs;y++)  //  assign input from the input year through last forecast year
          {
            for(a=1;a<=Fcast_Catch_Allocation_Groups;a++)
            {
              Fcast_Catch_Allocation(y,a)=Fcast_Catch_Allocation_list[k](a+1);
            }
          }
        }
        echoinput<<"processed allocation groups by year"<<endl;
        for(y=1;y<=N_Fcast_Yrs;y++)
        {
        	if(sum(Fcast_Catch_Allocation(y))==0.0)
        		{N_warn++; warning<<N_warn<<" Fcast_Catch_allocation is blank for year: "<<y+endyr<<"; SS3 assigning uniform; can override with input catches"<<endl;
        	Fcast_Catch_Allocation(y)(1,Fcast_Catch_Allocation_Groups)=1.0;}
        	else
        	{Fcast_Catch_Allocation(y)/=sum(Fcast_Catch_Allocation(y)(1,Fcast_Catch_Allocation_Groups));}
        echoinput<<y+endyr<<" "<<Fcast_Catch_Allocation(y)(1,Fcast_Catch_Allocation_Groups)<<endl;
        }
    }

    *(ad_comm::global_datafile) >> Fcast_InputCatch_Basis;
    echoinput<<Fcast_InputCatch_Basis<<" # basis for input Fcast catch:  -1= read with each obs; 2=dead catch; 3=retained catch; 99=input Hrate(F); -1=read fleet/time specific (bio/num units are from fleetunits; note new codes in SSV3.20)"<<endl;
    k1 = styr+(endyr-styr)*nseas-1 + nseas + 1;
    y=k1+(N_Fcast_Yrs)*nseas-1;
    if(Fcast_InputCatch_Basis==-1)
    {j=5; echoinput<<"# yr seas fleet catch basis"<<endl;}
    else
    {j=4;echoinput<<"# yr seas fleet catch"<<endl;}

    ender=0;
    do {
      dvector tempvec(1,j);
      *(ad_comm::global_datafile) >> tempvec(1,j);
      if(tempvec(1)==-9999.) ender=1;
      Fcast_InputCatch_list.push_back (tempvec(1,j));
      echoinput<<tempvec<<endl;
    } while (ender==0);
    N_Fcast_Input_Catches=Fcast_InputCatch_list.size()-1;
  }
  else
  {
    N_Fcast_Input_Catches=0;
    Fcast_InputCatch_Basis=2;
    k1=1;
    y=0;
    j=0;
    fif=999;
  }

 END_CALCS

  3darray Fcast_InputCatch(k1,y,1,Nfleet,1,2)  //  values and basis to be used
  matrix Fcast_InputCatch_rd(1,N_Fcast_Input_Catches,1,j)
  imatrix Fcast_RelF_special(1,nseas,1,Nfleet)  //  records whether an input catch or F occurs

 LOCAL_CALCS
  Fcast_InputCatch.initialize();
  Fcast_InputCatch_rd.initialize();
  Fcast_RelF_special.initialize();
  if(Do_Forecast_rd>0)
  {
    if(N_Fcast_Input_Catches>0)
    {
      for (t=k1;t<=y;t++)
      for (f=1;f<=Nfleet;f++)
      {Fcast_InputCatch(t,f,1)=-1;}

      for (i=0;i<=N_Fcast_Input_Catches-1;i++)
      {
   echoinput<<i<<" "<<Fcast_InputCatch_list[i]<<endl;
        Fcast_InputCatch_rd(i+1)=Fcast_InputCatch_list[i];
        y=Fcast_InputCatch_rd(i+1,1); s=Fcast_InputCatch_rd(i+1,2); f=Fcast_InputCatch_rd(i+1,3);
        if(y>endyr && y<=YrMax && fleet_type(f)<=2)
        {
        	Fcast_RelF_special(s,f)=1;
          t=styr+(y-styr)*nseas +s-1;
          Fcast_InputCatch(t,f,1)=Fcast_InputCatch_rd(i+1,4);
          if(y>=Fcast_Cap_FirstYear) {N_warn++; warning<<N_warn<<" "<<"Input catches in "<<y<<" can be overridden by caps or allocations"<<endl;}
          if(Fcast_InputCatch_Basis==-1)
          {
            Fcast_InputCatch(t,f,2)=Fcast_InputCatch_rd(i+1,5);  //  new method
          }
          else
          {
            Fcast_InputCatch(t,f,2)=Fcast_InputCatch_Basis;  //  method before 3.24P
          }
      	}
      }
    }
  }

  H4010_scale_vec.initialize();
  if(H4010_scale_rd>=0.0)
    {
      echoinput<<"fill H4010_scale_vec with single input"<<endl;
      H4010_scale_vec=H4010_scale_rd;
    }
    else
    {
      echoinput<<"fill H4010_scale_vec from input list; filling from read year to YrMax for each input"<<endl;
      j=H4010_scale_vec_rd.size()-1;
      int last_rd_yr;
      last_rd_yr=endyr;
      for (int s=0; s<=j-1; s++) //  loop input
      {
        y=H4010_scale_vec_rd[s](1);
        echoinput<<H4010_scale_vec_rd[s]<<endl;
        if(y<=endyr)
          {N_warn++;  warning<<N_warn<<"; "<<y<<" is <= endyr; set to endyr+1 "<<endl; echoinput<<"set to endyr+1 "<<endl; y=endyr+1;}
        if(y<=last_rd_yr)
          {N_warn++;  warning<<N_warn<<"; "<<y<<" is <= last_rd_yr; overwrite will occur "<<endl; echoinput<<"<= last_rd_yr; overwrite "<<endl;}
          last_rd_yr=y;
        if(y>YrMax)
          {N_warn++;  warning<<N_warn<<"; "<<y<<" is > YrMax; set to YrMax "<<endl; y=YrMax;}
        for(k=y;k<=YrMax;k++)
        {
          H4010_scale_vec(k)=H4010_scale_vec_rd[s](2);
        }
      }
    }
  echoinput<<"H4010_scale: "<<H4010_scale_vec<<endl;

  if(Do_Rebuilder>0 && Do_Forecast_rd<=0) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" error: Rebuilder output selected without requesting forecast"<<endl; exit(1);}
  if(Do_Benchmark==0)
  {
    if(Do_Forecast_rd>=1 && Do_Forecast_rd<=3) {Do_Benchmark=1; N_warn++;  warning<<N_warn<<" Turn Benchmark on because Forecast needs it"<<endl;}
    if(Do_Forecast==0 && F_std_basis>0) {F_std_basis=0; N_warn++;  warning<<N_warn<<" Set F_std_basis=0 because no benchmark or forecast"<<endl;}
    if(depletion_basis==2) {depletion_basis=1; N_warn++;  warning<<N_warn<<" Change depletion basis to 1 because benchmarks are off"<<endl;}
    if(SPR_reporting>=1 && SPR_reporting<=3) {SPR_reporting=4; N_warn++;  warning<<N_warn<<" Change SPR_reporting to 4 because benchmarks are off"<<endl;}
  }
  else
  {
     if(Do_MSY==0)  {Do_MSY=1; N_warn++;  warning<<N_warn<<" Setting Do_MSY=1 because benchmarks are on"<<endl;}
  }
//  if(Do_Forecast==2 && Do_MSY!=2) {Do_MSY=2; N_warn++;  warning<<N_warn<<" Set MSY option =2 because Forecast option =2"<<endl;}
//  if(depletion_basis==2 && Do_MSY!=2) {Do_MSY=2; N_warn++;  warning<<N_warn<<" Set MSY option =2 because depletion basis is B_MSY"<<endl;}
//  if(SPR_reporting==2 && Do_MSY!=2) {Do_MSY=2; N_warn++;  warning<<N_warn<<" Set MSY option =2 because SPR basis is SPR_MSY"<<endl;}
  if(Fcast_Sel_yr1>Fcast_Sel_yr2) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Sel_Yr1 must be at or before Fcast_Sel_Yr2"<<endl;  exit(1);}
  if(Fcast_Sel_yr1>endyr || Fcast_Sel_yr1<styr) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Sel_Yr1 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Sel_yr2>endyr || Fcast_Sel_yr2<styr) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Sel_Yr2 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Rec_yr1>Fcast_Rec_yr2) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Rec_Yr1 must be at or before Fcast_Rec_Yr2"<<endl;  exit(1);}
  if(Fcast_Rec_yr1>endyr || Fcast_Rec_yr1<styr) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Rec_Yr1 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Rec_yr2>endyr || Fcast_Rec_yr2<styr) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" Error, Fcast_Rec_Yr2 must be between styr and endyr"<<endl;  exit(1);}

  did_MSY=0;
  if(Do_Forecast>0) *(ad_comm::global_datafile) >> fif;

  if(Do_Forecast_rd>0 && fif!=999) {cout<<" EXIT, must have 999 to verify end of forecast inputs "<<fif<<endl; exit(1);}
  echoinput<<" done reading forecast "<<endl<<endl;
//  if(Do_Forecast==0) Do_Forecast=4;
    TimeMax_Fcast_std = styr+(max(YrMax,endyr+50)-styr)*nseas+nseas-1;

// redefine ALK_time_max for forecast years longer than 50, but no data past 50 years
    j=max(YrMax,endyr+50);
    ALK_time_max=(j-styr+1)*nseas*N_subseas;  //  sets maximum size for data array indexing 50 years into forecast
 END_CALCS

  imatrix Show_Time(styr,TimeMax_Fcast_std,1,2)  //  for each t:  shows year, season
  imatrix Show_Time2(1,ALK_time_max,1,3)  //  for each ALK_time:  shows year, season, subseas
 LOCAL_CALCS
  t=styr-1;
  for (y=styr;y<=max(YrMax,endyr+50);y++) /* SS_loop:  fill Show_Time(t,1) with year value */
  for (s=1;s<=nseas;s++) /* SS_loop:  fill Show_Time(t,2) with season value */
  {
    t++;
    Show_Time(t,1)=y;
    Show_Time(t,2)=s;
  }
  ALK_idx=0;
  for (y=styr;y<=max(YrMax,endyr+50);y++)
  for (s=1;s<=nseas;s++)
  for (subseas=1;subseas<=N_subseas;subseas++)
  {
    ALK_idx++;
    Show_Time2(ALK_idx,1)=y;
    Show_Time2(ALK_idx,2)=s;
    Show_Time2(ALK_idx,3)=subseas;
  }
 END_CALCS

//  matrix env_data_RD(styr-1,YrMax,1,N_envvar)
  vector env_data_mean(1,N_envvar)
  vector env_data_stdev(1,N_envvar)
  vector env_data_N(1,N_envvar)
  ivector env_data_minyr(1,N_envvar)
  ivector env_data_maxyr(1,N_envvar)
  ivector env_data_do_mean(1,N_envvar)
  ivector env_data_do_stdev(1,N_envvar)

 LOCAL_CALCS
  {
  env_data_mean.initialize();
  env_data_stdev.initialize();
  env_data_N.initialize();
  env_data_minyr.initialize();
  env_data_maxyr.initialize();
  env_data_do_mean.initialize();
  env_data_do_stdev.initialize();

  if(N_envdata>0)
  {
  	env_data_minyr=9876;
    for (i=0;i<=N_envdata-1;i++)
    {
    	y=env_temp[i](1);
    	k=env_temp[i](2);
    	if(y<=-1)  //  flag to do_mean  so use -2 to get mean but not stdev
    	{env_data_do_mean(k)=1;}
    	if(y==-1)  //  flag to do_stdev
    	{env_data_do_stdev(k)=1;}
      if(y>=(styr-1) && y<=YrMax)
    	{
        env_data_mean(k)+=env_temp[i](3);
        env_data_stdev(k)+=env_temp[i](3)*env_temp[i](3);
        env_data_N(k)++;
        env_data_minyr(k)=min(env_data_minyr(k),y);
        env_data_maxyr(k)=max(env_data_maxyr(k),y);
      }
    }
    echoinput<<" process environmental input data"<<endl;
    for(k=1;k<=N_envvar;k++)
    {
    	if(env_data_N(k)>0)
    	{
    		env_data_mean(k)/=env_data_N(k);
    	}
    	else
    	{//  no data
    	}
    	if(env_data_N(k)>1)
    	{
    		temp=env_data_stdev(k)/(env_data_N(k)-1.);
    		env_data_stdev(k)=sqrt(temp-env_data_mean(k)*env_data_mean(k));
    	}
    	else
    	{//  no data
    	}
      echoinput<<k<<" N "<<env_data_N(k)<<" min-max yr "<<env_data_minyr(k)<<" "<<env_data_maxyr(k)<<" mean "<<env_data_mean(k)<<" stdev "<<env_data_stdev(k)<<" subtract mean "<<env_data_do_mean(k)<<" divide stddev "<<env_data_do_stdev(k)<<endl;
    }
  }
  }
 END_CALCS


!!//  SS_Label_Info_3.2 #Create complete list of years for STD reporting
  ivector STD_Yr_Reverse(styr-2,YrMax)
  ivector STD_Yr_Reverse_Dep(styr-2,YrMax)
  ivector STD_Yr_Reverse_Ofish(styr-2,YrMax)
  ivector STD_Yr_Reverse_F(styr-2,YrMax)
  int N_STD_Yr_Dep;
  int N_STD_Yr_Ofish;
  int N_STD_Yr_F;
  int N_STD_Mgmt_Quant;

 LOCAL_CALCS
  if(STD_Yr_min<0 || STD_Yr_min<(styr-2) ) STD_Yr_min=styr-2;
  if(STD_Yr_max==-1) STD_Yr_max=endyr+1;
  if(STD_Yr_max==-2) STD_Yr_max=YrMax;
  if(STD_Yr_max>YrMax) STD_Yr_max=YrMax;
   STD_Yr_Reverse.initialize();
   for (y=STD_Yr_min;y<=STD_Yr_max;y++) {STD_Yr_Reverse(y)=1;}
   STD_Yr_Reverse(styr-2)=1;
   STD_Yr_Reverse(styr-1)=1;
   STD_Yr_Reverse(styr)=1;
   for (i=1;i<=N_STD_Yr_RD;i++)
   {if(STD_Yr_RD(i)>=styr && STD_Yr_RD(i)<YrMax) {STD_Yr_Reverse(STD_Yr_RD(i))=1;}}

   N_STD_Yr=sum(STD_Yr_Reverse);
 END_CALCS

 LOCAL_CALCS
  STD_Yr_Reverse_Dep.initialize();
  STD_Yr_Reverse_Ofish.initialize();
  STD_Yr_Reverse_F.initialize();
  j=0;
  N_STD_Yr_Dep=0;
  N_STD_Yr_Ofish=0;
  N_STD_Yr_F=0;

  echoinput<<"SPR_reporting "<<SPR_reporting<<endl;
  echoinput<<"F_reporting "<<F_reporting<<endl;
  for (y=styr-2;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse(y)>0)
    {
      j++;
      STD_Yr_Reverse(y)=j;  // use for SPB and recruitment
      if(y>=styr)
      {
      // depletion must start in year AFTER first catch.  It could vary earlier if recdevs happened enough earlier to change spbio, but this is not included
      if((depletion_basis>0 && y>first_catch_yr) || y==endyr) {N_STD_Yr_Dep++; STD_Yr_Reverse_Dep(y) = N_STD_Yr_Dep; }
      if(y<=endyr)
      {
        if((SPR_reporting>0 && totcat(y)>0.0) || y==endyr) {N_STD_Yr_Ofish++; STD_Yr_Reverse_Ofish(y) = N_STD_Yr_Ofish; }
        if((F_reporting>0 && totcat(y)>0.0) || y==endyr) {N_STD_Yr_F++; STD_Yr_Reverse_F(y) = N_STD_Yr_F; }
      }
      else
      {
        if(SPR_reporting>0) {N_STD_Yr_Ofish++; STD_Yr_Reverse_Ofish(y) = N_STD_Yr_Ofish; }
        if(F_reporting>0) {N_STD_Yr_F++; STD_Yr_Reverse_F(y) = N_STD_Yr_F; }
      }

      }
    }
  }
  echoinput<<"Finished creating STD containers and indexes "<<endl
  <<" STD_SSB_Recr "<<STD_Yr_Reverse<<endl
  <<" STD_deplet "<<STD_Yr_Reverse_Dep<<endl
  <<" STD_SPR "<<STD_Yr_Reverse_Ofish<<endl
  <<" STD_F "<<STD_Yr_Reverse_F<<endl;
 END_CALCS
