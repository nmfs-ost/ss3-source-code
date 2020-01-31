
//*********COUNTERS*************************
  int z // counters for size (length)
  int z1  // min for z counter
  int z2  // max for z counter
  int  L1  //  for selecting sex specific length data
  int  L2  //  used for l+nlength to get length bin for males
  int  A2  //  used for a+nages+1 to get true age bin for males
  int a1  // use to track a subset of ages
  int f // counter for fleets and surveys.  total is Ntypes
  int f1  // another fleet counter
  int fs  //  counter for fleets when looping across size and ageselex; so = f-Ntypes

  int gmorph // number of biological entities:  gender*GP*BirthEvent*Platoon
  int g // counter for biological entity
  int GPat  //  counter for Gpattern (morph)
  int gg  // counter for sex
  int gp //  counter for sex*GPat  or for Gpat
  int gp2  //  used to loop platoons within Gpattern

  int a // counter for ages
  int b // counter for age bins
  int p // counter for area
  int p1
  int p2 // counter for destination area in migration
  int i // counter for observations
  int y // counter for year
  int yz // year, but not allowed to extend past endyr
  int s // counter for seasons
  int s2  // destination season
  int mid_subseas  //  index of the subseas that corresponds to the middle of the season
  int subseas  //  subseas, mostly used to calc ALK_idx
  int ALK_idx  //  index to which subseas within current year to use for the ALK  ALK_idx=(s-1)*N_subseas+subseas
  int ALK_time  //  continuous index to subseas =(y-styr)*nseas*N_subseas+ALK_idx
  int ALK_idx_mid  //  index of subseason at middle of season
  int t // counter for time, combining year and season
  int mo  //  month (1-12), not (0-11)
  int j
  int j1
  int j2
  int k
  int k1
  int k2
  int k3
  int s_off  // offset for male section of vectors
  int Fishon  // whether or not to do fishery catch in equil_calc
  int NP  // number of parameters
  int Ip  // parameter counter
  int firstseas   // used to start season loops at the birthseason
  int t_base;    //
  int niter  // iteration count
  int loop
  int TG_t;  // time counter (in seasons) for tag groups
  int Fcast_catch_start
//  int ParCount;
  int retParCount;
  int N_SC;  // counter for starter comments
  int N_DC;
  int N_CC;
  int N_FC;

  int catch_mult_pointer;

  int frac_female_pointer;

  int icycle
  int No_Report  //  flag to skip output reports after MCMC and MCeval
  int mcmcFlag
  int noest_flag
  number temp;
  number temp1;
  int save_for_report;
  int bigsaver;  //  (save_for_report>0) || ((sd_phase() || mceval_phase()) && (initial_params::mc_phase==0))
  int write_bodywt;
  int save_gparm;
  int save_gparm_print;
  int N_warn;
  !! save_for_report=0;
  !! bigsaver=0;
  !! save_gparm=0;
  !! N_warn=0;
  !! write_bodywt=0;

  int Nparm_on_bound;

 LOCAL_CALCS

  No_Report=0;
  Ncycle=3;
  z=0; z1=0; z2=0; L1=0; L2=0; A2=0;  a1=0; f=0; f1=0; fs=0; 
  gmorph=0; g=0; GPat=0; gg=0; gp=0; gp2=0; 
  a=0; b=0; p=0; p1=0; p2=0; i=0; y=0; yz=0; s=0; s2=0; 
  mid_subseas=0;  subseas=0; ALK_idx=0; ALK_time=0; ALK_idx_mid=0; 
  t=0; mo=0; j=0; j1=0; j2=0; k=0; k1=0; k2=0; k3=0; s_off=0; 
  Fishon=0; NP=0; Ip=0; firstseas=0; t_base=0; niter=0; loop=0; 
  TG_t=0; Fcast_catch_start=0; retParCount=0; N_SC=0; N_DC=0; N_CC=0; N_FC=0; catch_mult_pointer=0; frac_female_pointer=0; icycle=0; No_Report=0; 
  mcmcFlag=0; noest_flag=0; temp=0; temp1=0; save_gparm_print=0; 

  //  SS_Label_Info_1.1.2  #Create elements of parameter labels
