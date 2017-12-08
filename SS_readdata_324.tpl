// /*  SS_Label_Flow  read data file named in STARTER.SS file */
  //  SS_Label_Info_2.0 #READ DATA FILE
  //  SS_Label_Info_2.1 #Read comments and dimension info
  //  SS_Label_Info_2.1.1 #Read and save comments at top of data file
 LOCAL_CALCS
  ad_comm::change_datafile_name(datfilename);
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
   read_seas_mo=1;
  *(ad_comm::global_datafile) >> styr;  //start year of the model
  echoinput<<styr<<" start year "<<endl;

  *(ad_comm::global_datafile) >> endyr; // end year of the model
  echoinput<<endyr<<" end year "<<endl;

 END_CALCS

  init_int nseas  //  number of seasons
 !!echoinput<<nseas<<" N seasons "<<endl;

  init_vector seasdur(1,nseas) // season duration; enter in units of months, fractions OK; will be rescaled to sum to 1.0 if total is greater than 11.9
 !!echoinput<<seasdur<<" months/seas (fractions OK) "<<endl;

  int N_subseas  //  number of subseasons within season; must be even number to get one to be mid_season
 LOCAL_CALCS
  N_subseas=2;
  echoinput<<N_subseas<<" Number of subseasons (even number only; min 2) for calculation of ALK "<<endl;
  mid_subseas=N_subseas/2 + 1;
 END_CALCS

  int TimeMax
  int TimeMax_Fcast_std

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
    {seasdur /=sumseas;}
  else
    {seasdur /=12.;}
  seasdur_half = seasdur*0.5;   // half a season
  subseasdur_delta=seasdur/double(N_subseas);
  TimeMax = styr+(endyr+20-styr)*nseas+nseas-1;
  retro_yr=endyr+retro_yr;

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
      spawn_month=1.0 + azero_seas(spawn_seas)*12.;
      spawn_subseas=1;
      spawn_time_seas=0.0;
    }
  else  //  reading values of month
    {
      spawn_month=spawn_rd;
      temp1=(spawn_month-1.0)/12.;  //  spawn_month as fraction of year
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
     N_warn++; warning<<" spawn_seas index must be <= nseas "<<endl;
   }
 END_CALCS
  int pop   // number of areas (populations)
  int gender  //  number of sexes
  int nages  //  maxage as accumulator
  int nages2  //  doubled vector to store males after females = gender*nages+gender-1
  int Nsurvey
  int Nfleet
  int Nfleet1  // used with 3.24 for number of fishing fleets

 LOCAL_CALCS
    *(ad_comm::global_datafile) >> Nfleet1;
    *(ad_comm::global_datafile) >> Nsurvey;
    Nfleet=Nfleet1+Nsurvey;
    echoinput<<Nfleet1<<" "<<Nsurvey<<"  Nfleetss and surveys "<<endl;
    *(ad_comm::global_datafile) >> pop;
    echoinput<<pop<<" N_areas "<<endl;
    if(pop>1 && F_reporting==3)
    {N_warn++; warning<<" F-reporting=3 (sum of full Fs) not advised in multiple area models "<<endl;}
 END_CALCS

//  SS_Label_Info_2.1.5  #Define fleets, surveys and areas
  imatrix pfleetname(1,Nfleet,1,2)
  ivector fleet_type(1,Nfleet)   // 1=fleet with catch; 2=discard only fleet with F; 3=survey(ignore catch); 4=ignore completely
  ivector need_catch_mult(1,Nfleet)  // 0=no, 1=need catch_multiplier parameter
  vector surveytime(1,Nfleet)   // fraction of season (not year) in which survey occurs
  ivector fleet_area(1,Nfleet)    // areas in which each fleet/survey operates
  vector catchunits1(1,Nfleet1)  // 1=biomass; 2=numbers
  vector catch_se_rd1(1,Nfleet1)  // units are se of log(catch); use -1 to ignore input catch values for discard only fleets
  vector catchunits(1,Nfleet)
  vector catch_se_rd(1,Nfleet)
  matrix catch_se(styr-nseas,TimeMax,1,Nfleet);
  matrix fleet_setup(1,Nfleet,1,5)  // type, timing, area, units, need_catch_mult
  matrix bycatch_setup(1,Nfleet,1,6)
  vector YPR_mask(1,Nfleet)
  int N_bycatch;  //  number of bycatch only fleets
  int N_catchfleets; //  number of bycatch plus landed catch fleets

  ivector retParmLoc(1,2*Nfleet)    // could have both retained and disc mort params for each fleet
  int N_retParm

 LOCAL_CALCS
  bycatch_setup.initialize();
  YPR_mask.initialize();
    *(ad_comm::global_datafile) >> fleetnameread;
  for (f=1;f<=Nfleet;f++) {pfleetname(f,1)=1; pfleetname(f,2)=1;}    /* SS_loop: set pointer to fleetnames to default in case not enough names are read */
  f=1;
  for (i=1;i<=strlen(fleetnameread);i++)  /* SS_loop: read string of fllenames by character */
  if(adstring(fleetnameread(i))==adstring("%"))
   {pfleetname(f,2)=i-1; f+=1;  pfleetname(f,1)=i+1;}
  pfleetname(Nfleet,2)=strlen(fleetnameread);
  for (f=1;f<=Nfleet;f++)  /* SS_loop: move fleetnames into array of strings */
  {
    fleetname+=fleetnameread(pfleetname(f,1),pfleetname(f,2))+CRLF(1);
  }
  echoinput<<fleetname<<endl;

    *(ad_comm::global_datafile) >> surveytime;
    echoinput<<surveytime<<" surveytime "<<endl;
    *(ad_comm::global_datafile) >> fleet_area;
    echoinput<<fleet_area<<" fleet_area "<<endl;
    *(ad_comm::global_datafile) >> catchunits1;
    echoinput<<catchunits1<<" catchunits "<<endl;
    *(ad_comm::global_datafile) >> catch_se_rd1;
    echoinput<<catch_se_rd1<<" catch_se "<<endl;
    for(f=1;f<=Nfleet;f++)
    {
      if(f<=Nfleet1)
      {
        YPR_mask(f)=1.0;
        catchunits(f)=catchunits1(f);
        catch_se_rd(f)=catch_se_rd1(f);
        fleet_type(f)=1;
        if(catch_se_rd(f)<0) // bycatch only;  set values to default from SS_3.24
        {
          fleet_type(f)=2;
          bycatch_setup(f,1)=f;
          bycatch_setup(f,2)=1;  //  include dead bycatch in benchmark and forecast quantities
          bycatch_setup(f,3)=1;  //  scale F with Fmult like other fleets
        }
        need_catch_mult(f)=0;
      }
      else
      {
        catchunits(f)=2;
        catch_se_rd(f)=.1;
        fleet_type(f)=3;
        need_catch_mult(f)=0;
      }
      if(fleet_type(f)==1)
        {
          for (t=styr-nseas;t<=TimeMax;t++) {catch_se(t,f)=catch_se_rd(f);} // set catch se for fishing fleets
        }
        else
        {
          for (t=styr-nseas;t<=TimeMax;t++) {catch_se(t,f)=0.1;} // set a value for catch se for surveys and bycatch fleets (not used)
        }
      fleet_setup(f,1)=fleet_type(f);
      fleet_setup(f,2)=surveytime(f);
      fleet_setup(f,3)=fleet_area(f);
      fleet_setup(f,4)=catchunits(f);
      fleet_setup(f,5)=need_catch_mult(f);
    }
    N_retParm=0;
 END_CALCS

//  ProgLabel_2.1.5  define genders and max age
 LOCAL_CALCS
     *(ad_comm::global_datafile) >> gender;
     echoinput<<gender<<" N sexes "<<endl;
     *(ad_comm::global_datafile) >> nages;
     echoinput<<nages<<" nages is maxage "<<endl;
     nages2=gender*nages+gender-1;
 END_CALCS

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
  if (F_reporting==4)
  {
    F_reporting_ages=F_reporting_ages_R;
    if(F_reporting_ages(1)>(nages-2) || F_reporting_ages(1)<0)
    {N_warn++; warning<<" reset lower end of F_reporting_ages to be nages-2  "<<endl; F_reporting_ages(1)=nages-2;}
    if(F_reporting_ages(2)>(nages-2) || F_reporting_ages(2)<0)
    {N_warn++; warning<<" reset upper end of F_reporting_ages to be nages-2  "<<endl; F_reporting_ages(2)=nages-2;}
  }
  else
  {
    F_reporting_ages(1)=nages/2;
    F_reporting_ages(2)=F_reporting_ages(1)+1;
  }
 END_CALCS

  int ALK_time_max

 LOCAL_CALCS
  ALK_time_max=(endyr-styr+20)*nseas*N_subseas;  //  sets maximum size for data array indexing  20 years into forecast is allowed
 END_CALCS
!!//  SS_Label_Info_2.1.6  #Indexes for data timing.  "have_data" and "data_time" hold pointers for data occurrence, timing, and ALK need
  int data_type
  number data_timing
  4darray have_data(1,ALK_time_max,0,Nfleet,0,9,0,150);  //  this can be a i4array in ADMB 11
//    4iarray have_data(1,ALK_time_max,0,Nfleet,0,9,0,60);  //  this can be a i4array in ADMB 11
  imatrix have_data_yr(styr,endyr+20,0,Nfleet)

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
   obs_equ_catch.initialize();
    *(ad_comm::global_datafile) >> obs_equ_catch(1)(1,Nfleet1);  // only read season fpr 3.24
    echoinput<<obs_equ_catch<<" obs_equ_catch "<<endl;

   for(y=1;y<=ALK_time_max;y++)
   for(f=1;f<=Nfleet;f++)
   {
     data_time(y,f,1)=-1.0;  //  set to illegal value since 0.0 is valid
   }
 END_CALCS
