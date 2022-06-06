// SS_Label_file  #7. **SS_global.tpl**
// SS_Label_file  # - <div style="color: #ff0000">RUNTIME_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - not used by SS3
// SS_Label_file  # - <div style="color: #ff0000">TOP_OF_MAIN_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - revise some memory and array constraints
// SS_Label_file  # - <div style="color: #ff0000">GLOBALS_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - open some output files
// SS_Label_file  #     - create needed adstring_arrays for labels
// SS_Label_file  #     - create vector_vector arrays that are appended to in readdata
// SS_Label_file  #     - two functions included here in GLOBALS because need to be used in the DATA_SECTION:
// SS_Label_file  #         - <u>get_data_timing()</u> and   <u>create_timevary()</u>
// SS_Label_file  # - <div style="color: #ff0000">BETWEEN_PHASES_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - for F_method 2, convert F as scaling factors to F as parameters in designated phase
// SS_Label_file  # - <div style="color: #ff0000">FINAL_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - output *covar.sso*
// SS_Label_file  #     - set save_for_report to 1, then call: <u>setup_recdevs()</u>, <u>get_initial_conditions()</u>, <u>get_time_series()</u>, <u>evaluate_the_objective_function()</u>
// SS_Label_file  #
// SS_Label_file  #     - call benchmark and forecast if not already done in sdphase
// SS_Label_file  #     - <u>call Process_STDquant()</u> and <u>get_posteriors()</u>
// SS_Label_file  #     - write other reports using function calls: *cumreport.sso*, *ss_summary.sso*, *ss_rebuild.sso*, *SIS_table.sso*
// SS_Label_file  #     - call write_big_output() to produce *report.sso* and *compreport.sso*
// SS_Label_file  # - <div style="color: #ff0000">REPORT_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - produces *ss.rep*, but see write_big_output for the more complete *report.sso*
// SS_Label_file  #

//  SS_Label_Section_8 #RUNTIME_SECTION (not used in SS3)
RUNTIME_SECTION
//  {
//  maximum_function_evaluations 200, 200, 200, 200, 200, 200, 200, 2000;
//  convergence_criteria 100, 10, 1, 0.1, 1e-4, 1e-4, 1e-4, 1e-4;
//  }

//  SS_Label_Section_9 #TOP_OF_MAIN_SECTION
TOP_OF_MAIN_SECTION
//  {
//  SS_Label_Info_9.1 #Set array and gradient structure space
  arrmblsize = 200000000; // 2e8 = about 0.2 GB.
//  gradient_structure::set_GRADSTACK_BUFFER_SIZE(672647168);
  gradient_structure::set_GRADSTACK_BUFFER_SIZE(20000000); // 2e7 gets multiplied by the gradstack size (usually 48), to reach about 0.9 GB.
//  gradstack is not allocated unless needed by the model, but arrmblsize and cmpdif are allocated immediately
//  gradient_structure::set_CMPDIF_BUFFER_SIZE(500000000);
  gradient_structure::set_CMPDIF_BUFFER_SIZE(200000000); // 2e8 = about 0.2GB
  gradient_structure::set_MAX_NVAR_OFFSET(5000);
  gradient_structure::set_NUM_DEPENDENT_VARIABLES(10000);
  gradient_structure::set_MAX_DLINKS(10000000);

//  SS_Label_Info_9.2 #Set clock start time
  time(&start); //this is to see how long it takes to run
//  }

//  SS_Label_Section_10. #GLOBALS_SECTION
GLOBALS_SECTION
//  {
  #include <admodel.h>
  #include <time.h>
  #include <fvar.hpp>
  #include <vector>
  #include <iostream>
  #include <sstream>
  #include <sys/types.h>
  #include <sys/stat.h>
  time_t start, finish;
  long hour, minute, second;
  double elapsed_time;

//  SS_Label_Info_10.2 #Define some adstring variables
  adstring_array ParmLabel; // extendable array to hold the parameter labels
  adstring_array Parm_info; // extendable array to hold the parameter labels
  adstring_array SzFreq_units_label;
  adstring_array SzFreq_scale_label;
  adstring_array fleetname;
  adstring ssnew_pathname;
  adstring sso_pathname;
  adstring fleetnameread;
  adstring depletion_basis_label;
  adstring F_report_label;
  adstring SPR_report_label;
  adstring onenum(4);
  adstring onenum2(4);
  adstring anystring;
  adstring anystring2;
  adstring report_sso_filename;
  adstring MSY_name; // label describing what Do_MSY and MSY_units are being used

  adstring_array version_info;
  adstring_array version_info2;
  adstring_array Starter_Comments;
  adstring_array Data_Comments;
  adstring_array Control_Comments;
  adstring_array Forecast_Comments;
  adstring_array NumLbl; // label for numbers 1 to 199
  adstring_array NumLbl0; // label for numbers 0 to 198 (needed for ages)
  adstring_array GenderLbl; // gender label
  adstring_array GP_Lbl; // gender label
  adstring_array CRLF; // blank to terminate lines
  adstring_array pick_report_name; //  name of report
  adstring_array pick_report_use; //  X if used; 0 if not

//  SS_Label_Info_10.1 #Open output files using ofstream
  ofstream warning;
  ofstream echoinput;
  ofstream ParmTrace;
  ofstream report5; //  forecast-report
  ofstream report2; //  control.ss_new
  ofstream bodywtout;
  ofstream SS2out; // this is just a create
  ofstream SS_compout; // this is just a create
  ofstream report1; //  for data output files
  ofstream covarout;
  ofstream rebuilder;
  ofstream rebuild_dat;
  ofstream posts;
  ofstream der_posts;
  ofstream post_vecs;
  ofstream post_obj_func;
  ofstream SS_smry;
  ofstream SIS_table;