//  adstring_array NumLbl;
//  adstring_array GenderLbl;   // gender label
//  adstring_array CRLF;   // blank to terminate lines

  CRLF+="";
  GenderLbl+="Fem";
  GenderLbl+="Mal";
  GP_Lbl+="_GP_1";
  GP_Lbl+="_GP_2";
  GP_Lbl+="_GP_3";
  GP_Lbl+="_GP_4";
  GP_Lbl+="_GP_5";
  GP_Lbl+="_GP_6";
  onenum="    ";
  for (i=1;i<=199;i++) /* SS_loop: fill string NumLbl with numbers */
  {
  sprintf(onenum, "%d", i);
  NumLbl+=onenum+CRLF(1);
  }

//  SS_Label_Info_1.2  #Read the STARTER.SS file
// /*  SS_Label_Flow  read STARTER.SS */
  ad_comm::change_datafile_name("starter.ss");       //  get filenames
  cout<<" reading from STARTER.SS"<<endl;
  adstring checkchar;
  line_adstring readline;
  checkchar="";
  ifstream Starter_Stream("starter.ss");
   //  this opens a different logical file with a separate pointer from the pointer that ADMB uses when reading using init command to read from global_datafile
  k=0;
  N_SC=0;
  while(k==0)
  {
    Starter_Stream >>  readline;          // reads a single line from input stream
    if(length(readline)>2)
    {
      checkchar=readline(1);
      k=strcmp(checkchar,"#");
      checkchar=readline(1,2);
      j=strcmp(checkchar,"#C");
      if(j==0) {N_SC++; Starter_Comments+=readline;}
    }
  }
  echoinput<<version_info<<endl<<ctime(&start)<<endl;
  warning<<version_info<<endl<<ctime(&start)<<endl;

  adstring sw;  //  used for reading of ADMB switches from command line
  mcmcFlag = 0;
  noest_flag=0;
  for (i=0;i<argc;i++)  /* SS_loop: check command line arguments for mcmc commands */
  {
    sw = argv[i];
    j=strcmp(sw,"-mcmc");
    if(j==0) {mcmcFlag = 1;}
    j=strcmp(sw,"-mceval");
    if(j==0) {mcmcFlag = 1;}
  }
 END_CALCS


  init_adstring datfilename
  !!echoinput<<datfilename<<"  datfilename"<<endl;
  init_adstring ctlfilename
  !!echoinput<<ctlfilename<<"  ctlfilename"<<endl;
  init_int readparfile
  !!echoinput<<readparfile<<"  readparfile"<<endl;
  init_int rundetail
  !!echoinput<<rundetail<<"  rundetail"<<endl;
  init_int reportdetail
 LOCAL_CALCS
  if (reportdetail < 0 || reportdetail > 2) reportdetail = 0;
  echoinput<<reportdetail<<"  reportdetail"<<endl;
 END_CALCS

  init_int docheckup           // flag for ending dump to "checkup.SS"
   !!echoinput<<docheckup<<"  docheckup"<<endl;
  init_int Do_ParmTrace
   !!echoinput<<Do_ParmTrace<<"  Do_ParmTrace"<<endl;
  init_int Do_CumReport
   !!echoinput<<Do_CumReport<<"  Do_CumReport"<<endl;
  init_int Do_all_priors
   !!echoinput<<Do_all_priors<<"  Do_all_priors"<<endl;
  init_int SoftBound
   !!echoinput<<SoftBound<<"  SoftBound"<<endl;
  init_int N_nudata_read
  int N_nudata
   !! N_nudata=N_nudata_read;
   !!echoinput<<N_nudata<<"  N_nudata"<<endl;
  init_int Turn_off_phase
   !!echoinput<<Turn_off_phase<<"  Turn_off_phase"<<endl;

// read in burn and thinning intervals
  init_int burn_intvl
   !!echoinput<<burn_intvl<<"  MCeval burn_intvl"<<endl;
  init_int thin_intvl
   !!echoinput<<thin_intvl<<"  MCeval thin_intvl"<<endl;

  init_number jitter
   !!echoinput<<jitter<<"  jitter fraction for initial parm values"<<endl;

  init_int STD_Yr_min  // min yr for sdreport
   !!echoinput<<STD_Yr_min<<"  STD_Yr_min"<<endl;
  init_int STD_Yr_max  // max yr for sdreport
   !!echoinput<<STD_Yr_max<<"  STD_Yr_max (-1 for "<<endl;
  init_int N_STD_Yr_RD  // N extra years to read
   !!echoinput<<N_STD_Yr_RD<<"  N extra STD years to read"<<endl;
  int N_STD_Yr
  init_ivector STD_Yr_RD(1,N_STD_Yr_RD)
   !!if(N_STD_Yr_RD>0) echoinput<<STD_Yr_RD<<"  vector of extra STD years"<<endl;
  // wait to process the above until after styr, endyr, N-forecast_yrs are read in data and forecast sections below

