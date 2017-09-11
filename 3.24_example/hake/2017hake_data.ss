#C 2017 Hake data file
###################################################

### Global model specifications ###
1966    # Start year
2016    # End year
1       # Number of seasons/year
12      # Number of months/season
1       # Spawning occurs at beginning of season
1       # Number of fishing fleets
1       # Number of surveys
1       # Number of areas
Fishery%Acoustic_Survey
0.5 0.5 # fleet timing_in_season
1 1     # Area of each fleet
1       # Units for catch by fishing fleet: 1=Biomass(mt),2=Numbers(1000s)
0.01    # SE of log(catch) by fleet for equilibrium and continuous options
1       # Number of genders
20      # Number of ages in population dynamics

### Catch section ###
0  # Initial equilibrium catch (landings + discard) by fishing fleet

51 # Number of lines of catch
# Catch  Year    Season
137700	1966	1
214370	1967	1
122180	1968	1
180130	1969	1
234590	1970	1
154620	1971	1
117540	1972	1
162640	1973	1
211260	1974	1
221350	1975	1
237520	1976	1
132690	1977	1
103637	1978	1
137110	1979	1
89930	1980	1
139120	1981	1
107741	1982	1
113931	1983	1
138492	1984	1
110399	1985	1
210616	1986	1
234148	1987	1
248840	1988	1
298079	1989	1
261286	1990	1
319705	1991	1
299650	1992	1
198905	1993	1
362407	1994	1
249495	1995	1
306299	1996	1
325147	1997	1
320722	1998	1
311887	1999	1
228777	2000	1
227525	2001	1
180697	2002	1
205162	2003	1
342307	2004	1
363135	2005	1
361699	2006	1
293389	2007	1
321802	2008	1
177171	2009	1
230755	2010	1
291670	2011	1
205787	2012	1
285591	2013	1
298705	2014	1
190663	2015	1
329427	2016	1


22 # Number of index observations
# Units: 0=numbers,1=biomass,2=F; Errortype: -1=normal,0=lognormal,>0=T
# Fleet Units Errortype
1 1 0 # Fishery
2 1 0 # Acoustic Survey

# Acoustic survey  (all years updated with new acoustic team extrapolation analysis; 1995 unavailabe with new analysis)
# Year  seas    fleet   obs       se(log)
1995    1       2       1318035   0.0893
1996    1       -2      1         1
1997    1       -2      1         1
1998    1       2       1569148   0.0479
1999    1       -2      1         1
2000    1       -2      1         1
2001    1       2       861744    0.1059
2002    1       -2      1         1
2003    1       2       2137528   0.0642
2004    1       -2      1         1
2005    1       2       1376099   0.0638
2006    1       -2      1         1
2007    1       2       942721    0.0766
2008    1       -2      1         1
2009    1       2       1502273   0.0995
2010    1       -2      1         1
2011    1       2       674617    0.1177
2012    1       2       1279421   0.0673
2013    1       2       1929235   0.0646
2014    1       -2      1         1
2015    1       2       2155853   0.0829
2016    1       -2      1         1



0  #_N_fleets_with_discard
0  #_N_discard_obs
0  #_N_meanbodywt_obs
30 #_DF_for_meanbodywt_T-distribution_like

## Population size structure
2  # Length bin method: 1=use databins; 2=generate from binwidth,min,max below;
2  # Population length bin width
10 # Minimum size bin
70 # Maximum size bin

-1      # Minimum proportion for compressing tails of observed compositional data
0.001   # Constant added to expected frequencies
0       # Combine males and females at and below this bin number

26 # Number of Data Length Bins
# Lower edge of bins
20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70
0 #_N_Length_obs

15 #_N_age_bins
# Age bins
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

