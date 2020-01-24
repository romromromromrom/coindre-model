*###############################################################################################
*################                                                             ##################
*################                           EXPORTS                           ##################
*################                                                             ##################
*###############################################################################################
$SETGLOBAL COMMON_DIRECTORY C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0
$SETGLOBAL out_dir %COMMON_DIRECTORY%\output
$SETGLOBAL PZ_DIR %COMMON_DIRECTORY%\power zones\power_zones.gdx
$SETGLOBAL BATHY_DIR %COMMON_DIRECTORY%\bathy\bathymetry.gdx
$SETGLOBAL ADDUCTION_DIR %COMMON_DIRECTORY%\double adduction routines\adduction_planes.gdx
$SETGLOBAL gdx_dir %COMMON_DIRECTORY%\gdx_files\import_coopt.gdx
$SETGLOBAL out_name output_COOPT
$SETGLOBAL MIP_GAP 0.001
$SETGLOBAL RUN_TIME_LIMIT 2000
$SETGLOBAL NO_TB_FILTER 1
$SETGLOBAL ENABLE_RESERVED_FLOW_RATE 1
 NOTE THAT IF NO_tb_FILTER IS ON n_days has no effect the time horizon is the number of days in the input dataset
$SETGLOBAL n_days 2
$SETGLOBAL CURRENT_TIME 10

$SETGLOBAL ACTI_SLACKS 1
$SETGLOBAL ACTI_WB_SLACKS 0
$SETGLOBAL ALLO_SPILL 1
$SETGLOBAL DZ_COMP_SSTR 1
$SETGLOBAL CORR_FLO 0.3
$SETGLOBAL QTOT_THRESH_SSTR 15
$SETGLOBAL QTOT_THRESH_TRANS 10
$SETGLOBAL delta_V 2
$SETGLOBAL PCT_START 0
$SETGLOBAL PCT_END 1
$SETGLOBAL VOLUME_INIT_CONDITIONS 1
$SETGLOBAL V_INI_GR  1500000
$SETGLOBAL V_INI_PR  250000
$SETGLOBAL RUN_NUM 2
$SETGLOBAL INFLOWS_FACT 1

SET tb;
PARAMETER report(tb,*);

PARAMETER pp(tb),vv_closed(tb);

$gdxin '%out_dir%\all_results_COOPT.gdx'
$load tb report
pp(tb) = report(tb,'p(t)');
vv_closed(tb) = report(tb,'Vane CLOSED');

*** export to hydrolix ******
File power_schedule /"%out_dir%\power_schedule.csv"/;
File vane_schedule  /"%out_dir%\vane_schedule.csv"/


put power_schedule;
put ',p(tb)' /;
loop(tb, put tb.te(tb),',',pp(tb):</);

put vane_schedule;
put ',vane_closed(tb)' /;
loop(tb, put tb.te(tb),',',vv_closed(tb):</);

execute '%COMMON_DIRECTORY%\post_results.py'