//  declare some entities that need global access
  std::stringstream warnstream;
  std::string usermsg;
  int ParCount;
  int timevary_parm_cnt;
  int N_warn = 0;
  int styr;
  int endyr;
  int YrMax;
  int nseas;
  int Ncycle;
  int seas_as_year;
  int special_flag = 0; //  for whenever I need one

//  SS_Label_Info_10.3  #start random number generator with seed based on time
  random_number_generator radm(long(time(&start)));

  std::vector<int> Parm_minmax;
  std::vector<dvector> catch_read;
  std::vector<dvector> Svy_data;
  std::vector<dvector> discdata;
  std::vector<dvector> mnwtdata1;
  std::vector<dvector> lendata;
  std::vector<dvector> Age_Data;
  std::vector<dvector> sizeAge_Data;
  std::vector<dvector> H4010_scale_vec_rd;
  std::vector<dvector> Fcast_InputCatch_list;
  std::vector<dvector> Fcast_Catch_Allocation_list;
  std::vector<dvector> env_temp;
  std::vector<dvector> WTage_in;
  std::vector<dvector> var_adjust_data;
  std::vector<dvector> lambda_change_data;
  std::vector<dvector> timevary_parm_rd;
  std::vector<ivector> timevary_def;
  std::vector<ivector> TwoD_AR_def;
  std::vector<ivector> TwoD_AR_def_rd;
  std::vector<ivector> reportdetail_list;
  std::vector<ivector> Fparm_loc;
  std::vector<dvector> F_Method_4_input;
  std::vector<int> Fparm_PH;
  ;
//  function in GLOBALS to do the timing setup in the data section

// SS_Label_Function xxxa write_message(string,int,int); output a message with an option to exit (when fatal)
  void write_message(std::string msg, int echo, int exitflag)
  {
  if (msg.length() > 0)
  {
    N_warn++;
    warning << N_warn << ": " << msg << endl;

    if (echo == 1)
    {
      if (exitflag == 1)
        echoinput << "Exit:  ";
      echoinput << msg << endl;
    }
    if (exitflag == 1)
    {
      cout << " Fatal Error:" << endl;
      cout << " -- " << msg << endl;
      cout << " Exiting SS3. " << endl;
      exit(1);
    }
  }
  }
// SS_Label_Function_xxxb write_warning(int,int); output a warning with an option to exit (when fatal)
  void write_warning(int echo, int exitflag)
  {
    std::string msg(warnstream.str());
	write_message(msg, echo, exitflag);
    warnstream.str("");
  }

// SS_Label_Function_xxxx  #get_data_timing()  called by readdata
  void get_data_timing(const dvector& to_process, const ivector& timing_constants, ivector i_result, dvector r_result, const dvector& seasdur, const dvector& subseasdur_delta, const dvector& azero_seas, const dvector& surveytime)
  {

  // r_result(1,3) will contain: real_month, data_timing_seas, data_timing_yr,
  // i_result(1,6) will contain y, t, s, f, ALK_time, use_midseas
  int f, s, subseas, y;
  double temp, temp1, month, data_timing_seas;
  //  timing_constants(1)=read_seas_mo;
  //  timing_constants(2)=nseas;
  //  timing_constants(3)=N_subseas;
  //  timing_constants(4)=mid_subseas;
  //  timing_constants(5)=styr;
  //  timing_constants(6)-endyr;

  y = int(to_process(1));
  month = fabs(to_process(2));
  f = abs(int(to_process(3)));
  if (timing_constants(1) == 1) // reading season
  {
    s = int(month);
    subseas = timing_constants(4); //  mid subseas
    if (surveytime(f) >= 0.)
    { //  fraction of season
      data_timing_seas = surveytime(f);
      i_result(6) = 1;
    }
    else
    { //  for fishing fleets;  use midseason and fishery catch
      data_timing_seas = 0.5;
      i_result(6) = -1; //  flag to use season-long fishery catch as the sample
    }
    month = 1.0 + azero_seas(s) * 12. + 12. * data_timing_seas * seasdur(s);
  }
  else //  reading month.fraction
  {
    if (surveytime(f) < 0) //  so a fishing fleet
    {
      if (month > 999)
      { // override to allow a fishing fleet to have explicit timing
        month -= 1000.;
        i_result(6) = 1;
      }
      else
      {
        i_result(6) = -1; //  flag to use season-long fishery catch as the sample
      }
    }
    else
    {
      i_result(6) = 1; //  explicit timing for all survey fleet obs
      if (month > 999)
      { // override to allow a fishing fleet to have explicit timing
        month -= 1000.;
      }
    }

    if (seas_as_year == 0)
    {
      if (month >= 13.0)
      {
	  warnstream << "Fatal error. month must be <13.0, end of year is 12.99, value read is: " << month;
	  write_warning(0, 1);
//        N_warn++;
//        cout << "fatal read error, see warning" << endl;
//        warning << N_warn << " Fatal error. month must be <13.0, end of year is 12.99, value read is: " << month << endl;
//        exit(1);
      }
      temp1 = max(0.00001, (month - 1.0) / 12.); //  month as fraction of year
      s = 1; // earlist possible seas;
      subseas = 1; //  earliest possible subseas in seas
      temp = subseasdur_delta(s); //  starting value
      while (temp <= temp1 + 1.0e-9)
      {
        if (subseas == timing_constants(3))
        {
          s++;
          subseas = 1;
        }
        else
        {
          subseas++;
        }
        temp += subseasdur_delta(s);
      }
      data_timing_seas = (temp1 - azero_seas(s)) / seasdur(s); //  remainder converted to fraction of season (and multiplied by seasdur when used)
    }
    else
    {
      temp1 = 0.5;
      month = 0.5 * seasdur(1) * 12.;
      s = 1;
      subseas = timing_constants(4);
      data_timing_seas = 0.5;
    }
  }

  // i_result(1,6) will contain y, t, s, f, ALK_time, use_midseas
  // r_result(1,3) will contain: real_month, data_timing_seas*use_midseas, data_timing_yr,
  //    t=styr+(y-styr)*nseas+s-1;
  //    ALK_time=(yr-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
  i_result(1) = y;
  i_result(2) = timing_constants(5) + (y - timing_constants(5)) * timing_constants(2) + s - 1; //  t
  i_result(3) = s;
  i_result(4) = f;

  if (seas_as_year == 0)
  {
    if (i_result(6) >= 0)
    {
      i_result(5) = (y - timing_constants(5)) * timing_constants(2) * timing_constants(3) + (s - 1) * timing_constants(3) + subseas; //  ALK_time
      // r_result(1,3) : real_month, data_timing_seas, data_timing_yr,
      r_result(1) = month;
      r_result(2) = data_timing_seas * i_result(6);
      r_result(3) = float(y) + (month - 1.) / 12.; //  year.fraction
    }
    else //  assign to midseason
    {
      i_result(5) = (y - timing_constants(5)) * timing_constants(2) * timing_constants(3) + (s - 1) * timing_constants(3) + timing_constants(4); //  ALK_time
      data_timing_seas = 0.5;
      month = 1.0 + azero_seas(s) * 12. + 12. * data_timing_seas * seasdur(s);
      r_result(1) = month;
      r_result(2) = data_timing_seas * i_result(6);
      r_result(3) = float(y) + (month - 1.) / 12.; //  year.fraction
    }
  }
  else
  {
    i_result(5) = (y - timing_constants(5)) * timing_constants(2) * timing_constants(3) + (s - 1) * timing_constants(3) + timing_constants(4); //  ALK_time
    r_result(1) = month;
    r_result(2) = data_timing_seas * i_result(6);
    r_result(3) = float(y) + 0.5; //  year.fraction
  }
  return;
  }

