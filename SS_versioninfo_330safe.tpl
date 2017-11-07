DATA_SECTION
!!// Stock Synthesis
!!// Developed by Richard Methot, NOAA Fisheries

!!//  SS_Label_Section_1.0 #DATA_SECTION

!!//  SS_Label_Info_1.1.1  #Create string with version info
!!version_info+="#V3.30.08.04-safe;_2017_11_06;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.6";
!!version_info2+="#_user_support_available_at:NMFS.Stock.Synthesis@noaa.gov";
!!version_info3+="#_user_info_available_at:https://vlab.ncep.noaa.gov/group/stock-synthesis";


!!//  V3.30.01.13  fix problem with transition to linear growth in Richards growth function
!!//  V3.30.04.01  05/23/2017  convert 3.24 birthseason to 3.30 settlement_event; no mandatory I/O change
!!//  V3.30.04.02  05/30/2017  fix index issue in converter for MGparm seasonal effects and for retention in fleet >1

!!//  V3.30.05.02  06/28/2017  fix issue with settlement events in spawn_season
!!//  V3.30.06.01  07/12/2017  enhance capability and control of depletion fleet
!!//  V3.30.06.02  07/25/2017  implement fcast_specify_selex to fix problem&various other format ++
!!//  V3.30.07.01  08/07/2017  augment detailed_F input; augment SPR/YPR output profile
!!//  V3.30.07.02  08/15/2017  repair age-specific K; fix growth problem if settlement age >0
!!//  V3.30.08.01  08/29/2017  fix Nfleet1 erroneous usage, except in tag parameters, I/O change in forecast
!!//  V3.30.08.02  2017-09-26  minor fixes to env_data output and to rebuild.dat output
!!//  V3.30.08.03  2017-09-29  fix error in the new code for ss_summary.sso
!!//  V3.30.08.04  2017-11-06  VLAB #40546; fix forecast recruitment error when spawn_month>1