44 # N_ageerror_definitions
# No ageing error
#0.5    1.5     2.5     3.5     4.5     5.5     6.5     7.5     8.5     9.5     10.5    11.5    12.5    13.5    14.5    15.5    16.5    17.5    18.5    19.5    20.5
#0.001  0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001   0.001
# Baseline ageing error
#0.5    1.5     2.5     3.5     4.5     5.5     6.5     7.5     8.5     9.5     10.5    11.5    12.5    13.5    14.5    15.5    16.5    17.5    18.5    19.5    20.5
#0.329  0.329   0.347   0.369   0.395   0.428   0.468   0.518   0.579   0.653   0.745   0.858   0.996   1.167   1.376   1.632   1.858   2.172   2.530   2.934   3.388
# Annual keys with cohort effect
#
# NOTE: no adjustment for 2008, full adjustment for 2010
#
#age0      age1       age2       age3       age4       age5       age6       age7       age8       age9       age10      age11      age12      age13      age14      age15      age16      age17      age18      age19      age20      yr         def        comment
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1973     def1       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1973     def1       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1974     def2       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1974     def2       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1975     def3       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1975     def3       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1976     def4       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1976     def4       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1977     def5       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1977     def5       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1978     def6       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1978     def6       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1979     def7       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1979     def7       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1980     def8       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1980     def8       SD of age. 
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1981     def9       Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1981     def9       SD of age. 0.55*age1
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1982     def10      Expected ages
0.329242   0.329242   0.19080435 0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1982     def10      SD of age. 0.55*age2
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1983     def11      Expected ages
0.329242   0.329242   0.346917   0.2027476  0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1983     def11      SD of age. 0.55*age3
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1984     def12      Expected ages
0.329242   0.329242   0.346917   0.368632   0.2174216  0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1984     def12      SD of age. 0.55*age4
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1985     def13      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.2354495  0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1985     def13      SD of age. 0.55*age1, 0.55*age5
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1986     def14      Expected ages
0.329242   0.329242   0.19080435 0.368632   0.395312   0.42809    0.2575991  0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1986     def14      SD of age. 0.55*age2, 0.55*age6
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1987     def15      Expected ages
0.329242   0.329242   0.346917   0.2027476  0.395312   0.42809    0.468362   0.28481255 0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1987     def15      SD of age. 0.55*age3, 0.55*age7
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1988     def16      Expected ages
0.329242   0.329242   0.346917   0.368632   0.2174216  0.42809    0.468362   0.517841   0.3182465  0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1988     def16      SD of age. 0.55*age4, 0.55*age8
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1989     def17      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.2354495  0.468362   0.517841   0.57863    0.3593238  0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1989     def17      SD of age. 0.55*age5, 0.55*age9
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1990     def18      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.2575991  0.517841   0.57863    0.653316   0.4097918  0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1990     def18      SD of age. 0.55*age6, 0.55*age10
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1991     def19      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.28481255 0.57863    0.653316   0.745076   0.47179715 0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1991     def19      SD of age. 0.55*age7, 0.55*age11
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1992     def20      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.3182465  0.653316   0.745076   0.857813   0.5479771  1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1992     def20      SD of age. 0.55*age8, 0.55*age12
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1993     def21      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.3593238  0.745076   0.857813   0.996322   0.641575   1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 1993     def21      SD of age. 0.55*age9, 0.55*age13
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1994     def22      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.4097918  0.857813   0.996322   1.1665     0.7565635  1.63244    1.858      2.172      2.53       2.934      3.388      # 1994     def22      SD of age. 0.55*age10, 0.55*age14
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1995     def23      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.47179715 0.996322   1.1665     1.37557    0.897842   1.858      2.172      2.53       2.934      3.388      # 1995     def23      SD of age. 0.55*age11, 0.55*age15
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1996     def24      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.5479771  1.1665     1.37557    1.63244    1.0219     2.172      2.53       2.934      3.388      # 1996     def24      SD of age. 0.55*age12, 0.55*age16
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1997     def25      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   0.641575   1.37557    1.63244    1.858      1.1946     2.53       2.934      3.388      # 1997     def25      SD of age. 0.55*age13, 0.55*age17
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1998     def26      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     0.7565635  1.63244    1.858      2.172      1.3915     2.934      3.388      # 1998     def26      SD of age. 0.55*age14, 0.55*age18
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 1999     def27      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    0.897842   1.858      2.172      2.53       1.6137     3.388      # 1999     def27      SD of age. 0.55*age15, 0.55*age19
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2000     def28      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.0219     2.172      2.53       2.934      1.8634     # 2000     def28      SD of age. 0.55*age1, 0.55*age16, 0.55*age20
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2001     def29      Expected ages
0.329242   0.329242   0.19080435 0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      1.1946     2.53       2.934      3.388      # 2001     def29      SD of age. 0.55*age2, 0.55*age17
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2002     def30      Expected ages
0.329242   0.329242   0.346917   0.2027476  0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      1.3915     2.934      3.388      # 2002     def30      SD of age. 0.55*age3, 0.55*age18
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2003     def31      Expected ages
0.329242   0.329242   0.346917   0.368632   0.2174216  0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       1.6137     3.388      # 2003     def31      SD of age. 0.55*age4, 0.55*age19
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2004     def32      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.2354495  0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      1.8634     # 2004     def32      SD of age. 0.55*age5, 0.55*age20
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2005     def33      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.2575991  0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2005     def33      SD of age. 0.55*age6
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2006     def34      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.28481255 0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2006     def34      SD of age. 0.55*age7
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2007     def35      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.3182465  0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2007     def35      SD of age. 0.55*age8
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2008     def36      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.3593238  0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2008     def36      SD of age. 0.55*age9
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2009     def37      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.4097918  0.857813   0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2009     def37      SD of age. 0.55*age10
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2010     def38      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.47179715 0.996322   1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2010     def38      SD of age. 0.55*age11
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2011     def39      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.5479771  1.1665     1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2011     def39      SD of age. 0.55*age1, 0.55*age12
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2012     def40      Expected ages
0.329242   0.329242   0.19080435 0.368632   0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   0.641575   1.37557    1.63244    1.858      2.172      2.53       2.934      3.388      # 2012     def40      SD of age. 0.55*age2, 0.55*age13
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2013     def41      Expected ages
0.329242   0.329242   0.346917   0.2027476  0.395312   0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     0.7565635  1.63244    1.858      2.172      2.53       2.934      3.388      # 2013     def41      SD of age. 0.55*age3, 0.55*age14
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2014     def42      Expected ages
0.329242   0.329242   0.346917   0.368632   0.2174216  0.42809    0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    0.897842   1.858      2.172      2.53       2.934      3.388      # 2014     def42      SD of age. 0.55*age4, 0.55*age15
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2015     def43      Expected ages
0.329242   0.329242   0.346917   0.368632   0.395312   0.2354495  0.468362   0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.0219     2.172      2.53       2.934      3.388      # 2015     def43      SD of age. 0.55*age5, 0.55*age16
0.5        1.5        2.5        3.5        4.5        5.5        6.5        7.5        8.5        9.5        10.5       11.5       12.5       13.5       14.5       15.5       16.5       17.5       18.5       19.5       20.5       # 2016     def44      Expected ages
0.329242   0.329242   0.19080435 0.368632   0.395312   0.42809    0.2575991  0.517841   0.57863    0.653316   0.745076   0.857813   0.996322   1.1665     1.37557    1.63244    1.858      1.1946     2.53       2.934      3.388      # 2016     def44      SD of age. 0.55*age2, 0.55*age6, 0.55*age17