!!//  SS_Label_Info_2.2 #Read CATCH amount by fleet

  int N_ReadCatch;
  int Catch_read;
  vector tempvec(1,6)  //  vector used for temporary reads
 LOCAL_CALCS
    *(ad_comm::global_datafile) >> N_ReadCatch;
    echoinput<<N_ReadCatch<<" N_ReadCatch read catch as table with fleets as columns"<<endl;
    j=Nfleet1+2;
 END_CALCS
  matrix catch_bioT(1,N_ReadCatch,1,j)
  matrix catch_ret_obs(1,Nfleet,styr-nseas,TimeMax+nseas)
  imatrix do_Fparm(1,Nfleet,styr-nseas,TimeMax+nseas)
  3darray catch_seas_area(styr,TimeMax,1,pop,0,Nfleet)
  matrix totcatch_byarea(styr,TimeMax,1,pop)
  vector totcat(styr-1,endyr)  //  by year, not by t
  int first_catch_yr

 LOCAL_CALCS
  catch_ret_obs.initialize();

  // insert initial equilibrium catch
  for (f=1; f<= Nfleet1; f++)
  {
    catch_ret_obs(f,styr-nseas) = obs_equ_catch(1,f);
  }

  tempvec.initialize();
  k=0;  // counter for reading catch records
  for (k=1;k<=N_ReadCatch;k++)
  {
      *(ad_comm::global_datafile) >> catch_bioT(k)(1,Nfleet1+2);
      y=catch_bioT(k,Nfleet1+1); s=catch_bioT(k,Nfleet1+2);
    echoinput<<catch_bioT(k)<<endl;

    if(y>=styr-1 && y<=endyr)  //  observation is in date range
    {
      if(s>nseas) s=nseas;   // allows for collapsing multiple season catch data down into fewer seasons
                               //  typically to collapse to annual because accumulation will all be in the index "nseas"
      if(s>0)
      {
        t=styr+(y-styr)*nseas+s-1;

        if(y>=styr)
        {
          for (f=1;f<=Nfleet1;f++) catch_ret_obs(f,t) += catch_bioT(k,f);
        }
      }
      else  // distribute catch equally across seasons
      {
        for (s=1;s<=nseas;s++)
        {
          t=styr+(y-styr)*nseas+s-1;
          for (f=1;f<=Nfleet1;f++) catch_ret_obs(f,t) += catch_bioT(k,f)/nseas;
        }
      }
    }
  }

  echoinput<<" processed catch "<<endl<<trans(catch_ret_obs)<<endl;

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
      if(fleet_area(f)==p && catch_ret_obs(f,t) > 0.0)
      {
        totcat(y) += catch_ret_obs(f,t);
        catch_seas_area(t,p,f)=1;
        catch_seas_area(t,p,0)=1;
        totcatch_byarea(t,p)+=catch_ret_obs(f,t);
      }
    }
    if(totcat(y)>0.0 && first_catch_yr==0) first_catch_yr=y;
    if(y==endyr && totcat(y)==0.0)
    {
      N_warn++; warning<<" catch is 0.0 in endyr; this will cause failure in the benchmark and forecast calculations"<<endl;
    }
  }
 END_CALCS

  //  SS_Label_Info_2.3 #Read fishery CPUE, effort, and Survey index or abundance
  init_int Svy_N_rd
  int Svy_N
 LOCAL_CALCS
  echoinput<<Svy_N_rd<<" nobs_survey "<<endl;
  if(Svy_N_rd>0) {k=3; j=Nfleet;} else {k=0; j=Nfleet;}
  data_type=1;  //  for surveys
 END_CALCS
  init_imatrix Svy_units_rd(1,Nfleet,1,k)
  ivector Svy_units(1,j)   //0=num/1=bio/2=F
  ivector Svy_errtype(1,j)  // -1=normal / 0=lognormal / >0=T
  ivector Svy_sdreport(1,j) // 0=no sdreport; 1=enable sdreport
  int Svy_N_sdreport

 LOCAL_CALCS

  // defaults for 3.24
  Svy_sdreport   = 0;
  Svy_N_sdreport = 0;

  if(k>0)
  {
    echoinput<<"Units:  0=numbers; 1=biomass; 2=F"<<endl;
    echoinput<<"Errtype:  -1=normal; 0=lognormal; >0=T"<<endl;
    echoinput<<"Fleet Units Err_Type"<<endl;
    echoinput<<Svy_units_rd<<endl;
    Svy_units=column(Svy_units_rd,2);
    Svy_errtype=column(Svy_units_rd,3);
  }
  else
    {
      Svy_units=0;
      Svy_errtype=0;
    }
 END_CALCS

   init_matrix Svy_data(1,Svy_N_rd,1,5)
  !!if(Svy_N_rd>0) echoinput<<" Svy_data "<<endl<<Svy_data<<endl;
  ivector Svy_N_fleet(1,Nfleet)
  int in_superperiod
  ivector Svy_super_N(1,Nfleet)      // N super_yrs per fleet

 LOCAL_CALCS
  //  count the number of observations, exclude those outside the specified year range, count the number of superperiods
  Svy_N=0;
  Svy_N_fleet=0;
  Svy_super_N=0;
  if(Svy_N_rd>0)
  {
    for (i=1;i<=Svy_N_rd;i++)
    {
      y=Svy_data(i,1);
      if(y>=styr && y<=retro_yr)
      {
        f=abs(Svy_data(i,3));  //  negative f turns off observation
        Svy_N_fleet(f)++;
        if(Svy_data(i,5)<0) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"cannot use negative se to indicate superperiods in survey data"<<endl; exit(1);}
        if(Svy_data(i,2)<0) Svy_super_N(f)++;  // count the super-periods if seas<0
      }
    }
    Svy_N=sum(Svy_N_fleet);
    for (f=1;f<=Nfleet;f++)
    if(Svy_super_N(f)>0)
    {
      j=Svy_super_N(f)/2;  // because we counted the begin and end
      if(2*j!=Svy_super_N(f))
      {
        N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"unequal number of starts and ends of survey superperiods "<<endl; exit(1);
      }
      else
      {
        Svy_super_N(f)=j;
      }
    }
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

 LOCAL_CALCS