// SS_Label_Function_xxxx  #create_timevary()  called by readdata to create timevary parameters
  /*
   where:
   baseparm_list:           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_byyear:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   targettype:           integer with type of MGparm being worked on; analogous to 2*fleet in the selectivity section
   block_design_pass:       block design, if any, being used
   env_data_pass:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
   finish_starter:  End of starter file value
  */
  void create_timevary(dvector& baseparm_list, ivector& timevary_setup,
    ivector& timevary_byyear, int& autogen_timevary, const int& targettype,
    const ivector& block_design_pass, const dvector& env_data_pass, 
    int& N_parm_dev, const double& finish_starter)
  {
  //  where timevary_byyear is a selected column of a year x type matrix (e.g. timevary_MG) in read_control
  //  timevary_setup(1)=baseparm type;
  //  timevary_setup(2)=baseparm index;
  //  timevary_setup(3)=first timevary parm
  //  timevary_setup(4)=block or trend type
  //  timevary_setup(5)=block pattern
  //  timevary_setup(6)=env link type
  //  timevary_setup(7)=env variable
  //  timevary_setup(8)=dev vector used
  //  timevary_setup(9)=dev link type
  //  timevary_setup(10)=dev min year
  //  timevary_setup(11)=dev maxyear
  //  timevary_setup(12)=dev phase
  //  timevary_setup(13)=all parm index of baseparm
  //  timevary_setup(14)=continue_last dev
  echoinput << "baseparm: " << baseparm_list << endl;
  int j;
  int g;
  int y;
  int a; // int f;
  int k;
  int z;
  int Nblocks;
  j = timevary_setup(13); //  index of base in all parameters to get correct baseparm label
  if (baseparm_list(13) != 0) //  blocks or trends
  {
    z = baseparm_list(13); // specified block or trend definition
    timevary_setup(4) = z; //  block or trend type
    timevary_setup(5) = baseparm_list(14); //  block pattern
    if (z > 0) //  blocks with z as the block pattern
    {
      Nblocks = 0.5 * (block_design_pass.size());
      k = int(baseparm_list(14)); //  block method
      echoinput << "block pattern: " << z << " method " << k << " Nblocks: " << Nblocks << endl;

      g = 1; //  index to list of years in block design; will increment by 2 for begin-end of block
      for (a = 1; a <= Nblocks; a++) //  loop blocks for block pattern z
      {
        timevary_parm_cnt++;
        ParCount++;
        echoinput << " create parm for block " << a << endl;
        y = block_design_pass(g);
        timevary_byyear(y) = 1;
        sprintf(onenum, "%d", y);

        echoinput << " block method " << k << endl;
        switch (k)
        {
          case 0:
          {
            ParmLabel += ParmLabel(j) + "_BLK" + NumLbl(z) + "mult_" + onenum + CRLF(1);
            dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if (autogen_timevary >= 1) //  read
            {
              *(ad_comm::global_datafile) >> tempvec(1, 7);
              echoinput << "read timevary block parameter: " << tempvec << endl;
            }
            if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
            {
              tempvec.fill("{-10,10,0.,0.,5,6,4}");
              if (baseparm_list(1) <= 0.0)
              {
                warnstream << "cannot use multiplicative blocks for parameter with a negative lower bound;  exit " << endl
                        << baseparm_list(1) << " " << baseparm_list(2) << " " << baseparm_list(3) << endl;
                write_warning(0,1);
//                N_warn++;
//                warning << N_warn << " "
//                        << " cannot use multiplicative blocks for parameter with a negative lower bound;  exit " << endl
//                        << baseparm_list(1) << " " << baseparm_list(2) << " " << baseparm_list(3) << endl;
//                cout << "exit, see warning" << endl;
//                exit(1);
              }
              tempvec(1) = log(baseparm_list(1) / baseparm_list(3)); //  max negative change
              tempvec(2) = log(baseparm_list(2) / baseparm_list(3)); //  max positive change
              //              tempvec(5)=0.5*fmin(fabs(tempvec(1)),tempvec(2));   //  sd of normal prior
              tempvec(5) = (tempvec(2) - tempvec(1)) / 4.; //  range/4 to approx sd of normal prior
              echoinput << " autogen mult block: " << tempvec << endl;
            }
            timevary_parm_rd.push_back(tempvec);
            break;
          }
          case 1:
          {
            ParmLabel += ParmLabel(j) + "_BLK" + NumLbl(z) + "add_" + onenum + CRLF(1);
            dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if (autogen_timevary >= 1) //  read
            {
              *(ad_comm::global_datafile) >> tempvec(1, 7);
              echoinput << "read timevary block parameter: " << tempvec << endl;
            }
            if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
            {
              tempvec.fill("{-10,10,0.,0.,5,6,4}");
              tempvec(1) = baseparm_list(1) - baseparm_list(3); //  max negative change
              tempvec(2) = baseparm_list(2) - baseparm_list(3); //  max positive change
              tempvec(5) = (tempvec(2) - tempvec(1)) / 4.; //  range/4 to approx sd of normal prior
              echoinput << " autogen additive block: " << tempvec << endl;
            }
            timevary_parm_rd.push_back(tempvec);
            break;
          }
          case 2:
          {
            ParmLabel += ParmLabel(j) + "_BLK" + NumLbl(z) + "repl_" + onenum + CRLF(1);
            dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if (autogen_timevary >= 1) //  read
            {
              *(ad_comm::global_datafile) >> tempvec(1, 7);
              echoinput << "read timevary block parameter: " << tempvec << endl;
            }
            if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
            {
              for (int s = 1; s <= 7; s++)
                tempvec(s) = baseparm_list(s);
              if (finish_starter == 999)
              {
                double temp;
                temp = tempvec(5);
                tempvec(5) = tempvec(6);
                tempvec(6) = temp;
              }
              echoinput << "autogen block replace: " << tempvec << endl;
            }
            timevary_parm_rd.push_back(tempvec);
            break;
          }
          case 3:
          {
            ParmLabel += ParmLabel(j) + "_BLK" + NumLbl(z) + "delta_" + onenum + CRLF(1);
            dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if (autogen_timevary >= 1) //  read
            {
              *(ad_comm::global_datafile) >> tempvec(1, 7);
              echoinput << " read timevary block parm: " << tempvec << endl;
            }
            if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
            {
              tempvec.fill("{-10,10,0.,0.,5,6,4}");
              tempvec(1) = baseparm_list(1) - baseparm_list(3); //  max negative change
              tempvec(2) = baseparm_list(2) - baseparm_list(3); //  max positive change
              tempvec(5) = (tempvec(2) - tempvec(1)) / 4.; //  range/4 to approx sd of normal prior
              echoinput << " autogen block delta: " << tempvec << endl;
            }
            timevary_parm_rd.push_back(tempvec);
            break;
          }
        }
        y = block_design_pass(g + 1) + 1; // first year after block
        if (y <= YrMax)
          timevary_byyear(y) = 1;
        if (targettype == 7 && timevary_setup(1) == 1) //  so doing catch_mult which needs annual values calculated for each year of the block
        {
          for (int z = block_design_pass(g); z <= y; z++) //  where y has end year of block + 1
          {
            timevary_byyear(z) = 1;
          }
        }
        g += 2;
      }
    }
    else //  (z<0) so invoke a trend
    {
      echoinput << "trend " << endl;
      if (baseparm_list(13) == -1)
      {
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendFinal_LogstOffset" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendInfl_LogstOffset" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendWidth_yrs_" + CRLF(1);
        for (k = 1; k <= 3; k++) //  for the 3 trend parameters
        {
          timevary_parm_cnt++;
          dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
          tempvec.initialize();
          if (autogen_timevary >= 1) //  read
          {
            *(ad_comm::global_datafile) >> tempvec(1, 7);
          }
          if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
          {
            if (k == 1)
            {
              tempvec.fill("{-4.0,4.0,0.,0.,0.5,6,4}");
            }
            if (k == 2)
            {
              tempvec.fill("{-4.0,4.0,0.,0.,0.5,6,4}");
            }
            if (k == 3)
            {
              tempvec.fill("{1.0,20.0,3.,3.,3.0,6,4}");
            }
          }
          timevary_parm_rd.push_back(tempvec);
        }
      }
      else if (baseparm_list(13) == -2)
      {
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendFinal_direct_" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendInfl_yr_" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendWidth_yr_" + CRLF(1);
        for (k = 1; k <= 3; k++) //  for the 3 trend parameters
        {
          timevary_parm_cnt++;
          dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
          tempvec.initialize();
          if (autogen_timevary >= 1) //  read
          {
            *(ad_comm::global_datafile) >> tempvec(1, 7);
          }
          if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
          {
            if (k == 1)
            {
              for (a = 1; a <= 7; a++)
                tempvec(a) = baseparm_list(a);
            }
            if (k == 2)
            {
              tempvec.fill("{-2.0,2.0,0.,0.,0.5,6,4}");
              tempvec(1) = styr;
              tempvec(2) = endyr;
              tempvec(3) = (styr + endyr) * 0.5;
              tempvec(4) = tempvec(3);
            }
            if (k == 3)
            {
              tempvec.fill("{1.0,20.0,3.,3.,3.0,6,4}");
            }
          }
          timevary_parm_rd.push_back(tempvec);
        }
      }
      else if (baseparm_list(13) == -3)
      {
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendFinal_frac_" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendInfl_frac_" + CRLF(1);
        ParCount++;
        ParmLabel += ParmLabel(j) + "_TrendWidth_yr_" + CRLF(1);
        for (k = 1; k <= 3; k++) //  for the 3 trend parameters
        {
          timevary_parm_cnt++;
          dvector tempvec(1, 7); //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
          tempvec.initialize();
          if (autogen_timevary >= 1) //  read
          {
            *(ad_comm::global_datafile) >> tempvec(1, 7);
          }
          if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
          {
            if (k == 1)
            {
              tempvec.fill("{0.0001,0.999,0.,0.,0.5,6,4}");
              tempvec(3) = (baseparm_list(3) - baseparm_list(1)) / (baseparm_list(2) - baseparm_list(1));
              tempvec(4) = tempvec(3);
            }
            if (k == 2)
            {
              tempvec.fill("{0.0001,0.999,0.5,0.5,0.5,6,4}");
            }
            if (k == 3)
            {
              tempvec.fill("{1.0,20.0,3.,3.,3.,6,4}");
            }
          }
          timevary_parm_rd.push_back(tempvec);
        }
      }
      else
      {
        for (int icycle = 1; icycle <= Ncycle; icycle++)
        {
          ParCount++;
          ParmLabel += ParmLabel(j) + "_Cycle_" + NumLbl(icycle) + CRLF(1);
          timevary_parm_cnt += 1; //  count the cycle parameters
        }
      }
      for (y = styr - 1; y <= YrMax; y++)
      {
        timevary_byyear(y) = 1;
      } //  all years need calculation for trends
    }
  }

  if (baseparm_list(8) != 0) //  env effect is used
  {
    k = timevary_setup(6);
    //      if(timevary_setup(7)==99) timevary_setup(7)=-1;  //  for linking to rel_spawn biomass
    //      if(timevary_setup(7)==98) timevary_setup(7)=-2;  //  for linking to exp(recdev)
    //      if(timevary_setup(7)==97) timevary_setup(7)=-3;  //  for linking to rel_smrybio
    //      if(timevary_setup(7)==96) timevary_setup(7)=-4;  //  for linking to rel_smry_num
    echoinput << "env link_type: " << k << " env_var: " << timevary_setup(7) << endl;
    switch (k)
    {
      case 1: //  multiplicative
      {
        echoinput << " do env mult for parm: " << j << " " << ParmLabel(j) << endl;
        ParCount++;
        ParmLabel += ParmLabel(j) + "_ENV_mult";
        timevary_parm_cnt++;
        dvector tempvec(1, 7);
        tempvec.initialize();
        if (autogen_timevary >= 1) //  read
        {
          *(ad_comm::global_datafile) >> tempvec(1, 7);
        }
        if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
        {
          tempvec.fill("{-10.,10.0,1.0,1.0,0.5,6,4}");
        }
        timevary_parm_rd.push_back(tempvec(1, 7));
        break;
      }
      case 2: //  additive
      {
        echoinput << " do env additive " << endl;
        ParCount++;
        ParmLabel += ParmLabel(j) + "_ENV_add";
        timevary_parm_cnt++;
        dvector tempvec(1, 7);
        tempvec.initialize();
        if (autogen_timevary >= 1) //  read
        {
          *(ad_comm::global_datafile) >> tempvec(1, 7);
        }
        if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
        {
          tempvec.fill("{-10.,10.0,1.0,1.0,0.5,6,4}");
        }
        timevary_parm_rd.push_back(tempvec(1, 7));
        break;
      }
      case 3: //  additive in logistic space to stay in min-max bounds
      {
        echoinput << " do env constrained " << endl;
        ParCount++;
        ParmLabel += ParmLabel(j) + "_ENV_add_constr";
        timevary_parm_cnt++;
        dvector tempvec(1, 7);
        tempvec.initialize();
        if (autogen_timevary >= 1) //  read
        {
          *(ad_comm::global_datafile) >> tempvec(1, 7);
        }
        if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
        {
          tempvec.fill("{-1.8,1.8,1.0,1.0,0.5,6,4}");
        }
        timevary_parm_rd.push_back(tempvec(1, 7));
        break;
      }
      case 4: //  logistic with offset
      {
        ParCount++;
        ParmLabel += ParmLabel(j) + "_ENV_offset";
        timevary_parm_cnt++;
        dvector tempvec(1, 7);
        tempvec.initialize();
        if (autogen_timevary >= 1) //  read
        {
          *(ad_comm::global_datafile) >> tempvec(1, 7);
        }
        if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
        {
          tempvec.fill("{-0.9,0.9,0.0,0.0,0.5,6,4}");
        }
        timevary_parm_rd.push_back(tempvec(1, 7));
        ParCount++;
        ParmLabel += ParmLabel(j) + "_ENV_lgst_slope";
        timevary_parm_cnt++;
        tempvec.initialize();
        if (autogen_timevary >= 1) //  read
        {
          *(ad_comm::global_datafile) >> tempvec(1, 7);
        }
        if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
        {
          tempvec.fill("{-0.9,0.9,0.0,0.0,0.5,6,4}");
        }
        timevary_parm_rd.push_back(tempvec(1, 7));
        break;
      }
    }
    {
      if (timevary_setup(7) > 0)
      {
        timevary_byyear(env_data_pass(1), env_data_pass(2) + 1) = 1;
      }
      else if (timevary_setup(7) < 0) //  density-dependence being used
      {
        timevary_byyear(styr, YrMax) = 1;
      }
    }
  }

  if (baseparm_list(9) > 0) //  devs are used
  {
    N_parm_dev++; //  count of dev vectors that are used
    timevary_setup(8) = N_parm_dev; //    specifies which dev vector will be used by a parameter
    timevary_setup(9) = baseparm_list(9); //   code for dev link type
    y = baseparm_list(10);
    if (y < styr)
    {
      warnstream << "reset parm_dev start year to styr for parm: " << j << " " << y;
      write_warning(0,0);
//      N_warn++;
//      warning << N_warn << " "
//              << " reset parm_dev start year to styr for parm: " << j << " " << y << endl;
      y = styr;
    }
    timevary_setup(10) = y;

    y = baseparm_list(11);
    if (y > YrMax)
    {
	  warnstream << " reset parm_dev end year to YrMax for parm: " << j << " " << y;
	  write_warning(0,0);
//      N_warn++;
//      warning << N_warn << " "
//              << " reset parm_dev end year to YrMax for parm: " << j << " " << y << endl;
      y = YrMax;
    }
    timevary_setup(11) = y;
    for (y = timevary_setup(10); y <= timevary_setup(11) + 1; y++)
    {
      timevary_byyear(y) = 1;
    }

    ParCount++;
    ParmLabel += ParmLabel(j) + "_dev_se" + CRLF(1);
    timevary_parm_cnt++;
    dvector tempvec(1, 7);
    tempvec.initialize();
    if (autogen_timevary >= 1) //  read
    {
      *(ad_comm::global_datafile) >> tempvec(1, 7);
    }
    timevary_setup(12) = baseparm_list(12); //  dev phase
    echoinput << "parameter dev vector created with phase set to: " << timevary_setup(12) << endl;
    if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec(1) == -12345)) //  create or overwrite
    {
      tempvec.fill("{0.0001,2.0,0.5,0.5,0.5,6,-5}");
      if (finish_starter == 999)
      {
        tempvec(3) = baseparm_list(12); //  set init to value on the 3.24 format base parameter line
        tempvec(4) = baseparm_list(12); //  set prior
      }
      //       timevary_setup(12)=-5;  //  set reasonable phase for devs;
      //       baseparm_list(12)=-5;
    }
    timevary_parm_rd.push_back(dvector(tempvec(1, 7)));

    ParCount++;
    ParmLabel += ParmLabel(j) + "_dev_autocorr" + CRLF(1);
    timevary_parm_cnt++;
    dvector tempvec2(1, 7);
    tempvec2.initialize();
    if (autogen_timevary >= 1)
    {
      *(ad_comm::global_datafile) >> tempvec2(1, 7);
    } // read
    if (autogen_timevary == 0 || (autogen_timevary == 2 && tempvec2(1) == -12345)) //  create or overwrite
    {
      tempvec2.fill("{-0.99,0.99,0.0,0.0,0.5,6,-6}");
    }
    timevary_parm_rd.push_back(dvector(tempvec2(1, 7)));
    echoinput << "dev vec: " << timevary_setup(8) << " with link: " << timevary_setup(9) << " min, max year " << timevary_setup(10, 11) << endl;
  }
  echoinput << "timevary_setup" << timevary_setup << endl;
  return;
  }
  