#Age comps updated 1/11/2016
53   # Number of age comp observations
1    # Length bin refers to: 1=population length bin indices; 2=data length bin indices
0    #_combine males into females at or below this bin number
# Acoustic survey ages (N=10)
#year Season Fleet Sex Partition AgeErr LbinLo LbinHi nTrips  a1      a2      a3      a4      a5      a6      a7      a8      a9      a10     a11     a12     a13     a14     a15
1995  1      2     0   0         23     -1     -1     69      0       20.48   3.26    1.06    19.33   1.03    4.03    16.37   1.44    0.72    24.86   0.24    1.67    0.21    5.32
1998  1      2     0   0         26     -1     -1     105     0       6.83    8.03    17.03   17.25   1.77    11.37   10.79   1.73    4.19    7.60    1.27    0.34    9.74    2.06
2001  1      2     0   0         29     -1     -1     57      0       50.62   10.95   15.12   7.86    3.64    3.84    2.60    1.30    1.34    0.65    0.68    0.87    0.15    0.39
2003  1      2     0   0         31     -1     -1     71      0       23.06   1.63    43.40   13.07   2.71    5.14    3.43    1.82    2.44    1.44    0.49    0.43    0.42    0.52
2005  1      2     0   0         33     -1     -1     47      0       19.07   1.23    5.10    4.78    50.67   6.99    2.50    3.99    2.45    1.71    0.74    0.48    0.14    0.16
2007  1      2     0   0         35     -1     -1     69      0       28.29   2.16    11.64   1.38    5.01    3.25    38.64   3.92    1.94    1.70    0.83    0.77    0.34    0.12
2009  1      2     0   0         37     -1     -1     72      0       0.55    29.33   40.21   2.29    8.22    1.25    1.79    1.93    8.32    3.63    1.44    0.28    0.48    0.26
2011  1      2     0   0         39     -1     -1     46      0       27.62   56.32   3.71    2.64    2.94    0.70    0.78    0.38    0.66    0.97    2.10    0.76    0.31    0.11
2012  1      2     0   0         40     -1     -1     94      0       62.12   9.78    16.70   2.26    2.92    1.94    1.01    0.50    0.23    0.27    0.66    0.98    0.51    0.12
2013  1      2     0   0         41     -1     -1     67      0       2.17    74.97   5.63    8.68    0.95    2.20    2.59    0.71    0.35    0.10    0.13    0.36    0.77    0.38
2015  1      2     0   0         43     -1     -1     78      0       7.45    9.19    4.38    58.98   4.88    7.53    1.69    1.68    1.64    0.95    0.16    0.29    0.24    0.92