//  SS_Label_Info_2.3.1  #Process survey observations, move info into working arrays,create super-periods as needed
    Svy_super_N.initialize();
    Svy_N_fleet.initialize();
    Svy_styr.initialize();
    Svy_endyr.initialize();
    Svy_yr.initialize();
    in_superperiod=0;
    if(Svy_N>0)  /* SS_Logic proceed if any survey data in yr range */
    {
      for (i=1;i<=Svy_N_rd;i++)  // loop all, including those out of yr range
      {
        y=Svy_data(i,1);
        f=abs(Svy_data(i,3));

        if(y>=styr && y<=retro_yr)
        {
          Svy_N_fleet(f)++;  //  count obs by fleet
          j=Svy_N_fleet(f);
          Svy_yr(f,j)=y;
          if(Svy_styr(f)==0 || (y>=styr && y<Svy_styr(f)) )  Svy_styr(f)=y;  //  for dimensioning survey q devs
          if(Svy_endyr(f)==0 || (y<=endyr && y>Svy_endyr(f)) )  Svy_endyr(f)=y;  //  for dimensioning survey q devs

          {  //  start have_data index and timing processing
            temp=abs(Svy_data(i,2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;

            Svy_time_t(f,j)=t;
            Svy_ALK_time(f,j)=ALK_time;  //  continuous subseas counter in which jth obs from fleet f occurs
            if(data_time(ALK_time,f,1)<0.0)  //  so first occurrence of data at ALK_time,f
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  year.fraction
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"SURVEY: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type in this subseas, for this fleet
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);  //  current number of observations
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas

          }  //  end have_data index and timing processing

          Svy_se_rd(f,j)=Svy_data(i,5);   // later adjust with varadjust, copy to se_cr_use, then adjust with extra se parameter
          if(Svy_data(i,3)<0) {Svy_use(f,j)=-1;} else {Svy_use(f,j)=1;}

          Svy_obs(f,j)=Svy_data(i,4);

          //  create super_year indexes
          if(Svy_data(i,2)<0) // start or stop a super-period;  ALL observations must be continguous in the file
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

      echoinput<<" processed survey data "<<endl;
      for (f=1;f<=Nfleet;f++)
      {echoinput<<f<<" "<<fleetname(f)<<" styr "<<Svy_styr(f)<<"  endyear "<<Svy_endyr(f)<<"  obs: "<<Svy_obs(f)<<endl;}
    }
    echoinput<<"Successful read of index data; N= "<<Svy_N<< endl;
    echoinput<<"Number of survey superperiods by fleet: "<<Svy_super_N<<endl;
 END_CALCS

   init_int Ndisc_fleets
   int nobs_disc

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
 LOCAL_CALCS
  disc_units.initialize();
  disc_errtype.initialize();
  if(Ndisc_fleets>0)
  {
    echoinput<<"#_discard_units (1=same_as_catchunits(bio/num);2=fraction; 3=numbers)"<<endl;
    echoinput<<"#_discard_error:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal"<<endl;
    echoinput<<"#Fleet Units Err_Type"<<endl;
    echoinput<<disc_units_rd<<endl;
    for (j=1;j<=Ndisc_fleets;j++)
    {
      f=disc_units_rd(j,1);
      disc_units(f)=disc_units_rd(j,2);
      disc_errtype(f)=disc_units_rd(j,3);
      disc_errtype_r(f)=float(disc_errtype(f));
    }
  }
 END_CALCS
   init_int disc_N_read
  !! echoinput<<disc_N_read<<" N discard obs "<<endl;

  init_matrix discdata(1,disc_N_read,1,5)
  !! if(disc_N_read>0) echoinput<<" discarddata "<<endl<<discdata<<endl;
   ivector disc_N_fleet(1,Nfleet)
   ivector N_suprper_disc(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
  nobs_disc=0;
  disc_N_fleet=0;
  N_suprper_disc=0;
  if(disc_N_read>0)
  {
    for (i=1;i<=disc_N_read;i++)  // get count of observations in date range
    {
      y=discdata(i,1);
      if(y>=styr && y<=retro_yr)
      {
        f=abs(discdata(i,3));
        disc_N_fleet(f)++;
        if(discdata(i,5)<0) {N_warn++; cout<<"EXIT - see warning"<<endl; warning<<"Cannot use negative se as indicator of superperiod in discard data"<<endl;}
        if(discdata(i,2)<0) N_suprper_disc(f)++;  // count the super-periods if seas<0 or se<0
      }
    }
    nobs_disc=sum(disc_N_fleet);  // sum of obs in the date range
    for (f=1;f<=Nfleet;f++)
    if(N_suprper_disc(f)>0)
    {
      j=N_suprper_disc(f)/2;  // because we counted the begin and end
      if(2*j!=N_suprper_disc(f))
      {
        N_warn++; cout<<"EXIT - see warning"<<endl; warning<<"unequal number of starts and ends of discard superperiods "<<endl; exit(1);
      }
      else
      {
        N_suprper_disc(f)=j;
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
      for (i=1;i<=disc_N_read;i++)
      {
        y=discdata(i,1);
        if(y>=styr && y<=endyr)
        {
         f=abs(discdata(i,3));
         disc_N_fleet(f)++;
         j=disc_N_fleet(f);  //  index number for data that are in date range

          {  //  start have_data index and timing processing
          temp=abs(discdata(i,2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;

          disc_time_t(f,j)=t;

          if(surveytime(f)==-1.)  //  so ignoring month info
          {
              subseas=mid_subseas;
              data_timing=0.5;
          }
          ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
          disc_time_ALK(f,j)=ALK_time;  //  subseas that this observation is in
            if(data_time(ALK_time,f,1)<0.0)
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  year.fraction
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"DISCARD: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
          }  //  end have_data index and timing processing

         cv_disc(f,j)=discdata(i,5);
         obs_disc(f,j)=fabs(discdata(i,4));

         if(discdata(i,4)<0.0) discdata(i,3)=-abs(discdata(i,3));  //  convert to new format using negative fleet
         if(discdata(i,3)<0) {yr_disc_use(f,j)=-1;} else {yr_disc_use(f,j)=1;}
         if(catch_ret_obs(f,t)<=0.0)
         {
           N_warn++; warning<<" discard observation: "<<i<<" has no corresponding catch "<<discdata(i)<<endl;
         }

  //  create super_year indexes
         if(discdata(i,2)<0)  // start/stop a super-year  ALL observations must be continguous in the file
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
    echoinput<<"Successful read of discard data, N by fleet = "<< nobs_disc << endl;
    echoinput<<"N superperiods by fleet = "<< N_suprper_disc << endl;
 END_CALCS


!!//  SS_Label_Info_2.5 #Read Mean Body Weight data
//  note that syntax for storing this info internal is done differently than for surveys and discard
   init_int nobs_mnwt_rd
   int nobs_mnwt
   int do_meanbodywt
  number DF_bodywt  // DF For meanbodywt T-distribution
  !!echoinput<<nobs_mnwt_rd<<" nobs_mean body wt.  If 0, then no additional input in 3.30 "<<endl;

   matrix mnwtdata1(1,nobs_mnwt_rd,1,6)
 LOCAL_CALCS
    *(ad_comm::global_datafile) >> DF_bodywt;
    echoinput<<DF_bodywt<<" degrees of freedom for bodywt T-distribution "<<endl;
  do_meanbodywt=0;
  if(nobs_mnwt_rd>0)
  {
    *(ad_comm::global_datafile) >> mnwtdata1;
    echoinput<<" meanbodywt_data "<<endl<<mnwtdata1<<endl;
    do_meanbodywt=1;
  }

  data_type=3;
  nobs_mnwt=0;
  for (i=1;i<=nobs_mnwt_rd;i++)
  {
    y=mnwtdata1(i,1);
    if(y>=styr && y<=retro_yr) nobs_mnwt++;
  }
 END_CALCS
  matrix mnwtdata(1,9,1,nobs_mnwt)
//  9 items are:  yr, seas, type, mkt, obs, se, then three intermediate variance quantities
  3darray yr_mnwt2(1,Nfleet,styr,TimeMax,0,2)  // last dimension here is for total, discard, retain

 LOCAL_CALCS
  yr_mnwt2.initialize();
  mnwtdata.initialize();
  j=0;
  if(nobs_mnwt>0)  //  number in date range
  for (i=1;i<=nobs_mnwt_rd;i++)  //   loop all obs
  {
    y=mnwtdata1(i,1);
    if(y>=styr && y<=retro_yr)
    {
      j++;
      f=abs(mnwtdata1(i,3));

      {  //  start have_data index and timing processing
        if(mnwtdata1(i,2)<0.0) {N_warn++; warning<<"negative season not allowed for mnwtdata because superperiods not implemented "<<endl;}
      temp=abs(mnwtdata1(i,2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;

            if(data_time(ALK_time,f,1)<0.0)
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  fraction of year
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"MEAN_WEIGHT: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
      have_data(ALK_time,0,0,0)=1;
      have_data(ALK_time,f,0,0)=1;  //  so have data of some type
      have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
      p=have_data(ALK_time,f,data_type,0);
      have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
      }  //  end have_data index and timing processing

      if(s<1) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for meanwt obs "<<i<<" is <0; superper is not implemented for meanwt"<<endl; exit(1);}
      if(s>nseas) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for meanwt obs "<<i<<" is > nseas"<<endl; exit(1);}
      z=mnwtdata1(i,4);  // z is partition (0, 1, 2)
      yr_mnwt2(f,t,z)=j;  //  seems redundant with have_data, but this stores the partition info, so allows both disard and retained obs in same f,t

      mnwtdata(1,j)=t;
      mnwtdata(2,j)=real_month;
      for (k=3;k<=6;k++) mnwtdata(k,j)=mnwtdata1(i,k);
    }
  }
  echoinput<<"Successful read of mean-bodywt data, N= "<< nobs_mnwt <<endl;
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
  !!echoinput<<LenBin_option<<" LenBin_option "<<endl;
 LOCAL_CALCS
   if(LenBin_option==1)
   {k=0;}
   else if(LenBin_option==2)
   {k=3;}
   else if(LenBin_option==3)
   {k=1;}
   else
   {N_warn++; warning<<" LenBin_option must be 1, 2 or 3"<<LenBin_option<<endl;}
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
  !!if(nlength>0) echoinput<<len_bins_rd<<" pop length bins as read "<<endl;

!!//  SS_Label_Info_2.7 #Start length data section
  int use_length_data
!! use_length_data=1;  //  for compatibility with version 3.30
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
  vector min_sample_size_L(1,Nfleet) // minimum sample size
  int Comp_Err_ParmCount;  // counts number of fleets that need a parameter for the error estimation
 LOCAL_CALCS
  Comp_Err_ParmCount=0;
  Comp_Err_L2.initialize();
    *(ad_comm::global_datafile) >> min_tail;
    echoinput<<min_tail<<" min tail for comps "<<endl;
    *(ad_comm::global_datafile) >> min_comp;
    echoinput<<min_comp<<" value added to comps "<<endl;
    *(ad_comm::global_datafile) >> CombGender_l;
    echoinput<<CombGender_l<<" CombGender_lengths "<<endl;
    for (f=1;f<=Nfleet;f++)
    {
      min_tail_L(f) = min_tail;
      min_comp_L(f) = min_comp;
      CombGender_L(f) = CombGender_l;
      AccumBin_L(f) = 0;
      Comp_Err_L(f)=0;  //  for multinomial
      Comp_Err_L2(f)=0;  // no parameter needed
      min_sample_size_L(f) = 1.0;
    }
  *(ad_comm::global_datafile) >> nlen_bin;
  echoinput<<nlen_bin<<" nlen_bin_for_data "<<endl;
 END_CALCS
  vector len_bins_dat(1,nlen_bin) // length bin lower boundaries
 LOCAL_CALCS
  *(ad_comm::global_datafile) >> len_bins_dat;
  echoinput<<" len_bins_dat "<<endl<<len_bins_dat<<endl;

  for (f=1;f<=Nfleet;f++)
  {
  if(CombGender_L(f)>nlen_bin)
  {
    N_warn++; warning<<"Combgender_L(f) cannot be greater than nlen_bin; resetting for fleet: "<<f<<endl;  CombGender_L(f)=nlen_bin;
  }
  }
  nlen_binP=nlen_bin+1;
  nlen_bin2=gender*nlen_bin;
 END_CALCS

  vector len_bins_dat2(1,nlen_bin2)  //; doubled for males; for output only
  vector len_bins_dat_m(1,nlen_bin)  //; midbin; for output only
  vector len_bins_dat_m2(1,nlen_bin2)  //; doubled for males; for output only

 LOCAL_CALCS
  //  SS_Label_Info_2.7.2 #Process length bins, create mean length per bin, etc.
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
  echoinput<<endl<<"Processed Population length bin info "<<endl;

  maxL=len_bins_m(nlength);
  minL=len_bins(1);
  minL_m=len_bins_m(1);
  if(LenBin_option!=2) binwidth2=binwidth(nlength/2);  // set a reasonable value in case LenBin_option !=2
  if(len_bins_dat(nlen_bin)>len_bins(nlength))
  {
    N_warn++; cout<<"Critical error, see warning.sso"<<endl; warning<<" Data length bins extend beyond pop len bins "<<len_bins_dat(nlen_bin)<<" "<<len_bins(nlength)<<endl; exit(1);
  }

  startbin=1;
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
  echoinput<<endl<<"Processed Data length bin info "<<endl;
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
    echoinput<<"make_len_bin "<<len_bins<<endl;
    for (ibin=1;ibin<=nlen_bin;ibin++) echoinput<<len_bins_dat(ibin)<<make_len_bin(ibin)(1,nlength)<<endl;
   }
  echoinput<<endl<<"Processed Population to Data length bin conversion "<<endl;
 END_CALCS


!!//  SS_Label_Info_2.7.4 #Read Length composition data
   int nobsl_rd
   int Nobs_l_tot

 LOCAL_CALCS
    *(ad_comm::global_datafile) >> nobsl_rd;
   echoinput<<nobsl_rd<<" N length comp obs "<<endl;
 END_CALCS

  ivector Nobs_l(1,Nfleet)
  ivector N_suprper_l(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
    for(i=0;i<=nobsl_rd-1;i++)
     {
       dvector tempvec_lenread(1,6+nlen_bin2);
        *(ad_comm::global_datafile) >> tempvec_lenread(1,6+nlen_bin2);
      lendata.push_back (tempvec_lenread(1,6+nlen_bin2));
    }
    if(nobsl_rd>0) echoinput<<" first lencomp obs "<<endl<<lendata[0]<<endl<<" last obs"<<endl<<lendata[nobsl_rd-1]<<endl;;

    data_type=4;
    Nobs_l=0;                       //  number of observations from each fleet/survey
    N_suprper_l=0;
    if(nobsl_rd>0)
    for(i=0;i<=nobsl_rd-1;i++)
    {
      y=lendata[i](1);
      if(y>=styr && y<=retro_yr)
      {
      f=abs(lendata[i](3));
      if(lendata[i](6)<0) {N_warn++; cout<<"error in length data "<<endl; warning<<"Error: negative sample size no longer valid as indicator of skip data or superperiods "<<endl; exit(1);}
      if(lendata[i](2)<0) N_suprper_l(f)++;     // count the number of starts and ends of super-periods if seas<0
      Nobs_l(f)++;
      }
    }
    Nobs_l_tot=sum(Nobs_l);
  for (f=1;f<=Nfleet;f++)
  {
    s=N_suprper_l(f)/2.;
    if(s*2!=N_suprper_l(f))
    {N_warn++; cout<<"error in length data "<<endl; warning<<"Error: unequal number of length superperiod starts and stops "<<endl; exit(1);}
    else
    {N_suprper_l(f)=s;}// to get the number of superperiods
  }

    echoinput<<"Lendata Nobs by fleet "<<Nobs_l<<endl;
    echoinput<<"Lendata superperiods by fleet "<<N_suprper_l<<endl;
 END_CALCS

  imatrix Len_time_t(1,Nfleet,1,Nobs_l)
  imatrix Len_time_ALK(1,Nfleet,1,Nobs_l)
  3darray obs_l(1,Nfleet,1,Nobs_l,1,nlen_bin2)
  3darray obs_l_all(1,4,1,Nfleet,1,nlen_bin)  //  for the sum of all length comp data
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
    for(i=0;i<=nobsl_rd-1;i++)   //  loop all observations to find those for this fleet/time
    {
      y=lendata[i](1);
      if(y>=styr && y<=retro_yr)
      {
        f=abs(lendata[i](3));
        if(f==floop)
        {
          Nobs_l(f)++;
          j=Nobs_l(f);

          {  //  start have_data index and timing processing
          temp=abs(lendata[i](2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
            lendata[i](2)=lendata[i](2)/abs(lendata[i](2))*real_month;
            Len_time_t(f,j)=t;     // sequential time = year+season
            Len_time_ALK(f,j)=ALK_time;
            if(data_time(ALK_time,f,1)<0.0)
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  fraction of year
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"LENGTH: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
          }  //  end have_data index and timing processing

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for length obs "<<i<<" is > nseas"<<endl; exit(1);}

          if(lendata[i](6)<0.0)
            {N_warn++; warning<<"negative values not allowed for lengthcomp sample size, use -fleet to omit from -logL"<<endl;}
          header_l(f,j,1) = y;
          if(lendata[i](2)<0)
          {
            header_l(f,j,2) = -real_month;  // month with sign to indicate super period
          }
          else
          {
            header_l(f,j,2) = real_month;  // month
          }

          header_l_rd(f,j)(1,3) =  lendata[i](1,3);   // values as in input file
          header_l(f,j,3) = lendata[i](3);   // fleet with sign
          //  note that following storage is redundant with Show_Time(t,3) calculated later
          header_l(f,j,0) = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));  //
          gen_l(f,j)=lendata[i](4);         // gender 0=combined, 1=female, 2=male, 3=both
          mkt_l(f,j)=lendata[i](5);         // partition: 0=all, 1=discard, 2=retained
          nsamp_l_read(f,j)=lendata[i](6);  // assigned sample size for observation
          nsamp_l(f,j)=nsamp_l_read(f,j);

  //  SS_Label_Info_2.7.6 #Create super-periods for length compositions
          if(lendata[i](2)<0)  // start/stop a super-period  ALL observations must be continguous in the file
          {
            if(in_superperiod==0)  // start a super-period  ALL observations must be continguous in the file
            {N_suprper_l(f)++; suprper_l1(f,N_suprper_l(f))=j; in_superperiod=1;}
            else if(in_superperiod==1)  // end a super-year
            {suprper_l2(f,N_suprper_l(f))=j; in_superperiod=0;}
          }

          for (z=1;z<=nlen_bin2;z++)   // get the composition vector
           {obs_l(f,j,z)=lendata[i](6+z);}

          if(sum(obs_l(f,j))<=0.0) {N_warn++; warning<<" zero fish in size comp (fleet, year) "<<f<<" "<<y<<endl; cout<<" EXIT - see warning "<<endl; exit(1);}
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
          else  //  set upper tail same as female tail to ease code in write section
          {tails_l(f,j,3)=tails_l(f,j,1); tails_l(f,j,4)=tails_l(f,j,2);}

          obs_l(f,j) /= sum(obs_l(f,j));                  // make sum to 1.00 again after adding min_comp
          if(gender==1 || gen_l(f,j)!=2) {obs_l_all(1,f)(1,nlen_bin)+=obs_l(f,j)(1,nlen_bin);}  //  females or combined
          if(gender==2)
          {
            if(gen_l(f,j)==1 || gen_l(f,j)==3)  // put females into female only
            {
              obs_l_all(3,f)(1,nlen_bin)+=obs_l(f,j)(1,nlen_bin);
            }
            if(gen_l(f,j)>=2)  //  put males into combined and into male only
            {
              for(z=1;z<=nlen_bin;z++)
              {
                obs_l_all(1,f,z)+=obs_l(f,j,nlen_bin+z);
                obs_l_all(4,f,z)+=obs_l(f,j,nlen_bin+z);
              }
            }
          }
        }
      }
    }
  }

     echoinput<<"Overall_Compositions"<<endl<<"Fleet len_bins "<<len_bins_dat<<endl;
     for (f=1;f<=Nfleet;f++)
     {
       for(j=1;j<=4;j++)
       {
          if(j!=2)
          {
            temp=sum(obs_l_all(j,f));
            if(temp>0.0)
            {
               obs_l_all(j,f)/=temp;
            }
            else
            {
              obs_l_all(j,f)=float(1./nlen_bin);
            }
          }
       }
       obs_l_all(2,f,1)=obs_l_all(1,f,1); // first bin
       for (z=2;z<=nlen_bin;z++)
       {
         obs_l_all(2,f,z)=obs_l_all(2,f,z-1)+obs_l_all(1,f,z);
       }
       if(Nobs_l(f)>0)
       {
         echoinput<<f<<" freq"<<obs_l_all(1,f)<<endl;
         echoinput<<f<<" cuml"<<obs_l_all(2,f)<<endl;
         echoinput<<f<<" female"<<obs_l_all(3,f)<<endl;
         echoinput<<f<<" male"<<obs_l_all(4,f)<<endl;
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
  int AgeKey_StartAge;
  int AgeKey_Linear1;
  int AgeKey_Linear2;

 LOCAL_CALCS
   *(ad_comm::global_datafile) >> n_abins;
  echoinput<<n_abins<<" N age bins "<<endl;
  n_abins1=n_abins+1;
  n_abins2=gender*n_abins;
 END_CALCS

  init_vector age_bins1(1,n_abins) // age classes for data
  !!echoinput << age_bins1<< " agebins "  << endl;

  init_int N_ageerr   // number of ageing error matrices to be calculated
   !!echoinput<<N_ageerr<<" N age error defs "<<endl;
  init_3darray age_err_rd(1,N_ageerr,1,2,0,nages) // ageing imprecision as stddev for each age
 LOCAL_CALCS
  echoinput<<"ageerror_definitions_as_read"<<endl<<age_err_rd<<endl;
  Use_AgeKeyZero=0;
  if(N_ageerr>0)
  {
    for (i=1;i<=N_ageerr;i++)
    {
      if(age_err_rd(i,2,0)<0.) Use_AgeKeyZero=i;  //  set flag for setup of age error parameters
    }
    echoinput<<"set agekey: "<<Use_AgeKeyZero<<" to create key from parameters"<<endl;
  }
 END_CALCS
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

 LOCAL_CALCS
  Comp_Err_A2.initialize();
    *(ad_comm::global_datafile) >> nobsa_rd;
    echoinput << nobsa_rd<< " N ageobs"  << endl;
    *(ad_comm::global_datafile) >> Lbin_method;
    echoinput << Lbin_method<< " Lbin method for defined size ranges "  << endl;
    *(ad_comm::global_datafile) >> CombGender_a;
    echoinput<<CombGender_a<<" CombGender_a "<<endl;
    for (f=1;f<=Nfleet;f++)
    {
      min_tail_A(f) = min_tail;
      min_comp_A(f) = min_comp;
      CombGender_A(f) = CombGender_a;
      AccumBin_A(f) = 0;
      Comp_Err_A(f)=0;  //  for multinomial
      Comp_Err_A2(f)=0;  //  no parameter needed
      min_sample_size_A(f) = 1.0;
    }

  if(nobsa_rd>0 && N_ageerr==0)
  {
    N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" must define ageerror vectors because age data exist"<<endl; exit(1);
  }
  for (f=1;f<=Nfleet;f++)
  {
    if(CombGender_A(f)>n_abins2)
  {
    N_warn++; warning<<"Combgender_A(f) cannot be greater than n_abins for fleet:_"<<f<<"; resetting"<<endl;  CombGender_A(f)=n_abins2;
  }
  }
 END_CALCS
!!//  SS_Label_Info_2.8.2 #Read Age data

//  init_matrix Age_Data(1,nobsa_rd,1,9+n_abins2)
  ivector Nobs_a(1,Nfleet)
  ivector N_suprper_a(1,Nfleet)      // N super_yrs per obs

  vector age_bins(1,n_abins2) // age classes for data  female then male end-to-end
  vector age_bins_mean(1,n_abins2)  //  holds mean age for each data age bin

 LOCAL_CALCS
  data_type=5;  //  for age data
  for (b=1;b<=n_abins;b++)
  {
   age_bins(b) = age_bins1(b);
   if(gender==2) age_bins(b+n_abins)=age_bins1(b);
  }

  for (b=1;b<=n_abins;b++)
  {
   age_bins(b) = age_bins1(b);
   if(b<n_abins)
    {
      age_bins_mean(b) =(age_bins1(b)+age_bins1(b+1))*0.5;
    }
    else
    {
      age_bins_mean(b) =age_bins1(b)+0.5*(age_bins1(b)-age_bins1(b-1));
    }
    if(gender==2)
      {
        age_bins(b+n_abins)=age_bins1(b);
        age_bins_mean(b+n_abins)=age_bins_mean(b);
      }
  }

    for(i=0;i<=nobsa_rd-1;i++)
     {
       dvector tempvec_ageread(1,9+n_abins2);
        *(ad_comm::global_datafile) >> tempvec_ageread(1,9+n_abins2);
      Age_Data.push_back (tempvec_ageread(1,9+n_abins2));
    }
    if(nobsa_rd>0) echoinput<<" first agecomp obs "<<endl<<Age_Data[0]<<endl<<" last obs"<<endl<<Age_Data[nobsa_rd-1]<<endl;;

  Nobs_a=0;
  N_suprper_a=0;

    for(i=0;i<=nobsa_rd-1;i++)
  {
    y=Age_Data[i](1);
    if(y>=styr && y<=retro_yr)
    {
     f=abs(Age_Data[i](3));
     if(Age_Data[i](9)<0) {N_warn++; cout<<"error in age data "<<endl; warning<<"Error: negative sample size no longer valid as indicator of skip data or superperiods "<<endl; exit(1);}
     if(Age_Data[i](6)==0 || Age_Data[i](6)>N_ageerr) {N_warn++; cout<<"error in age data "<<endl; warning<<"Error: undefined age_error type: "<<Age_Data[i](6)<<"  in obs: "<<i<<endl; exit(1);}
     if(Age_Data[i](2)<0) N_suprper_a(f)++;     // count the number of starts and ends of super-periods if seas<0 or sampsize<0

     Nobs_a(f)++;
    }
  }
  for (f=1;f<=Nfleet;f++)
  {
    s=N_suprper_a(f)/2.;
    if(s*2!=N_suprper_a(f))
    {N_warn++; cout<<"error in age data "<<endl; warning<<"Error: unequal number of age superperiod starts and stops "<<endl; exit(1);}
    else
    {N_suprper_a(f)/=2;}
  }
  echoinput<<endl<<"Age_Data Nobs by fleet "<<Nobs_a<<endl;
  echoinput<<"Age_Data superperiods by fleet "<<N_suprper_a<<endl;
  Nobs_a_tot=sum(Nobs_a);

  for (f=1;f<=Nfleet;f++)
      {if(Nobs_a(f)==0) Nobs_a(f)=1;}  //  why is this needed?
 END_CALCS

  matrix offset_a(1,Nfleet,1,Nobs_a) // Compute OFFSET for multinomial (i.e, value for the multinonial function
  imatrix Age_time_t(1,Nfleet,1,Nobs_a)
  imatrix Age_time_ALK(1,Nfleet,1,Nobs_a)
  3darray obs_a(1,Nfleet,1,Nobs_a,1,gender*n_abins)
  3darray obs_a_all(1,2,1,Nfleet,1,n_abins)  //  for the sum of all age comp data
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
  3darray header_a(1,Nfleet,1,Nobs_a,0,9)
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
    for(i=0;i<=nobsa_rd-1;i++)
     {
       y=Age_Data[i](1);
       if(y>=styr && y<=retro_yr)
       {
         f=abs(Age_Data[i](3));
         if(f==floop)
         {
           Nobs_a(f)++;  //  redoing this pointer just to create index j used below
           j=Nobs_a(f);

          {  //  start have_data index and timing processing
          temp=abs(Age_Data[i](2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
            Age_Data[i](2)=Age_Data[i](2)/abs(Age_Data[i](2))*real_month;

          Age_time_t(f,j)=t;                     // sequential time = year+season
          Age_time_ALK(f,j)=ALK_time;
            if(data_time(ALK_time,f,1)<0.0)
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  fraction of year
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"AGE: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
//            warning<<" datatype: "<<data_type<<" p: "<<p;
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
          }  //  end have_data index and timing processing

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for age obs "<<i<<" is > nseas"<<endl; exit(1);}

          if(Age_Data[i](6)<0.0)
            {N_warn++; warning<<"negative values not allowed for age comp sample size, use -fleet to omit from -logL"<<endl;}
          header_a(f,j)(1,9)=Age_Data[i](1,9);
          header_a_rd(f,j)(2,3)=Age_Data[i](2,3);
          header_a(f,j,1) = y;
          if(Age_Data[i](2)<0)
          {
            header_a(f,j,2) = -real_month;  //  month with sign for super periods
          }
          else
          {
            header_a(f,j,2) = real_month;  // month
          }
          header_a(f,j,3) = Age_Data[i](3);   // fleet
          //  note that following storage is redundant with Show_Time(t,3) calculated later
          header_a(f,j,0) = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));  //
          gen_a(f,j)=Age_Data[i](4);         // gender 0=combined, 1=female, 2=male, 3=both
          mkt_a(f,j)=Age_Data[i](5);         // partition: 0=all, 1=discard, 2=retained
          nsamp_a_read(f,j)=Age_Data[i](9);  // assigned sample size for observation
          nsamp_a(f,j)=nsamp_a_read(f,j);

           if(Age_Data[i](6)>N_ageerr)
           {
              N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" ageerror type must be <= "<<N_ageerr<<endl; exit(1);
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
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" zero fish in age comp "<<header_a(f,j)<<endl;  exit(1);}

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
               if(s==0) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" L_bin_lo no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_lo(f,j)=s;

               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==len_bins_dat(Lbin_hi(f,j)) ) s=k;   //  find poplen bin that matches data len bin
               }
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl; warning<<" L_bin_hi no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
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
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl; warning<<"L_bin_lo no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_lo(f,j)=s;

               s=0;
               for (k=1;k<=nlength;k++)
               {
                 if( len_bins(k)==Lbin_hi(f,j) ) s=k;
               }
               if(s==0) {N_warn++; cout<<" exit - see warning "<<endl; warning<<"L_bin_hi no match to poplenbins in age comp "<<header_a(f,j)<<endl;  exit(1);}
               Lbin_hi(f,j)=s;
               break;
             }
           }

           //  lbin_lo and lbin_hi are now in terms of poplenbins; their original values are retained in header_a
           if(Lbin_lo(f,j)>nlength || Lbin_lo(f,j)>Lbin_hi(f,j))
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" L_bin_lo is too high in age comp.  Are you using lengths or bin numbers? "<<header_a(f,j)<<endl;  exit(1);}
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
           else  //  set upper tail same as female tail to ease code in write section
           {tails_a(f,j,3)=tails_a(f,j,1); tails_a(f,j,4)=tails_a(f,j,2);}

           if(sum(obs_a(f,j))>0.) obs_a(f,j) /= sum(obs_a(f,j));                  // make sum to 1.00 again after adding min_comp
           if(gender==1 || gen_a(f,j)!=2) obs_a_all(1,f)(1,n_abins)+=obs_a(f,j)(1,n_abins);  //  females or combined
           if(gender==2 && gen_a(f,j)>=2)
           {
             for (a=1;a<=n_abins;a++)
             {
               obs_a_all(1,f,a)+=obs_a(f,j,n_abins+a);  //  males
             }
           }
//           warning<<obs_a(f,j)(1,6)<<endl;
         }
       }
     }

     echoinput<<"Fleet age_bins "<<age_bins<<endl;
     for (f=1;f<=Nfleet;f++)
     {
       if(Nobs_a(f)>0)
       {
         obs_a_all(1,f)/=sum(obs_a_all(1,f));
       }
       else
       {
         obs_a_all(1,f)=float(1./n_abins);
       }
       obs_a_all(2,f,1)=obs_a_all(1,f,1); // first bin
       for (a=2;a<=n_abins;a++)
       {
         obs_a_all(2,f,a)=obs_a_all(2,f,a-1)+obs_a_all(1,f,a);
       }
       echoinput<<f<<" freq "<<obs_a_all(1,f)<<endl;
       echoinput<<f<<" cuml "<<obs_a_all(2,f)<<endl;
     }
   }
   echoinput<<endl<<"Successful processing of age data "<<endl;
 END_CALCS

!!//  SS_Label_Info_2.9 #Read mean Size_at_Age data
  init_int nobs_ms_rd
  int nobs_ms_tot
  int use_meansizedata
  !!echoinput<<nobs_ms_rd<<" N mean size-at-age obs "<<endl;
  init_matrix sizeAge_Data(1,nobs_ms_rd,1,7+2*n_abins2)
   !!if(nobs_ms_rd>0) echoinput<<" first size-at-age obs "<<endl<<sizeAge_Data(1)<<endl<<" last obs"<<endl<<sizeAge_Data(nobs_ms_rd)<<endl;;
  ivector Nobs_ms(1,Nfleet)
  ivector N_suprper_ms(1,Nfleet)      // N super_yrs per obs

 LOCAL_CALCS
  use_meansizedata=0;
  data_type=7;  //  for size (length or weight)-at-age data
  Nobs_ms=0;
  N_suprper_ms=0;
  if(nobs_ms_rd>0)
  {
  use_meansizedata=1;
  for (i=1;i<=nobs_ms_rd;i++)
  {
    y=sizeAge_Data[i](1);
    if(y>=styr && y<=retro_yr)
    {
      f=abs(sizeAge_Data[i](3));
      if(sizeAge_Data[i](7)<0) {N_warn++; cout<<"error in meansize"<<endl; warning<<"error.  cannot use negative sampsize for meansize data ";exit(1);;}
      if(sizeAge_Data[i](2)<0) N_suprper_ms(f)++;     // count the number of starts and ends of super-periods if seas<0 or sampsize<0
      Nobs_ms(f)++;
    }
  }
  }
  for (f=1;f<=Nfleet;f++)
  {
    s=N_suprper_ms(f)/2.;
    if(s*2!=N_suprper_ms(f))
    {N_warn++; cout<<"error in meansize data "<<endl; warning<<"Error: unequal number of meansize superperiod starts and stops "<<endl; exit(1);}
    else
    {N_suprper_ms(f)/=2;}
  }
  echoinput<<endl<<"meansize data Nobs by fleet "<<Nobs_ms<<endl;
  echoinput<<"meansize superperiods by fleet "<<N_suprper_ms<<endl;

  nobs_ms_tot=sum(Nobs_ms);
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

 LOCAL_CALCS
   Nobs_ms=0;
   suprper_ms1.initialize();
   suprper_ms2.initialize();
   N_suprper_ms.initialize();
   if(nobs_ms_tot>0)
   {
     in_superperiod=0;
     for (floop=1;floop<=Nfleet;floop++)
     for (i=1;i<=nobs_ms_rd;i++)
     {
       y=sizeAge_Data[i](1);
       if(y>=styr && y<=retro_yr)
       {
         f=abs(sizeAge_Data[i](3));
         if(f==floop)
         {
           Nobs_ms(f)++;
           j=Nobs_ms(f);  //  observation counter

          {  //  start have_data index and timing processing
          temp=abs(sizeAge_Data[i](2));  //  read value that could be season or month; abs ()because neg value indicates super period
            if(read_seas_mo==1)  // reading season
            {
              s=int(temp);
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
            }
            else  //  reading month.fraction
            {
              real_month=temp;
              temp1=(temp-1.0)/12.;  //  month as fraction of year
              s=1;  // earlist possible seas;
              subseas=1;  //  earliest possible subseas in seas
              temp=subseasdur_delta(s);  //  starting value
              while(temp<=temp1+1.0e-9)
              {
                if(subseas==N_subseas)
                {s++; subseas=1;}
                else
                {subseas++;}
                temp+=subseasdur_delta(s);
              }
              data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
              if(surveytime(f)==-1.)  //  so ignoring month info
              {
                subseas=mid_subseas;
                data_timing=0.5;
              }
            }

            t=styr+(y-styr)*nseas+s-1;
            ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
            sizeAge_Data[i](2)=sizeAge_Data[i](2)/abs(sizeAge_Data[i](2))*real_month;

           msz_time_t(f,j)=t;

            msz_time_ALK(f,j)=ALK_time;
            if(data_time(ALK_time,f,1)<0.0)
            {
              data_time(ALK_time,f,1)=real_month;
              data_time(ALK_time,f,2)=data_timing;  //  fraction of season
              data_time(ALK_time,f,3)=float(y)+(real_month-1.)/12.;  //  fraction of year
            }
            else if (real_month!=  data_time(ALK_time,f,1))
            {
              N_warn++;
              warning<<"MEAN LEN-AT-AGE: data_month already set for y,s,f: "<<y<<" "<<s<<" "<<f<<" to real month: "<< data_time(ALK_time,f,1)<<"  but read value is: "<<real_month<<endl;
            }
            have_data(ALK_time,0,0,0)=1;
            have_data(ALK_time,f,0,0)=1;  //  so have data of some type
            have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
            p=have_data(ALK_time,f,data_type,0);
            have_data(ALK_time,f,data_type,p)=j;  //  store data index for the p'th observation in this subseas
          }  //  end have_data index and timing processing

          if(s>nseas)
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for size-age obs "<<i<<" is > nseas"<<endl; exit(1);}

          if(sizeAge_Data[i](6)<0.0)
            {N_warn++; warning<<"negative values not allowed for size-at-age sample size, use -fleet to omit from -logL"<<endl;}

           header_ms(f,j)(1,7)=sizeAge_Data(i)(1,7);
          header_ms_rd(f,j)(2,3)=sizeAge_Data[i](2,3);
          header_ms(f,j,1) = y;
          if(sizeAge_Data[i](2)<0)
          {
            header_ms(f,j,2) = -real_month;  //month
          }
          else
          {
            header_ms(f,j,2) = real_month;  //month
          }
          header_ms(f,j,3) = sizeAge_Data[i](3);   // fleet
          if(sizeAge_Data[i](3)<0) header_ms(f,j,3)=-f;
          //  note that following storage is redundant with Show_Time(t,3) calculated later
          header_ms(f,j,0) = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));  //

           gen_ms(f,j)=sizeAge_Data[i](4);
           mkt_ms(f,j)=sizeAge_Data[i](5);
           if(sizeAge_Data[i](6)>N_ageerr)
           {
              N_warn++;cout<<" EXIT - see warning "<<endl;
              warning<<" in meansize, ageerror type must be <= "<<N_ageerr<<endl; exit(1);
           }
           ageerr_type_ms(f,j)=sizeAge_Data[i](6);

  //  SS_Label_Info_2.9.1 #Create super-periods for meansize data
           if(sizeAge_Data[i](2)<0)  // start/stop a super-period  ALL observations must be continguous in the file
           {
             if(in_superperiod==0)  //  start superperiod
             {N_suprper_ms(f)++; suprper_ms1(f,N_suprper_ms(f))=j; in_superperiod=1;}
             else
             if(in_superperiod==1)  // end a super-period
             {suprper_ms2(f,N_suprper_ms(f))=j; in_superperiod=0;}
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
   }

   echoinput<<"Successful read of size-at-age data; N = "<<Nobs_ms<<endl;
 END_CALCS


!!//  SS_Label_Info_2.10 #Read environmental data that will be used to modify processes and expected values
    init_int N_envvar
  !!echoinput<<N_envvar<<" N_envvar "<<endl;
    init_int N_envdata
  !!echoinput<<N_envdata<<" N_envdata "<<endl;

    matrix env_data_RD(styr-1,endyr+100,1,N_envvar)  //  leave enough room for N_Fcast_Yrs which is not yet known
    init_matrix env_temp(1,N_envdata,1,3)
 LOCAL_CALCS
     if(N_envdata>0)
     {
      if(N_envdata>0)echoinput<<" env data "<<endl<<env_temp<<endl;
      env_data_RD=0.;
      for (i=1;i<=N_envdata;i++)
        if(env_temp(i,1)>=(styr-1))
        {env_data_RD(env_temp(i,1), env_temp(i,2) ) = env_temp(i,3);}
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
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_units<<" Sizetfreq units(bio/num) per method"<<endl;
  init_ivector SzFreq_scale(1,SzFreq_Nmeth);               //  bin scale (1=kg; 2=lbs; 3=cm; 4=in) for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_scale<<" Sizefreq scale(kg/lbs/cm/inches) per method"<<endl;
  init_vector SzFreq_mincomp(1,SzFreq_Nmeth);               //  mincomp to add for each method
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_mincomp<<" Sizefreq mincomp per method "<<endl;
  init_ivector SzFreq_nobs(1,SzFreq_Nmeth);
  !!if(SzFreq_Nmeth>0) echoinput<<SzFreq_nobs<<" Sizefreq N obs per method"<<endl;

  ivector SzFreq_Nbins_seas_g(1,SzFreq_Nmeth*nseas);   //  array dimensioner used only for the SzFreqTrans array
  ivector SzFreq_Nbins3(1,SzFreq_Nmeth)        // doubles the Nbins if gender==2
  int SzFreqMethod_seas;

 LOCAL_CALCS
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
        warning<<" error:  cannot accumulate biomass into length-based szfreq scale for method: "<<k<<endl;
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

 LOCAL_CALCS
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
    echoinput<<"Processed_SizeFreqMethod_bins"<<k<<endl<<SzFreq_bins(k)<<endl;;
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
  // SzFreq_obs_hdr:     1=y; 2=s; 3=f; 4=gender; 5=partition; 6=method&skip flag; 7=first bin to use; 8=last bin(e.g. to include males or not); 9=flag to indicate transition matrix needs calculation
  vector SzFreq_sampleN(1,SzFreq_totobs);
  vector SzFreq_effN(1,SzFreq_totobs);
  vector SzFreq_eachlike(1,SzFreq_totobs);
  matrix SzFreq_obs(1,SzFreq_totobs,1,SzFreq_Setup2);
  imatrix SzFreq_LikeComponent(1,Nfleet,1,SzFreq_Nmeth)
  number N_suprper_SzFreq   //  no real need to keep track of these by method, so just use a number
 LOCAL_CALCS
  SzFreq_N_Like=0;
  if(SzFreq_Nmeth>0)
  {
    SzFreq_LikeComponent.initialize();
    SzFreq_obs.initialize();
    N_suprper_SzFreq=0;
    iobs=0;
    for (k=1;k<=SzFreq_Nmeth;k++)
    {
      for (j=1;j<=SzFreq_nobs(k);j++)
      {
//       if(y>=styr && y<=retro_yr)  // not used because all obs in one list
        iobs++;
        for (z=1;z<=5;z++)
        {SzFreq_obs_hdr(iobs,z) = int(SzFreq_obs1(iobs,z+1));}
        SzFreq_sampleN(iobs) = SzFreq_obs1(iobs,7);
        if(SzFreq_obs_hdr(iobs,2)<0) N_suprper_SzFreq++;  //  count the number of superperiod start/stops
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
        f=abs(SzFreq_obs_hdr(iobs,3));
        if(gender==1) SzFreq_obs_hdr(iobs,4)=1;  // just in case

        SzFreq_obs(iobs)/=sum(SzFreq_obs(iobs));
        SzFreq_obs(iobs)+=SzFreq_mincomp(k);
        SzFreq_obs(iobs)/=sum(SzFreq_obs(iobs));
        y=SzFreq_obs_hdr(iobs,1);
        temp=abs(SzFreq_obs_hdr(iobs,2));
        if(read_seas_mo==1)  // reading season
        {
              s=int(temp);
              if(s>nseas)
              {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Critical error, season for general sizecomp  method, obs "<<k<<" "<<j<<" is > nseas"<<endl; exit(1);}
              subseas=mid_subseas;
              if(surveytime(f)>=0.)
              {data_timing=surveytime(f);}  //  fraction of season
              else
              {data_timing=0.5;}
              real_month=1.0 + azero_seas(s)*12. + 12.*data_timing*seasdur(s);
        }
        else  //  reading month.fraction
        {
          real_month=temp;
          temp1=(temp-1.0)/12.;  //  month as fraction of year
          s=1;  // earlist possible seas;
          subseas=1;  //  earliest possible subseas in seas
          temp=subseasdur_delta(s);  //  starting value
          while(temp<=temp1+1.0e-9)
          {
            if(subseas==N_subseas)
            {s++; subseas=1;}
            else
            {subseas++;}
            temp+=subseasdur_delta(s);
          }
          data_timing=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (but is multiplied by seasdur as it is used, so perhaps change this)
          if(surveytime(f)==-1.)  //  so ignoring month info
          {
            subseas=mid_subseas;
            data_timing=0.5;
          }
        }
        SzFreq_obs_hdr(iobs,2)=SzFreq_obs_hdr(iobs,2)/abs(SzFreq_obs_hdr(iobs,2))*real_month;
        SzFreq_obs1(iobs,3)=real_month;

        t=styr+(y-styr)*nseas+s-1;
        ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
        SzFreq_time_t(iobs)=t;
        SzFreq_time_ALK(iobs)=ALK_time;
        if(gender==1) {SzFreq_obs_hdr(iobs,4)=0;}
        z=SzFreq_obs_hdr(iobs,4);  // gender
// get min and max index according to use of 0, 1, 2, 3 gender index
        if(z!=2) {SzFreq_obs_hdr(iobs,7)=1;} else {SzFreq_obs_hdr(iobs,7)=SzFreq_Nbins(k)+1;}
        if(z<=1) {SzFreq_obs_hdr(iobs,8)=SzFreq_Nbins(k);} else {SzFreq_obs_hdr(iobs,8)=2*SzFreq_Nbins(k);}
  //      SzFreq_obs_hdr(iobs,5);  // partition
        SzFreq_obs_hdr(iobs,6)=k;
        if(k!=SzFreq_obs1(iobs,1)) {N_warn++; warning<<" sizefreq ID # doesn't match "<<endl; } // save method code for later use
        if(y>=styr && y<=retro_yr)
        {
          SzFreq_LikeComponent(f,k)=1;    // indicates that this combination is being used
          if(SzFreq_HaveObs2(k,ALK_time)==0)  //  transition matirx needs calculation
            {
            	SzFreq_HaveObs2(k,ALK_time)=1;  // flad showing condition met
            	SzFreq_obs_hdr(iobs,9)=1;  //  flag that will be ehecked in ss_expval
            }

          have_data(ALK_time,0,0,0)=1;
          have_data(ALK_time,f,0,0)=1;  //  so have data of some type
          have_data(ALK_time,f,data_type,0)++;  //  count the number of observations in this subseas
          p=have_data(ALK_time,f,data_type,0);
          have_data(ALK_time,f,data_type,p)=iobs;  //  store data index for the p'th observation in this subseas

          if(SzFreq_obs_hdr(iobs,7)<0) SzFreq_obs_hdr(iobs,3)=-abs(SzFreq_obs_hdr(iobs,3));  //  old method for excluding from logL
        }
        else
        {
          SzFreq_obs_hdr(iobs,3)=-abs(SzFreq_obs_hdr(iobs,3));  //  flag for skipping this obs
        }
      }
    }
    SzFreq_N_Like=sum(SzFreq_LikeComponent);
    if(N_suprper_SzFreq>0)
    {
      j=N_suprper_SzFreq/2;  // because we counted the begin and end
      if(2*j!=N_suprper_SzFreq)
      {
        N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"unequal number of starts and ends of sizefreq superperiods "<<endl; exit(1);
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
   echoinput<<" Tag Releases "<<endl<<"TG area year seas tindex gender age N_released "<<endl<<TG_release<<endl;
   TG_endtime(1)=0;
   if(N_TG>0)
   {
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
     TG=TG_recap_data(j,1);  // TD the tag group
     t=styr+int((TG_recap_data(j,2)-styr)*nseas+TG_recap_data(j,3)-1) - TG_release(TG,5); // find elapsed time in terms of number of seasons
     if(t>TG_maxperiods) t=TG_maxperiods;
     if(t<0)
     {
       N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" recapture is before tag release for recap: "<<j<<endl;  exit(1);
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
   init_vector mc_temp(1,3*Do_Morphcomp);
   int Morphcomp_nobs
   int Morphcomp_nmorph
   number Morphcomp_mincomp
 LOCAL_CALCS
  if(Do_Morphcomp>0)
  {
    Morphcomp_nobs=mc_temp(1);
    Morphcomp_nmorph=mc_temp(2);   // later compare this value to the n morphs in the control file and exit if different
    Morphcomp_mincomp=mc_temp(3);
  echoinput<<Morphcomp_nobs<<" Morphcomp_nobs "<<endl;
  echoinput<<Morphcomp_nmorph<<" Morphcomp_nmorph "<<endl;
  echoinput<<Morphcomp_mincomp<<" Morphcomp_mincomp "<<endl;
  }
  else
  {
    Morphcomp_nobs=0;
  }
 END_CALCS
 init_matrix Morphcomp_obs(1,Morphcomp_nobs,1,5+Morphcomp_nmorph)
//    yr, seas, type, partition, Nsamp, datavector

  3darray Morphcomp_havedata(1,Nfleet*Do_Morphcomp,styr,TimeMax,0,0)    // last dimension is reserved for future use of Partition
 LOCAL_CALCS
  if(Do_Morphcomp>0)
  {
  echoinput<<" morph composition data"<<endl<<"yr seas type partition Nsamp datavector"<<endl<< Morphcomp_obs<<endl;
  Morphcomp_havedata=0;
  for (i=1;i<=Morphcomp_nobs;i++)
  {
    y=Morphcomp_obs(i,1); s=Morphcomp_obs(i,2); t=styr+(y-styr)*nseas+s-1;
    f=Morphcomp_obs(i,3); z=Morphcomp_obs(i,4);   // z not used, partition must be 0 (e.g. combined discard and retained)
    Morphcomp_havedata(f,t,0)=i;
//  CODE HERE NEEDS UPDATE
    have_data(t,f,8)=i;
    have_data(t,f,8,2)=s;  // season or month; later will be processed according to value of readseasmo
    if(y>retro_yr) Morphcomp_obs(i,5) = -fabs(Morphcomp_obs(i,5));
    Morphcomp_obs(i)(6,5+Morphcomp_nmorph) /= sum(Morphcomp_obs(i)(6,5+Morphcomp_nmorph));
    Morphcomp_obs(i)(6,5+Morphcomp_nmorph) += Morphcomp_mincomp;
    Morphcomp_obs(i)(6,5+Morphcomp_nmorph) /= sum(Morphcomp_obs(i)(6,5+Morphcomp_nmorph));
  }
  }
 END_CALCS

  int Do_SelexData;
!!  Do_SelexData=0;

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

  init_int Do_Benchmark  // 0=skip; do Fspr, Fbtgt, Fmsy
  !!echoinput<<Do_Benchmark<<" Do_Benchmark "<<endl;
  init_int Do_MSY   //  1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr)
  !!echoinput<<Do_MSY<<" Do_MSY "<<endl;

  int did_MSY;
  int show_MSY;
  int wrote_bigreport;
  !! show_MSY=0;
  !! did_MSY=0;
  !! wrote_bigreport=0;

  init_number SPR_target
  !!echoinput<<SPR_target<<" SPR_target "<<endl;
  init_number BTGT_target
  !!echoinput<<BTGT_target<<" BTGT_target "<<endl;

  ivector Bmark_Yr(1,10)
  ivector Bmark_t(1,2)  //  for range of time values for averaging body size
  init_ivector Bmark_Yr_rd(1,6)
  init_int Bmark_RelF_Basis
 LOCAL_CALCS
  echoinput<<Bmark_Yr_rd<<" Benchmark years as read:  beg-end bio; beg-end selex; beg-end relF"<<endl;

  for (i=1;i<=6;i++)  //  beg-end bio; beg-end selex; beg-end relF
  {
    if(Bmark_Yr_rd(i)==-999)
    {Bmark_Yr(i)=styr;}
    else if(Bmark_Yr_rd(i)>=styr)
    {Bmark_Yr(i)=Bmark_Yr_rd(i);}
    else if(Bmark_Yr_rd(i)<=0)
    {Bmark_Yr(i)=endyr+Bmark_Yr_rd(i);}
    else
    {
      N_warn++;Bmark_Yr(i)=styr;warning<<"benchmark year less than styr; reset to equal styr"<<endl;
    }
  }

  // default for transition to 3.30
  //  for distribution of recruits among areas&morphs
  Bmark_Yr(7) = styr;
  Bmark_Yr(8) = endyr;
  //  for SRparms
  Bmark_Yr(9) = styr;
  Bmark_Yr(10) = endyr;

  Bmark_t(1)=styr+(Bmark_Yr(1)-styr)*nseas;
  Bmark_t(2)=styr+(Bmark_Yr(2)-styr)*nseas;

  echoinput<<Bmark_Yr<<" Benchmark years as processed:  beg-end bio; beg-end selex; beg-end relF; beg-end recruits"<<endl;
  echoinput<<Bmark_RelF_Basis<<"  1=use range of years for relF; 2 = set same as forecast relF below"<<endl;
 END_CALCS

  init_int Do_Forecast   //  0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (enter yrs); 5=read Fmult
  !!echoinput<<Do_Forecast<<" Do_Forecast "<<endl;

  vector Fcast_Input(1,22);

  int N_Fcast_Yrs
  ivector Fcast_yr(1,6)  // yr range for selex, then yr range foreither allocation or for average F
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
  int HarvestPolicy  // 1=west coast adjust catch; 2=AK to adjust F
  number H4010_top
  number H4010_bot
  number H4010_scale
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

  int Fcast_Specify_Selex   // 0=do not use; 1=specify one selectivity for all fishing fleets for forecasts (not implemented); 2=specify selectivity per fishing fleet for forecasts (not implemented)

//  matrix Fcast_RelF(1,nseas,1,Nfleet)

 LOCAL_CALCS

  Fcast_Specify_Selex = 0;  // default for 3.24 files

  if(Do_Forecast==0)
  {
    k=0;
    echoinput<<"No forecast selected, so rest of forecast file will not be read and can be omitted"<<endl;
    echoinput<<"No forecast selected, default forecast of 1 yr created"<<endl;
    if(Bmark_RelF_Basis==2) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Fatal stop:  no forecast, but bmark set to use fcast"<<endl;  exit(1);}
    Fcast_yr.initialize();
    Fcast_yr_rd.initialize();
    Fcast_Loop_Control.initialize();
  }
  else
  {
    k=22;
    echoinput<<"Forecast selected; next 22 input values will be read as a block then parsed and procesed "<<endl;
  }
 END_CALCS
  init_vector Fcast_Input_rd(1,k)

 LOCAL_CALCS
  if(Do_Forecast>0)
  {
    Fcast_Input(1,k)=Fcast_Input_rd(1,k);
  k=0;
  k++; N_Fcast_Yrs=int(Fcast_Input(k));
  echoinput<<N_Fcast_Yrs<<" N_Fcast_Yrs "<<endl;
  if(Do_Forecast>0&&N_Fcast_Yrs<=0) {N_warn++; cout<<"Critical error in forecast input, see warning"<<endl; warning<<"ERROR: cannot do a forecast of zero years: "<<N_Fcast_Yrs<<endl; exit(1);}
  YrMax=endyr+N_Fcast_Yrs;
  TimeMax_Fcast_std = styr+(YrMax-styr)*nseas+nseas-1;
  k++; Fcast_Flevel=Fcast_Input(k);
  echoinput<<Fcast_Flevel<<" Fmult value used only if Do_Forecast==5"<<endl;
  k++; Fcast_yr(1)=int(Fcast_Input(k));
  k++; Fcast_yr(2)=int(Fcast_Input(k));
  k++; Fcast_yr(3)=int(Fcast_Input(k));
  k++; Fcast_yr(4)=int(Fcast_Input(k));

  // default values for 3.30
  Fcast_yr(5) = -999;
  Fcast_yr(6) = 0;

  Fcast_yr_rd = Fcast_yr;

  echoinput<<Fcast_yr<<" Begin-end yrs for average selex; begin-end yrs for allocation"<<endl;
  for (i=1;i<=6;i++)
  {
    if(Fcast_yr(i)==-999)
    {Fcast_yr(i)=styr;}
    else if(Fcast_yr(i)>0)
    {Fcast_yr(i)=Fcast_yr(i);}
    else
    {Fcast_yr(i)=endyr+Fcast_yr(i);}
  }
  Fcast_Sel_yr1=Fcast_yr(1);
  Fcast_Sel_yr2=Fcast_yr(2);
  Fcast_RelF_yr1=Fcast_yr(3);
  Fcast_RelF_yr2=Fcast_yr(4);
  Fcast_Rec_yr1=Fcast_yr(5);
  Fcast_Rec_yr2=Fcast_yr(6);
  echoinput<<Fcast_yr<<"  After Transformation:  begin-end yrs for average selex; begin-end yrs for rel F; begin-end yrs for recruits"<<endl;

  k++; HarvestPolicy=int(Fcast_Input(k));
  k++; H4010_top=Fcast_Input(k);
  k++; H4010_bot=Fcast_Input(k);
  k++; H4010_scale=Fcast_Input(k);
  echoinput<<HarvestPolicy<<"  HarvestPolicy "<<endl<<
  H4010_top<<"  H4010_top "<<endl<<
  H4010_bot<<"  H4010_bot "<<endl<<
  H4010_scale<<"  H4010_scale "<<endl;
  if(H4010_top<=H4010_bot) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" control rule top: "<<H4010_top<<" must be > control rule bottom "<<H4010_bot<<endl; exit(1);}
  if(H4010_scale>1.0) {N_warn++; warning<<" Sure you want harvest policy scalar > 1.0? "<<H4010_scale<<endl;}

  k++; Fcast_Loop_Control(1)=Fcast_Input(k);
  k++; Fcast_Loop_Control(2)=Fcast_Input(k);
  k++; Fcast_Loop_Control(3)=Fcast_Input(k);
  k++; Fcast_Loop_Control(4)=Fcast_Input(k);
  k++; Fcast_Loop_Control(5)=Fcast_Input(k);
  k++; Fcast_Cap_FirstYear=Fcast_Input(k);
  echoinput<<Fcast_Loop_Control(1)<<" N forecast loops (1-3) (recommend 3)"<<endl;
  echoinput<<Fcast_Loop_Control(2)<<" First forecast loop with stochastic recruitment (recommend 3)"<<endl;
  echoinput<<Fcast_Loop_Control(3)<<" Forecast loop control #3 (reserved for future use) "<<endl;
  echoinput<<Fcast_Loop_Control(4)<<" Forecast loop control #4 (reserved for future use) "<<endl;
  echoinput<<Fcast_Loop_Control(5)<<" Forecast loop control #5 (reserved for future use) "<<endl;
  echoinput<<Fcast_Cap_FirstYear<<"  Fcast_Cap_FirstYear for caps and allocations (should be after any fixed inputs) "<<endl;

  k++; Impl_Error_Std=Fcast_Input(k);
  echoinput<<Impl_Error_Std<<"  Impl_Error_Std "<<endl;
  if(Impl_Error_Std>0.0) Do_Impl_Error=1;

  k++; Do_Rebuilder=int(Fcast_Input(k));
  k++; Rebuild_Ydecl=int(Fcast_Input(k));
  k++; Rebuild_Yinit=int(Fcast_Input(k));
  echoinput<<
  Do_Rebuilder<<"  Do_Rebuilder "<<endl<<
  Rebuild_Ydecl<<"  Rebuild_Ydecl "<<endl<<
  Rebuild_Yinit<<"  Rebuild_Yinit "<<endl;

  k++; Fcast_RelF_Basis=int(Fcast_Input(k));
  echoinput<<Fcast_RelF_Basis<<" fleet relative F (1=use_year_range/2=read_seas_x_fleet) "<<endl;

  k++; Fcast_Catch_Basis=Fcast_Input(k);
    echoinput<<Fcast_Catch_Basis<<"  Fcast_Catch_Basis for caps and allocations "<<endl;
    echoinput<<"2=dead catch bio, 3=retained catch bio, 5= dead catch numbers 6=retained catch numbers;   Same for all fleets"<<endl;
  }
  else
  {
  N_Fcast_Yrs=1;
  YrMax=endyr+1;
  TimeMax_Fcast_std = styr+(YrMax-styr)*nseas+nseas-1;
  Fcast_Flevel=0;
  Fcast_yr=0;
  Fcast_RelF_Basis=1;
  Fcast_yr(1)=Fcast_Sel_yr1=endyr;
  Fcast_yr(2)=Fcast_Sel_yr2=endyr;
  Fcast_yr(3)=Fcast_RelF_yr1=endyr;
  Fcast_yr(4)=Fcast_RelF_yr2=endyr;
  Fcast_yr(5)=Fcast_Rec_yr1=styr;
  Fcast_yr(6)=Fcast_Rec_yr2=endyr;
  Fcast_yr_rd = Fcast_yr;
  HarvestPolicy=2;
  H4010_top=0.4;
  H4010_bot=0.01;
  H4010_scale=1.0;
  Fcast_Loop_Control.fill("{3,3,0,0,0}");
  Fcast_Cap_FirstYear=endyr+1;
  Impl_Error_Std=0.0;
  Do_Impl_Error=0;
  Do_Rebuilder=0;
  Rebuild_Ydecl=endyr;
  Rebuild_Yinit=endyr;
  Fcast_RelF_Basis=1;
  Fcast_Catch_Basis=2;
  }  //  end of defaults for do_forecast = 0

  if(Fcast_RelF_Basis==2)
  {
    if(Do_Forecast==4)
    {
      N_warn++; warning<<"Cannot specify forecast fleet relative F because Do_Forecast==4 specifies relative F directly as F;"<<endl;
      Fcast_RelF_Basis=1;
    }
    z=nseas;
    echoinput<<"Fcast_RelF_Basis==2, so now read seas(row) x fleet (column) array of relative F; will be re-scaled to sum to 1.0"<<endl;
  }
  else
  {z=0;}
 END_CALCS

  init_matrix Fcast_RelF_Input(1,z,1,Nfleet1)

 LOCAL_CALCS
  if(Fcast_RelF_Basis==2 && Do_Forecast>0)
  {
    echoinput<<" fleet relative F by season and fleet as read"<<endl<<Fcast_RelF_Input<<endl;
    // later set Fcast_RelF_Use=Fcast_RelF_Input;
  }
  else
  {
    echoinput<<" do not read relative F by season and fleet "<<endl;
  }
  if(Do_Forecast>0)
  {
    k=1;
    echoinput<<"Now read cap for each fleet, then cap for each area (even if only 1 area), then allocation assignment for each fleet"<<endl;
  }
  else
    {k=0;}
  echoinput<<" dimensions "<<k<<" "<<Nfleet1<<" "<<Nfleet<<endl;

 END_CALCS
  init_vector Fcast_MaxFleetCatch_rd(1,k*Nfleet1)
  init_vector Fcast_MaxAreaCatch_rd(1,k*pop)
  init_ivector Allocation_Fleet_Assignments_rd(1,k*Nfleet1)
  vector Fcast_MaxFleetCatch(1,Nfleet)
  vector Fcast_MaxAreaCatch(1,pop)
  ivector Allocation_Fleet_Assignments(1,Nfleet)
 LOCAL_CALCS
    for(f=1;f<=Nfleet;f++) Fcast_MaxFleetCatch(f)=-1;
    Fcast_Do_Fleet_Cap=0;
    Allocation_Fleet_Assignments.initialize();
    for(p=1;p<=pop;p++) Fcast_MaxAreaCatch(p)=-1;
    Fcast_Do_Area_Cap=0;
    Fcast_Catch_Allocation_Groups=0;
  if(k>0)
  {
    Fcast_MaxAreaCatch=Fcast_MaxAreaCatch_rd;
    for (f=1;f<=Nfleet1;f++)
    {
      Fcast_MaxFleetCatch(f)=Fcast_MaxFleetCatch_rd(f);
      if(Fcast_MaxFleetCatch(f)>0.0) Fcast_Do_Fleet_Cap=1;
    }

    for (f=1;f<=Nfleet1;f++)
    {Allocation_Fleet_Assignments(f)=Allocation_Fleet_Assignments_rd(f);}

    for (p=1;p<=pop;p++)
    {if(Fcast_MaxAreaCatch(p)>0.0) Fcast_Do_Area_Cap=1;}
    Fcast_Catch_Allocation_Groups=max(Allocation_Fleet_Assignments);
  }
  else
  {
  }
 END_CALCS

  matrix Fcast_Catch_Allocation(1,N_Fcast_Yrs,1,Fcast_Catch_Allocation_Groups);

 LOCAL_CALCS
  if(Do_Forecast>0)
  {
    echoinput<<" alloc groups "<<Fcast_Catch_Allocation_Groups<<endl;
    if(Fcast_Catch_Allocation_Groups>0)
    {
      *(ad_comm::global_datafile) >> Fcast_Catch_Allocation(1);
      for(y=1;y<=N_Fcast_Yrs;y++)
      {Fcast_Catch_Allocation(y)=Fcast_Catch_Allocation(1);}
    }
    else
    {
      Fcast_Catch_Allocation.initialize();
    }

    k=2;
    echoinput<<" Max totalcatch by fleet "<<endl<<Fcast_MaxFleetCatch<<endl;
    echoinput<<" Max totalcatch by area "<<endl<<Fcast_MaxAreaCatch<<endl;
    echoinput<<" Assign fleets to allocation groups (0 means not in a group) "<<endl<<Allocation_Fleet_Assignments<<endl;
    echoinput<<" calculated number of allocation groups "<<Fcast_Catch_Allocation_Groups<<endl;
    echoinput<<" Allocation among groups (columns are allocation groups, rows are N forecast years) "<<endl<<Fcast_Catch_Allocation<<endl;
  }
  else
  {k=0;}
 END_CALCS

  init_ivector more_Fcast_input(1,k);
 LOCAL_CALCS
  if(k>0)
  {
    N_Fcast_Input_Catches=more_Fcast_input(1);
    Fcast_InputCatch_Basis=more_Fcast_input(2);
    echoinput<<N_Fcast_Input_Catches<<" N_Fcast_input_catches "<<endl;
    echoinput<<Fcast_InputCatch_Basis<<" # basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F); -1=read fleet/time specific (bio/num units are from fleetunits; note new codes in SSV3.20)"<<endl;
    k1 = styr+(endyr-styr)*nseas-1 + nseas + 1;
    y=k1+(N_Fcast_Yrs)*nseas-1;
    if(N_Fcast_Input_Catches>0) echoinput<<"Now read "<<N_Fcast_Input_Catches<<" of fixed forecast catches (yr, seas, fleet, catch) "<<endl;
  }
  else
  {
    N_Fcast_Input_Catches=0;
    Fcast_InputCatch_Basis=2;
    k1=1;
    y=0;
  }
  if(Fcast_InputCatch_Basis==-1)
    {j=5;}
    else
    {j=4;}
 END_CALCS

  3darray Fcast_InputCatch(k1,y,1,Nfleet1,1,2)  //  values and basis to be used
  init_matrix Fcast_InputCatch_rd(1,N_Fcast_Input_Catches,1,j)  //  values to be read:  yr, seas, fleet, value, (basis)

 LOCAL_CALCS
  Fcast_InputCatch.initialize();
  if(N_Fcast_Input_Catches>0) echoinput<<" Fcast_catches_input "<<endl<<Fcast_InputCatch_rd<<endl;
  if(Do_Forecast>0)
  {
    if(N_Fcast_Input_Catches>0)
    {
      echoinput<<"Forecast input catches as read "<<endl<<Fcast_InputCatch_rd<<endl;
      for (t=k1;t<=y;t++)
      for (f=1;f<=Nfleet1;f++)
      {Fcast_InputCatch(t,f,1)=-1;}
      for (i=1;i<=N_Fcast_Input_Catches;i++)
      {
        y=Fcast_InputCatch_rd(i,1); s=Fcast_InputCatch_rd(i,2); f=Fcast_InputCatch_rd(i,3);
        if(y>endyr && y<=YrMax && f<=Nfleet1)
        {
          t=styr+(y-styr)*nseas +s-1;
          Fcast_InputCatch(t,f,1)=Fcast_InputCatch_rd(i,4);
          if(y>=Fcast_Cap_FirstYear) {N_warn++;warning<<"Input catches in "<<y<<" can be overridden by caps or allocations"<<endl;}
          if(Fcast_InputCatch_Basis==-1)
          {
            Fcast_InputCatch(t,f,2)=Fcast_InputCatch_rd(i,5);  //  new method
          }
          else
          {
            Fcast_InputCatch(t,f,2)=Fcast_InputCatch_Basis;  //  method before 3.24P
          }
      	}
      }
    }
    if(N_Fcast_Input_Catches>0) echoinput<<"Processed forecast input catches:"<<endl<<Fcast_InputCatch<<endl;
  }

  if(Do_Rebuilder>0 && Do_Forecast<=0) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" error: Rebuilder output selected without requesting forecast"<<endl; exit(1);}
  if(Do_Benchmark==0)
  {
    if(Do_Forecast>=1 && Do_Forecast<=3) {Do_Benchmark=1; N_warn++; warning<<" Turn Benchmark on because Forecast needs it"<<endl;}
    if(Do_Forecast==0 && F_std_basis>0) {F_std_basis=0; N_warn++; warning<<" Set F_std_basis=0 because no benchmark or forecast"<<endl;}
    if(depletion_basis==2) {depletion_basis=1; N_warn++; warning<<" Change depletion basis to 1 because benchmarks are off"<<endl;}
    if(SPR_reporting>=1 && SPR_reporting<=3) {SPR_reporting=4; N_warn++; warning<<" Change SPR_reporting to 4 because benchmarks are off"<<endl;}
  }
  else
  {
     if(Do_MSY==0)  {Do_MSY=1; N_warn++; warning<<" Setting Do_MSY=1 because benchmarks are on"<<endl;}
  }
  if(Do_Forecast==2 && Do_MSY!=2) {Do_MSY=2; N_warn++; warning<<" Set MSY option =2 because Forecast option =2"<<endl;}
  if(depletion_basis==2 && Do_MSY!=2) {Do_MSY=2; N_warn++; warning<<" Set MSY option =2 because depletion basis is B_MSY"<<endl;}
  if(SPR_reporting==2 && Do_MSY!=2) {Do_MSY=2; N_warn++; warning<<" Set MSY option =2 because SPR basis is SPR_MSY"<<endl;}
  if(Fcast_Sel_yr1>Fcast_Sel_yr2) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Sel_Yr1 must be at or before Fcast_Sel_Yr2"<<endl;  exit(1);}
  if(Fcast_Sel_yr1>endyr || Fcast_Sel_yr1<styr) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Sel_Yr1 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Sel_yr2>endyr || Fcast_Sel_yr2<styr) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Sel_Yr2 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Rec_yr1>Fcast_Rec_yr2) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Rec_Yr1 must be at or before Fcast_Rec_Yr2"<<endl;  exit(1);}
  if(Fcast_Rec_yr1>endyr || Fcast_Rec_yr1<styr) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Rec_Yr1 must be between styr and endyr"<<endl;  exit(1);}
  if(Fcast_Rec_yr2>endyr || Fcast_Rec_yr2<styr) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, Fcast_Rec_Yr2 must be between styr and endyr"<<endl;  exit(1);}

  did_MSY=0;

 END_CALCS

  init_number fif

 LOCAL_CALCS
  if(Do_Forecast>0 && fif!=999) {cout<<" EXIT, must have 999 to verify end of forecast inputs "<<fif<<endl; exit(1);}
  echoinput<<" done reading forecast "<<endl<<endl;
  if(Do_Forecast==0) Do_Forecast=4;
 END_CALCS

  imatrix Show_Time(styr,TimeMax_Fcast_std,1,2)  //  for each t:  shows year, season
  imatrix Show_Time2(1,ALK_time_max,1,2)  //  for each ALK_time:  shows year, season
 LOCAL_CALCS
  t=styr-1;
  for (y=styr;y<=YrMax;y++) /* SS_loop:  fill Show_Time(t,1) with year value */
  for (s=1;s<=nseas;s++) /* SS_loop:  fill Show_Time(t,2) with season value */
  {
    t++;
    Show_Time(t,1)=y;
    Show_Time(t,2)=s;
  }
  ALK_idx=0;
  for (y=styr;y<=endyr+19;y++)
  for (s=1;s<=nseas;s++)
  for (subseas=1;subseas<=N_subseas;subseas++)
  {
    ALK_idx++;
    Show_Time2(ALK_idx,1)=y;
    Show_Time2(ALK_idx,2)=s;
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
  if(STD_Yr_max==-1) STD_Yr_max=endyr;
  if(STD_Yr_max==-2) STD_Yr_max=YrMax;
  if(STD_Yr_max>YrMax) STD_Yr_max=YrMax;
   STD_Yr_Reverse.initialize();
   for (y=STD_Yr_min;y<=STD_Yr_max;y++) {STD_Yr_Reverse(y)=1;}
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
  echoinput<<"Finished creating STD containers and indexes "<<endl;
 END_CALCS