//  }  //  end GLOBALS_SECTION

//  SS_Label_Section_11. #BETWEEN_PHASES_SECTION
BETWEEN_PHASES_SECTION
  {
  int j_phase = current_phase(); // this is the phase to come
  cout << current_phase() - 1 << " " << niter << " -log(L): " << obj_fun << "  between " << endl;

  //  SS_Label_Info_11.1 #Save last value of objective function
  if (j_phase > 1)
  {
    last_objfun = obj_fun;
  }

  //  SS_Label_Info_11.2 #For Fmethod=2 & 4, set parameter values (F_rate) equal to Hrate array fromcalculated using hybrid method in previous phase
  if (N_Fparm > 0 && j_phase > 1)
  {
    for (int ff = 1; ff <= N_catchfleets(0); ff++)
    {
      f = fish_fleet_area(0, ff);
      if (F_Method_byPH(f, j_phase) < F_Method_byPH(f, j_phase - 1))
      {
        for (g = Fparm_loc_st(f); g <= Fparm_loc_end(f); g++)
        {
          t = Fparm_loc[g](2);
          F_rate(g) = Hrate(f, t);
        }
      }
    }
  }
  //        warning<<"between: Hrate_2010:  "<<Hrate(1,2010)<<" "<<Hrate(2,2010)<<" "<<Hrate(3,2010)<<" "<<Hrate(4,2010)<<" "<<endl;

  } //  end BETWEEN_PHASES_SECTION