// set up the mcmc chain counter
  int mceval_counter;
  int mceval_header;
  !! mceval_counter = 0;
  !! mceval_header = 0;
  int mcmc_counter;
  !! mcmc_counter = 0;
  int done_run;
  !! done_run=0;

// set up the convergence criteria
  vector func_eval(1,50);
  vector func_conv(1,50);
//  number final_conv;
  init_number final_conv;
   !!echoinput<<final_conv<<"  final_conv"<<endl;

  !! func_eval.fill_seqadd(100,0);
  !! func_conv.fill_seqadd(1,0);
  !! func_conv(1)=10.;
  !! func_conv(2)=10.;

  init_int retro_yr;             //  introduce year for retrospective analysis
   !!echoinput<<retro_yr<<"  retro_yr"<<endl;
  int fishery_on_off;
  !! fishery_on_off=1;

  init_int Smry_Age
   !!echoinput<<Smry_Age<<"  Smry_Age"<<endl;

  init_int depletion_basis   // 0=skip; 1=fraction of B0; 2=fraction of Bmsy where fraction is depletion_level 3=rel to styr
   !!echoinput<<depletion_basis<<"  depletion_basis"<<endl;
  init_number depletion_level
   !!echoinput<<depletion_level<<"  depletion_level"<<endl;
  init_int SPR_reporting  // 0=skip; 1=SPR; 2=SPR_MSY; 3=SPR_Btarget; 4=(1-SPR)
   !!echoinput<<SPR_reporting<<"  SPR_reporting"<<endl;
  init_int F_reporting  // 0=skip; 1=exploit(Bio); 2=exploit(Num); 3=sum(frates); 4=true F for range of ages; 5=unweighted avg F for range of ages
 LOCAL_CALCS
  echoinput<<F_reporting<<"  F_reporting"<<endl;
  if(F_reporting==4 || F_reporting==5) {k=2;} else {k=0;}
 END_CALCS
  init_ivector F_reporting_ages_R(1,k);
  //  convert to F_reporting_ages later after nages is read.
 LOCAL_CALCS
  if(k>0)
    {
      echoinput<<F_reporting_ages_R<<"  F_reporting_ages_R"<<endl;
      echoinput<<"Will be checked against maxage later "<<endl;
    }
 END_CALCS

  init_int F_std_basis // 0=raw; 1=rel Fspr; 2=rel Fmsy ; 3=rel Fbtgt; 4=annual F for range of years
  !!echoinput<<F_std_basis<<"  F_std_basis"<<endl;
  !!echoinput<<"For Kobe plot, set depletion_basis=2; depletion_level=1.0; F_reporting=your choose; F_std_basis=2"<<endl;
  number finish_starter
  int mcmc_output_detail
  number MCMC_bump  //  value read and added to ln(R0) when starting into MCMC
  number ALK_tolerance
  number tempin;
  int ender;
  int irand_seed;
  int irand_seed_rd;

 LOCAL_CALCS
   {
    mcmc_output_detail = 0;
    MCMC_bump=0.;
    ALK_tolerance=0.0;
    irand_seed_rd=-1;
    irand_seed=-1;
    ender=0;
    //embed following reads in a do-while such that additional reads can be added while retaining backward compatibility with files that do not have the added elements
    //  element list:
    //  1.  MCMC_output_detail.MCMC_bump
    //  2.  ALK_tolerance
    //  3.  irand_seed;  added for 3.30.15
    //  xx.  finish_starter
     do
     {	
      *(ad_comm::global_datafile) >> tempin;
      finish_starter=tempin;
      if(tempin==3.30 || tempin==999) ender=1;

   if(tempin==999.)  // finish read in 3.24 format for ss_trans
    {
      if (readparfile > 0)
      {
        echoinput<<endl<<"ss_trans does not read the PAR file; readparfile set to 0"<<endl<<endl;
        cout<<"Error: ss_trans does not read the PAR file; readparfile set to 0"<<endl;
        readparfile = 0;
      }

      echoinput<<"Read files in 3.24 format"<<endl<<endl;
    }
    else   // reading in 3.30 format
   {
     finish_starter=3.30;
     echoinput<<"Read files in 3.30 format"<<endl;
     echoinput<<"SS will read values until it reads 3.30"<<endl;
   	
     echoinput<<"read MCMC_output_detail.MCMC_bump as a single real number;  separate values will be parsed from integer and fraction"<<endl;
     mcmc_output_detail = int(tempin);
     MCMC_bump=tempin-mcmc_output_detail;
     if (mcmc_output_detail < 0 || mcmc_output_detail > 3) mcmc_output_detail = 0;
     echoinput<<"MCMC output detail:  "<<mcmc_output_detail<<endl;
     echoinput<<"MCMC bump to R0:  "<<MCMC_bump<<endl;

     echoinput<<"Now get ALK tolerance (0.0 is OK for no compression; 0.1 is too big;  suggest 0.0001)"<<endl;
     *(ad_comm::global_datafile) >> ALK_tolerance;
     echoinput<<"ALK tolerance:  "<<ALK_tolerance<<endl;
     // enforce valid range of ALK_tolerance
     if (ALK_tolerance < 0.0 || ALK_tolerance > 0.1)
     {
         warning<<"Error: ALK tolerance must be between 0.0 and 0.1"<<endl;
         cout<<"Error: ALK_tolerance must be between 0.0 and 0.1: "<<ALK_tolerance<<endl; exit(1);
     }

     echoinput<<"Now get random number seed; enter -1 to use long(time) as the seed"<<endl;
     *(ad_comm::global_datafile) >> tempin;
      if(tempin==3.30) 
      {ender=1; irand_seed_rd=-1; irand_seed=-1;}
      	else
     {irand_seed_rd=int(tempin);
     irand_seed=irand_seed_rd;
     echoinput<<"random number seed:  "<<irand_seed<<endl;
     tempin=0;
     }
     if(ender==0) {
     *(ad_comm::global_datafile) >> tempin;
      if(tempin==3.30) 
      	{ender=1;}
      	else
        {N_warn++; warning<<"starter.ss has extra input lines; check echoinput to verify read"<<endl;
        	echoinput<<endl<<"starter.ss should have read 3.30 here; it read: "<<tempin<<endl; exit(1);}
        }
    }
     } while (ender==0);
   echoinput<<"  finish reading starter.ss"<<endl<<endl;
   }
 END_CALCS

  //  end reading  from Starter file

  number pi
  !!  pi=3.14159265358979;

  number neglog19
  !!  neglog19 = -log(19.);

  number NilNumbers           //  used as the minimum for posfun and similar checks
  !! NilNumbers = 0.0000001;
