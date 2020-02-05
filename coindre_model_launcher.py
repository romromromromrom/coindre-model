import os
import import_COOPT as imp
import datetime as dt
import getpass
import post_results

##### parameters of the run #####
start_date = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
time = dt.datetime.now().hour
PERSONAL_API_KEY = '5bpodg6vmy18lqtq949u4psgh0mb5lfxg0bz326jmpxnma3w8r7tntb9y4j1hzlj'
user_name = getpass.getuser()
number_of_days= 14
run_num = 0
end_date = start_date + dt.timedelta(days=number_of_days)
mip_gap = 0.01
warm_start = 1
enable_transfer = 1
keep_UC_schedule = 1
lock_prod_plan_until_H = 24
run_time_limit = 2000
post_directly_in_HDX = False
inflows_factor_gr = 1
inflows_factor_pr = 1

print('* Production plan is equal to the nominated/realised up to H{} included'.format(lock_prod_plan_until_H))
print('* Python job started at {}'.format(dt.datetime.now()))
print('* Run Start date :  {}'.format(start_date))
print('* Run End date   :  {}'.format(end_date))


###### DIRECTORIES ###########
gams_dir = r'C:\Gams\win64\28.1\gams.exe'
common_dir = os.path.dirname(os.path.realpath(__file__))
csv2gdx_dir = r'\main\import_coopt.gms'
model_dir = r'\main\COOPT.gms'
ide = r'ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1'
cmd_conversion_csv2gdx_gams = gams_dir + ' ' + '\"' + common_dir + csv2gdx_dir + '\"' + r' --csv_data_dir="' + common_dir + r'\input"'+ r' --input_gdx_dir="' + common_dir + r'\gdx_files"'
gams_run_options = ' --MIP_GAP={} --RUN_NUM={} --COMMON_DIRECTORY="{}" --CURRENT_TIME={} --WARM_UP={} --REFINED_HYDRAULICS={} --FILTER_UC_SCHEDULE={} --LOCK_PRODUCTION_PLAN={} --RUN_TIME_LIMIT={} --INFLOWS_FACT_GR={} --INFLOWS_FACT_PR={}' \
    .format(mip_gap, run_num, common_dir, time, warm_start, enable_transfer, keep_UC_schedule, lock_prod_plan_until_H, run_time_limit,inflows_factor_gr, inflows_factor_pr)
cmd_run_launch = gams_dir + ' ' + '\"' + common_dir + model_dir + '\"' + gams_run_options

print('current working directoty: {}'.format(common_dir))



# Call HDX API and write the model's input in csv in the model input directory ###################
print('... Importing data from HDX ... ... Importing data from HDX ... ... Importing data from HDX ... ')
#imp.write_model_inputs(PERSONAL_API_KEY=PERSONAL_API_KEY,start_date=start_date,end_date=end_date,common_directory=common_dir,write_csv = True,plot_brut = True,plot_imbal_pr = False,plot_imbal_gr = False,moving_averages = False,plot_scatters=False)
# Call CSV2GDX.EXE to generate gams models ###########
os.system(cmd_conversion_csv2gdx_gams)
# Call GAMS.EXE to run COOPT.GMS with the specified options #############
print('Running command : {}'.format(cmd_run_launch))
print('... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ... LAUNCHING COOPT MODEL ...')
os.system(cmd_run_launch)

# post results in hdx parameters
if post_directly_in_HDX==True:
    post_results.post_results2hdx(common_dir=common_dir)
    print('* PRODUCTION results have been posted to hydrolix at     Id: 6753, Target: Coindre_T    , Attribute: production    , Scenario: coindre_model')
    print('* VALVE results have been posted to hydrolix at          Id: 6754, Target: Petite-Rhue_R, Attribute: valve_position, Scenario: coindre_model')
else:
    print('* Run is done, results are in run_results.xlsx')