#Aggregate marginal fishery age comps (n=40)
#year Season Fleet Sex Partition AgeErr LbinLo LbinHi nTrips  a1      a2      a3      a4      a5      a6      a7      a8      a9      a10     a11     a12     a13     a14     a15
1975	1	1	0	0	3	-1	-1	13	4.608	33.846	7.432	1.248	25.397	5.546	8.031	10.537	0.953	0.603	0.871	0.451	0.000	0.476	0.000
1976	1	1	0	0	4	-1	-1	142	0.085	1.337	14.474	6.742	4.097	24.582	9.766	8.899	12.099	5.431	4.303	4.075	1.068	2.355	0.687
1977	1	1	0	0	5	-1	-1	320	0.000	8.448	3.683	27.473	3.594	9.106	22.682	7.599	6.544	4.016	3.550	2.308	0.572	0.308	0.119
1978	1	1	0	0	6	-1	-1	341	0.472	1.110	6.511	6.310	26.416	6.091	8.868	21.505	9.776	4.711	4.680	2.339	0.522	0.353	0.337
1979	1	1	0	0	7	-1	-1	116	0.000	6.492	10.241	9.382	5.721	17.666	10.256	17.370	12.762	4.180	2.876	0.963	1.645	0.000	0.445
1980	1	1	0	0	8	-1	-1	221	0.148	0.544	30.087	1.855	4.488	8.166	11.227	5.012	8.941	11.075	9.460	2.628	3.785	1.516	1.068
1981	1	1	0	0	9	-1	-1	154	19.492	4.031	1.403	26.726	3.901	5.547	3.376	14.675	3.769	3.195	10.186	2.313	0.504	0.163	0.720
1982	1	1	0	0	10	-1	-1	170	0.000	32.050	3.521	0.486	27.347	1.526	3.680	3.894	11.764	3.268	3.611	7.645	0.241	0.302	0.664
1983	1	1	0	0	11	-1	-1	117	0.000	0.000	34.144	3.997	1.825	23.458	5.126	5.647	5.300	9.383	3.910	3.128	2.259	1.130	0.695
1984	1	1	0	0	12	-1	-1	123	0.000	0.000	1.393	61.904	3.625	3.849	16.778	2.853	1.509	1.239	3.342	0.923	0.586	1.439	0.561
1985	1	1	0	0	13	-1	-1	57	0.925	0.111	0.348	7.241	66.754	8.407	5.605	7.106	2.042	0.530	0.654	0.246	0.000	0.000	0.032
1986	1	1	0	0	14	-1	-1	120	0.000	15.341	5.384	0.527	0.761	43.638	6.898	8.154	8.260	2.189	2.817	1.834	3.133	0.457	0.609
1987	1	1	0	0	15	-1	-1	56	0.000	0.000	29.583	2.904	0.135	1.013	53.260	0.404	1.250	7.091	0.000	0.744	1.859	1.757	0.000
1988	1	1	0	0	16	-1	-1	84	0.000	0.657	0.065	32.348	0.980	1.451	0.656	45.959	1.343	0.835	10.498	0.791	0.054	0.064	4.301
1989	1	1	0	0	17	-1	-1	80	0.000	5.616	2.431	0.288	50.206	1.257	0.292	0.084	35.192	1.802	0.395	2.316	0.084	0.000	0.037
1990	1	1	0	0	18	-1	-1	163	0.000	5.194	20.559	1.885	0.592	31.349	0.512	0.200	0.043	31.901	0.296	0.067	6.411	0.000	0.992
1991	1	1	0	0	19	-1	-1	160	0.000	3.464	20.372	19.632	2.522	0.790	28.260	1.177	0.145	0.181	18.688	0.423	0.000	3.606	0.741
1992	1	1	0	0	20	-1	-1	243	0.461	4.238	4.304	13.052	18.594	2.272	1.044	33.927	0.767	0.078	0.340	18.049	0.413	0.037	2.426
1993	1	1	0	0	21	-1	-1	172	0.000	1.051	23.240	3.260	12.980	15.666	1.500	0.810	27.421	0.674	0.089	0.120	12.004	0.054	1.129
1994	1	1	0	0	22	-1	-1	235	0.000	0.037	2.832	21.390	1.265	12.628	18.687	1.571	0.573	29.906	0.262	0.282	0.022	9.634	0.909
1995	1	1	0	0	23	-1	-1	147	0.619	1.281	0.467	6.309	28.973	1.152	8.051	20.271	1.576	0.222	22.422	0.435	0.451	0.037	7.734
1996	1	1	0	0	24	-1	-1	186	0.000	18.282	16.242	1.506	7.743	18.140	1.002	4.908	10.981	0.576	0.347	15.716	0.009	0.108	4.439
1997	1	1	0	0	25	-1	-1	220	0.000	0.737	29.476	24.952	1.468	7.838	12.488	1.798	3.977	6.671	1.284	0.216	6.079	0.733	2.282
1998	1	1	0	0	26	-1	-1	243	0.015	4.786	20.351	20.288	26.596	2.869	5.400	9.310	0.917	1.557	3.899	0.352	0.092	2.940	0.627
1999	1	1	0	0	27	-1	-1	509	0.062	10.242	20.364	17.981	20.062	13.199	2.688	3.930	4.009	0.989	1.542	2.140	0.392	0.335	2.066
2000	1	1	0	0	28	-1	-1	530	0.996	4.218	10.935	14.285	12.880	21.063	13.115	6.548	4.648	2.509	2.070	2.306	1.292	0.720	2.414
2001	1	1	0	0	29	-1	-1	540	0.000	17.338	16.247	14.250	15.685	8.559	12.100	5.989	1.778	2.232	1.810	0.698	1.421	0.685	1.209
2002	1	1	0	0	30	-1	-1	449	0.000	0.033	50.642	14.934	9.687	5.719	4.438	6.580	3.546	0.871	0.845	1.036	0.242	0.475	0.953
2003	1	1	0	0	31	-1	-1	456	0.000	0.105	1.397	67.896	11.642	3.339	4.987	3.191	3.137	2.106	0.874	0.436	0.533	0.125	0.231
2004	1	1	0	0	32	-1	-1	501	0.000	0.022	5.310	6.067	68.288	8.152	2.187	4.155	2.512	1.281	1.079	0.350	0.268	0.160	0.170
2005	1	1	0	0	33	-1	-1	613	0.018	0.569	0.464	6.562	5.381	68.723	7.953	2.358	2.909	2.207	1.177	1.090	0.250	0.090	0.248
2006	1	1	0	0	34	-1	-1	720	0.326	2.808	10.444	1.673	8.567	4.879	59.038	5.275	1.716	2.376	1.134	1.015	0.426	0.135	0.188
2007	1	1	0	0	35	-1	-1	629	0.761	11.311	3.737	15.471	1.594	6.855	3.834	44.109	5.177	1.721	2.279	1.771	0.504	0.187	0.689
2008	1	1	0	0	36	-1	-1	794	0.758	9.850	30.590	2.403	14.421	1.027	3.628	3.166	28.014	3.039	1.142	0.732	0.491	0.313	0.429
2009	1	1	0	0	37	-1	-1	686	0.637	0.519	30.626	27.548	3.356	10.705	1.305	2.259	2.291	16.191	2.485	0.866	0.591	0.281	0.340
2010	1	1	0	0	38	-1	-1	874	0.028	25.336	3.355	34.848	21.528	2.358	3.001	0.444	0.579	0.974	6.056	0.926	0.306	0.104	0.157
2011	1	1	0	0	39	-1	-1	1081	2.638	8.503	70.847	2.650	6.413	4.446	1.144	0.819	0.294	0.390	0.118	1.348	0.171	0.110	0.108
2012	1	1	0	0	40	-1	-1	851	0.181	40.949	11.556	32.991	2.490	5.083	2.516	1.132	0.659	0.231	0.329	0.347	0.870	0.283	0.383
2013	1	1	0	0	41	-1	-1	1094	0.030	0.544	70.309	5.906	10.473	1.123	3.413	2.059	0.906	1.366	0.264	0.333	0.530	2.281	0.462
2014	1	1	0	0	42	-1	-1	1130	0.000	3.314	3.731	64.297	6.926	12.169	1.587	3.141	1.827	0.823	0.466	0.118	0.191	0.279	1.131
2015	1	1	0	0	43	-1	-1	798	3.591	1.136	6.883	3.946	70.023	4.940	5.089	0.958	1.551	1.088	0.202	0.205	0.061	0.054	0.273
2016	1	1	0	0	44	-1	-1	1300	0.322	46.956	1.687	4.867	2.589	35.046	3.004	3.376	0.868	0.471	0.402	0.220	0.073	0.041	0.078

0 # No Mean size-at-age data
0 # Total number of environmental variables
0 # Total number of environmental observations
0 # No Weight frequency data
0 # No tagging data
0 # No morph composition data

999 # End data file
