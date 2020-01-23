import os
import subprocess
import import_COOPTV6_test as imp
import datetime as dt
import sys,os
import hydrolix_client as hx
import pandas as pd
import pytz
import numpy as np
import timedelta

##### parameters of the run #####
start_date = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
time = dt.datetime.now().hour
API_KEY = '5bpodg6vmy18lqtq949u4psgh0mb5lfxg0bz326jmpxnma3w8r7tntb9y4j1hzlj'
number_of_days= 14
run_num = 0
end_date = start_date + dt.timedelta(days=number_of_days)
mip_gap = 0.01
warm_start = 1
second_solve = 1
keep_UC_schedule = 1
lock_prod_plan_until_H = 13

if dt.datetime.now().hour<=7:
    second_solve = 0
    keep_UC_schedule = 0


if dt.datetime.now().hour<=12:
    lock_prod_plan_until_H = 13
else:
    lock_prod_plan_until_H = 2 + dt.datetime.now().hour


#################################

######DIRECTORIES###########
#gams_dir = input(r'please enter your gams directory (example: C:\Gams\win64\28.1\gams.exe)')
gams_dir = r'C:\Gams\win64\28.1\gams.exe'
common_dir = os.path.dirname(os.path.realpath(__file__))


print(common_dir)

csv2gdx_dir = r'\main\import_coopt.gms'
#runner_dir = r'\main\backtest_OPTIM.gms'
runner_dir = r'\main\COOPT.gms'
ide = r'ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1'
options = ' --MIP_GAP={} --RUN_NUM={} --COMMON_DIRECTORY="{}" --CURRENT_TIME={} --WS={} --SS={} --KUC={} --LOCK_PRODUCTION_PLAN={}'.format(mip_gap,run_num,common_dir,dt.datetime.now().hour, warm_start,second_solve, keep_UC_schedule,lock_prod_plan_until_H )
print(options)


##### imports from HDX in .csv ###################
imp.import_model_inputs_v6(PERSONAL_API_KEY=API_KEY,start_date=start_date,end_date=end_date,common_directory=common_dir,write_csv = True,plot_brut = True,plot_imbal_pr = False,plot_imbal_gr = False,moving_averages = False,plot_scatters=False)
##### Conversion csv to gadx for GAMS ###########
cmd_conversion_csv2gdx_gams = gams_dir + ' ' + '\"' + common_dir + csv2gdx_dir + '\"' + r' --csv_data_dir="' + common_dir + r'\input"'+ r' --input_gdx_dir="' + common_dir + r'\gdx_files"'
os.system(cmd_conversion_csv2gdx_gams)


######## RUN LAUNCH #############
cmd_run_launch = gams_dir + ' ' + '\"' + common_dir + runner_dir + '\"' + options
print('... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ...')
os.system(cmd_run_launch)

