// !!   NilNumbers = 0.000;

!!//  SS_Label_Info_1.2.1 #Set up a dummy datum for use when max phase = 0
  number dummy_datum
  int dummy_phase
  !! dummy_datum=1.;
  !! if(Turn_off_phase<=0) {dummy_phase=0;} else {dummy_phase=-6;}

  int runnumber
  int N_prof_var;
  int prof_var_cnt
  int prof_junk

 LOCAL_CALCS
  //  SS_Label_Info_1.3 #Read runnumber.ss
   ifstream fin1("runnumber.ss", ios::in);
    if (fin1)
    {
      fin1>>runnumber;
      runnumber++;
      fin1.close();
    }
    else
    {
      runnumber=1;
    }
  //  SS_Label_Info_1.3.1 #Increment runnumber and write to file
    ofstream fin2("runnumber.ss", ios::out);
    fin2 << runnumber;
    fin2.close();

  //  SS_Label_Info_1.4 #Read Profilevalues.ss file
   N_prof_var=998;
   ifstream fin3("profilevalues.ss", ios::in);
   fin3>>N_prof_var;   //  if file is null this will not return anything
   if (N_prof_var==998) {N_prof_var=0; prof_junk=0;} else {prof_junk=1;}
   fin3.close();
   if(N_prof_var>0)
   {ad_comm::change_datafile_name("profilevalues.ss");}
   else
   {ad_comm::change_datafile_name("runnumber.ss");}  // just to have something in scope
   prof_var_cnt=(runnumber-1)*N_prof_var+2;
 END_CALCS
   init_vector prof_var(1,prof_junk+runnumber*N_prof_var);
