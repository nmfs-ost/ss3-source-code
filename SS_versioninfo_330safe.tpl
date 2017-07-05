DATA_SECTION
!!// Stock Synthesis
!!// Developed by Richard Methot, NOAA Fisheries

!!//  SS_Label_Section_1.0 #DATA_SECTION

!!//  SS_Label_Info_1.1.1  #Create string with version info
!!version_info+= "SS-V3.30.05.03-safe;_2017_07_05;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.6";
!!version_info2+="SS-V3.30.05.03-safe;user_support_available_at:NMFS.Stock.Synthesis@noaa.gov";
!!version_info3+="SS-V3.30.05.03-safe;user_info_available_at:https://vlab.ncep.noaa.gov/group/stock-synthesis";
!!version_info_short+="#V3.30.05.03";

!!//  V3.30.01.13  fix problem with transition to linear growth in Richards growth function
!!//  V3.30.04.01  05/23/2017  convert 3.24 birthseason to 3.30 settlement_event; no mandatory I/O change
!!//  V3.30.04.02  05/30/2017  fix index issue in converter for MGparm seasonal effects and for retention in fleet >1

!!//  V3.30.05.02  06/28/2017  fix issue with settlement events in spawn_season