//  SS_Label_Section_12. #FINAL_SECTION
FINAL_SECTION
  {
  //  SS_Label_Info_12.1 #Get run ending time
  time(&finish);
  elapsed_time = difftime(finish, start);
  hour = long(elapsed_time) / 3600;
  minute = long(elapsed_time) % 3600 / 60;
  second = (long(elapsed_time) % 3600) % 60;
  cout << endl
       << "In final section " << endl;
  cout << "Finish time: " << ctime(&finish);
  cout << "Elapsed time: ";
  cout << hour << " hours, " << minute << " minutes, " << second << " seconds." << endl;

  if (No_Report == 1)
  {
    cout << "MCMC finished; *.ss_new files and most .sso not written after MCMC or MCEVAL" << endl;
  }

  else
  {
    cout << " Iterations: " << niter << " -log(L): " << obj_fun << endl;
    cout << "Final gradient: " << objective_function_value::pobjfun->gmax << endl
         << endl;
    if (objective_function_value::pobjfun->gmax > final_conv)
    {
      warnstream << "Final gradient: " << objective_function_value::pobjfun->gmax << " is larger than final_conv: " << final_conv;
	  write_warning(0, 0);
    }

    //  SS_Label_Info_12.2 #Output the covariance matrix to covar.sso
    anystring = sso_pathname + "covar.sso";
    covarout.open(anystring);
    covarout << version_info << endl;
    covarout << "start_time: " << ctime(&start) << endl;
    covarout << active_parms << " " << CoVar_Count << endl;
    covarout << "active-i active-j all-i all-j Par?-i Par?-j label-i label-j corr" << endl;
    if (CoVar(1, 1) == 0.00 && CoVar(2, 2) == 0.0)
    {
      covarout << "Variances are 0.0 for first two elements, so do not write " << endl;
    }
    else
    {
      for (i = 1; i <= CoVar_Count; i++)
      {
        covarout << i << " " << 0 << " " << active_parm(i) << " " << active_parm(i);
        if (i <= active_parms)
        {
          covarout << " Par ";
        }
        else
        {
          covarout << " Der ";
        }
        covarout << " Std " << ParmLabel(active_parm(i)) << "   _   " << CoVar(i, 1) << endl;
        for (j = 2; j <= i; j++)
        {
          covarout << i << " " << j - 1 << " " << active_parm(i) << " " << active_parm(j - 1);
          if (i <= active_parms)
          {
            covarout << " Par ";
          }
          else
          {
            covarout << " Der ";
          }
          if ((j - 1) <= active_parms)
          {
            covarout << " Par ";
          }
          else
          {
            covarout << " Der ";
          }
          covarout << ParmLabel(active_parm(i)) << " " << ParmLabel(active_parm(j - 1)) << " " << CoVar(i, j) << endl;
        }
      }
      if (mceval_phase() == 0)
        cout << " finished COVAR.SSO" << endl;
    }

    //  SS_Label_Info_12.3 #Go thru time series calculations again to get extra output quantities
    //  SS_Label_Info_12.3.2 #Set save_for_report=1 then call initial_conditions and time_series to get other output quantities
    if (Do_Dyn_Bzero > 0) //  do dynamic Bzero
    {
      save_gparm = 0;
      fishery_on_off = 0;
      setup_recdevs();
      y = styr;
      get_initial_conditions();
      get_time_series();
      if (Do_Forecast > 0)
      {
        show_MSY = 0;
        Get_Forecast();
      }
      k = Do_Dyn_Bzero;
      for (j = styr - 2; j <= YrMax; j++)
      {
        Extra_Std(k) = SSB_yr(j);
        k++;
      }
      if (More_Std_Input(12) == 2)
      {
        for (j = styr - 2; j <= YrMax; j++)
        {
          Extra_Std(k) = exp_rec(j, 4);
          k++;
        }
      }
    } //  end dynamic Bzero

    fishery_on_off = 1;
    save_for_report = 1;
    bigsaver = 1;
    save_gparm = 0;
    if (SDmode == 0 && pick_report_use(60) == "Y")
      write_bodywt = 1; //  turn on conditional on SDMode because SDMode=1 situation already written
    y = styr;
    setup_recdevs();
    get_initial_conditions();
    get_time_series(); //  in final_section with save_for_report on
    evaluate_the_objective_function();
    //  SS_Label_Info_12.3.3 #Do benchmarks and forecast and stdquantities with save_for_report=1
    if (mceval_phase() == 0)
    {
      show_MSY = 1;
    }
    else
    {
      show_MSY = 0;
    } //  turn on reporting if not in mceval
    if (pick_report_use(60) == "Y")
    {
      write_bodywt = 1;
    } //  turn on bodywt after time series
    setup_Benchmark(); //  calculates biology and selectivity to be used
    if (Do_Benchmark > 0)
    {
      if (did_MSY == 0)
      {
        Get_Benchmarks(show_MSY);
        if (mceval_phase() == 0)
          cout << " finished benchmark" << endl;
      }
    }
    if (Do_Forecast >= 0)
    {
      report5 << "THIS FORECAST FOR PURPOSES OF GETTING DISPLAY QUANTITIES" << endl;
      if (did_MSY > 0)
        show_MSY = 0; //  so to not repeat forecast_report.sso
      Get_Forecast();
      if (mceval_phase() == 0)
        cout << " finished forecast" << endl;
    }

    if (write_bodywt > 0)
    {
      bodywtout << -9999 << " " << 1 << " " << 1 << " " << 1 << " " << 1 << " " << 0 << " " << Wt_Age_mid(1, 1) << " #terminator " << endl;
      bodywtout.close();
    }
    write_bodywt = 0;

    //  SS_Label_Info_12.3.4  #call fxn STDquant()
    Process_STDquant();
    if (mceval_phase() == 0)
      cout << " finished StdDev quantities" << endl;
    get_posteriors();
    if (mceval_phase() == 0)
      cout << " finished posteriors" << endl;

    //  SS_Label_Info_12.4.2 #Call fxn write_summaryoutput()
    if (Do_CumReport > 0)
      write_summaryoutput();

    if (pick_report_use(56) == "Y")
    {
      write_SS_summary();
    }

    //  SS_Label_Info_12.4.3 #Call fxn write_rebuilder_output to produce rebuilder.sso
    {
      if (pick_report_use(57) == "Y" && Do_Rebuilder == 1 && mceval_counter <= 1)
      {
        write_rebuilder_output();
      }

      if (pick_report_use(58) == "Y")
      {
        write_SIStable(); //note: SIStable is deprecated, but file with warning written for now
      }

      //  SS_Label_Info_12.4 #Do Outputs
      //  SS_Label_Info_12.4.1 #Call fxn write_bigoutput()
      write_bigoutput();
      cout << " finished report.sso" << endl;
    }
    //  SS_Label_Info_12.4.4 #Call fxn write_nudata() to create bootstrap data
    if (N_nudata > 0)
    {
      cout << "Creating bootstrap files: " << N_nudata << " files";
      write_nudata();
      cout << " finished" << endl;

      //  SS_Label_Info_12.4.5 #Call fxn write_nucontrol() to produce control.ss_new
      write_nucontrol();
    }
    else
    {
      {
        warnstream << "NOTE:  No *.ss_new and fewer *.sso files written after mceval";
		write_warning(0, 0);
      }
    }

    //  SS_Label_Info_12.4.6 #Call fxn write_Bzero_output()  appended to report.sso
    if (pick_report_use(59) == "Y")
    {
      cout << "dynamic Bzero in FINAL_SECTION: ";
      write_Bzero_output();
      cout << " finished " << endl;
    }

    if (pick_report_use(54) == "Y" && Do_Benchmark > 0)
    {
      cout << "setup_benchmark: " << endl;
      setup_Benchmark();
      cout << "SPR_profile: ";
      SPR_profile();
      cout << " finished " << endl;
    }

    if (pick_report_use(55) == "Y" && Do_Benchmark > 0)
    {
      cout << "Global_MSY: ";
      Global_MSY();
      cout << " finished " << endl;
    }

    if (parm_adjust_method == 3)
    {
      warnstream << "Time-vary parms not bound checked";
	  write_warning(0, 0);
    }

    //  SS_Label_Info_12.4.7 #Finish up with final writes to warning.sso
    if (N_changed_lambdas > 0)
    {
      warnstream << "Reminder: Number of lamdas !=0.0 and !=1.0:  " << N_changed_lambdas;
	  write_warning(0, 0);
    }

    if (Nparm_on_bound > 0)
    {
      cout << Nparm_on_bound << " parameters are on or within 1% of min-max bound" << endl;
      warning << " N parameters are on or within 1% of min-max bound: " << Nparm_on_bound << "; check results, variance may be suspect" << endl;
    }
    warning << "N warnings: " << N_warn << endl;
    cout << endl
         << "!!  Run has completed  !!            ";
    if (N_warn > 0)
    {
      cout << "See warning.sso for N warnings: " << N_warn << endl;
    }
    else
    {
      cout << "No warnings :)" << endl;
    }
  }
  } //  end final section

//  SS_Label_Section_13. #REPORT_SECTION  produces SS3.rep,which is less extensive than report.sso produced in final section
REPORT_SECTION
  {
  int k = gradients.size();
  int k1 = parm_gradients.size();
  if (k1 < k)
    k = k1;
  for (int i = 1; i <= k; i++)
    parm_gradients(i) = gradients(i);
  if (current_phase() >= max_phase && finished_minimize == 0)
    finished_minimize = 1; //  because REPORT occurs after minimize finished
  //  SS_Label_Info_13.1 #Write limited output to SS.rep
  if (reportdetail > 0)
  {
    if (Svy_N > 0)
      report << " CPUE " << surv_like << endl;
    if (nobs_disc > 0)
      report << " Disc " << disc_like << endl;
    if (nobs_mnwt > 0)
      report << " MnWt " << mnwt_like << endl;
    if (Nobs_l_tot > 0)
      report << " LEN  " << length_like_tot << endl;
    if (Nobs_a_tot > 0)
      report << " AGE  " << age_like_tot << endl;
    if (nobs_ms_tot > 0)
      report << " L-at-A  " << sizeage_like << endl;
    report << " EQUL " << equ_catch_like << endl;
    report << " Recr " << recr_like << endl;
    report << " Parm " << parm_like << endl;
    report << " F_ballpark " << F_ballpark_like << endl;
    if (F_Method > 1)
    {
      report << "Catch " << catch_like << endl;
    }
    else
    {
      report << "  crash " << CrashPen << endl;
    }
    if (SzFreq_Nmeth > 0)
      report << " sizefreq " << SzFreq_like << endl;
    if (Do_TG > 0)
      report << " TG-fleetcomp " << TG_like1 << endl
             << " TG-negbin " << TG_like2 << endl;
    report << " -log(L): " << obj_fun << "  Spbio: " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr)) << endl;

    report << endl
           << "Year Spbio Recruitment" << endl;
    report << "Virg " << SSB_yr(styr - 2) << " " << exp_rec(styr - 2, 4) << endl;
    report << "Init " << SSB_yr(styr - 1) << " " << exp_rec(styr - 1, 4) << endl;
    for (y = styr; y <= endyr; y++)
      report << y << " " << SSB_yr(y) << " " << exp_rec(y, 4) << endl;

    report << endl
           << "EXPLOITATION F_Method: ";
    if (F_Method == 1)
    {
      report << " Pope's_approx ";
    }
    else
    {
      report << " instantaneous_annual_F ";
    }
    report << endl
           << "X Catch_Units ";
    for (f = 1; f <= Nfleet; f++)
      if (catchunits(f) == 1)
      {
        report << " Bio ";
      }
      else
      {
        report << " Num ";
      }
    report << endl
           << "Yr Seas";
    for (f = 1; f <= Nfleet; f++)
      report << " " << f;
    report << endl
           << "init_yr 1 ";
    for (s = 1; s <= nseas; s++)
      for (f = 1; f <= Nfleet; f++)
      {
        if (init_F_loc(s, f) > 0)
        {
          report << " " << init_F(init_F_loc(s, f));
        }
        else
        {
          report << " NA ";
        }
      }
    report << endl;
    for (y = styr; y <= endyr; y++)
      for (s = 1; s <= nseas; s++)
      {
        t = styr + (y - styr) * nseas + s - 1;
        report << y << " " << s << " " << column(Hrate, t) << endl;
      }

    report << endl
           << "LEN_SELEX" << endl;
    report << "Fleet Sex " << len_bins_m << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (seltype(f, 1) > 0)
      {
        for (gg = 1; gg <= gender; gg++)
          report << f << "-" << fleetname(f) << gg << " " << sel_l(endyr, f, gg) << endl;
      }
    }

    report << endl
           << "AGE_SELEX" << endl;
    report << "Fleet Sex " << age_vector << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (seltype(f + Nfleet, 1) > 10)
      {
        for (gg = 1; gg <= gender; gg++)
          report << f << "-" << fleetname(f) << " " << gg << " " << sel_a(endyr, f, gg) << endl;
      }
    }
  }

  //  SS_Label_Info_13.2 #Call fxn write_bigoutput() as last_phase finishes and before doing Hessian
  if (last_phase() && SDmode == 1)
  {
    if (pick_report_use(60) == "Y")
    {
      write_bodywt = 1;
    }
    save_for_report = 1;
    save_gparm = 0;
    y = styr;
    setup_recdevs();
    get_initial_conditions();
    get_time_series(); //  in ADMB's report_section
    evaluate_the_objective_function();
    write_bigoutput();
    cout << "Wrote bigoutput and bodywt for last_phase in REPORT_SECTION and before hessian, no benchmark or forecast " << endl;
    save_for_report = 0;
    write_bodywt = 0;
    //    SS2out.close();
  }
  } //  end standard report section

