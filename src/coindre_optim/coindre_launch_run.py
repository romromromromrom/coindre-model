import os
import datetime as dt
import prepare_csv_input as prep_csv
import post_results as pr
import shutil
from __init__ import config


# relative paths and directories of interest in the project
PY_SRC_PATH = os.path.dirname(os.path.realpath(__file__))
GAMS_SRC_PATH = os.path.join(PY_SRC_PATH,"GAMS")
PROJECT_DIR = os.path.realpath(os.path.join(PY_SRC_PATH,"..",".."))
COINDRE_OPTIM_DIR = os.path.realpath(os.path.join(PY_SRC_PATH))
# using YAML file to find directories to write the model input and output
GDX_DIR = os.path.join(config["WORKING_DIR"],"gdx_files")
CSV_INPUT_DIR = os.path.join(config["WORKING_DIR"],"input")
OUT_DIR = os.path.join(config["WORKING_DIR"],"output")
# create the input gdx and output directories in a user chosen working directory is not existent
for p in [GDX_DIR,
          CSV_INPUT_DIR,
          OUT_DIR]:
    if not os.path.exists(p):
        os.makedirs(p)
# copy the template run_results.xlsx to the working directory for visualisation
shutil.copyfile(os.path.join(COINDRE_OPTIM_DIR,"run_results.xlsx"),
                os.path.join(config["WORKING_DIR"],"run_results.xlsx"))

# Start and end date for the GAMS RUN
start_date = dt.datetime.now().replace(hour=0,
                                       minute=0,
                                       second=0,
                                       microsecond=0)
end_date = start_date + dt.timedelta(days=config["HDX"]["NUMBER_OF_DAYS"])
time = dt.datetime.now().hour


# print out information about the setup to user
print(f'* Production plan is equal to the nominated/realised up to H{config["GAMS"]["LOCK_PRODUCTION_PLAN"]} included')
print(f"* Python job started at {dt.datetime.now()}")
print(f"* Run Start date :  {start_date}")
print(f"* Run End date   :  {end_date}")




def get_gams_run_options(config):
    options_cli = ""
    for k,v in config["GAMS"].items():
        if (k != "GAMS_PATH"):
            if (k == "IDE"):
                v = f'"{v}"'
            options_cli ="--".join([options_cli , "".join([k,"=",f"{v}"," "])])
    return options_cli

def convert_to_gdx(config,CSV_INPUT_DIR,GDX_DIR):
    cli_csv2gdx = " ".join([
        config["GAMS"]["GAMS_PATH"],
        f'"{os.path.join(GAMS_SRC_PATH,"convert_to_gdx.gms")}"',
        f'--CSV_INPUT_DIR="{CSV_INPUT_DIR}"',
        f'--GDX_DIR="{GDX_DIR}"',

    ])
    print("running command line:    ",cli_csv2gdx)
    os.system(cli_csv2gdx)


def run_model_daily(config,GDX_DIR,OUT_DIR):
    cli_run_daily_model = " ".join([
        config["GAMS"]["GAMS_PATH"],
        f'"{os.path.join(GAMS_SRC_PATH, "COOPT.gms")}"',
        get_gams_run_options(config),
        f'--GDX_DIR="{GDX_DIR}"',
        f'--CURRENT_TIME="{time}"',
        f'--IMPORT_GDX_PATH="{os.path.realpath(os.path.join(GDX_DIR,"import_coopt.gdx"))}"',
        f'--OUT_DIR="{OUT_DIR}"',
        f'--OUT_PATH="{os.path.join(OUT_DIR,"output.gdx")}"',
        f'--ALL_OUT_PATH="{os.path.join(OUT_DIR, "all_output.gdx")}"',
        f'--GAMS_SRC_PATH="{GAMS_SRC_PATH}"',
        f'--PZ_PATH="{os.path.join(GAMS_SRC_PATH,"power_zones.gdx")}"',
        f'--BAHTY_PATH="{os.path.join(GAMS_SRC_PATH, "bathymetry.gdx")}"',
        f'--ADDUCTION_PATH="{os.path.join(GAMS_SRC_PATH, "adduction_planes.gdx")}"',
        f'--XLS_OUTPUT="{os.path.join(config["WORKING_DIR"],"run_results.xlsx")}"'
    ])
    print("running command line:    ",cli_run_daily_model)
    os.system(cli_run_daily_model)




prep_csv.write_model_csv_inputs(PERSONAL_API_KEY=config["HDX"]["PERSONAL_API_KEY"],
                                start_date=start_date,
                                end_date=end_date,
                                CSV_INPUT_DIR=CSV_INPUT_DIR,
                                write_csv = True)

convert_to_gdx(config,CSV_INPUT_DIR,GDX_DIR)
run_model_daily(config,GDX_DIR,OUT_DIR)


# post results in hdx parameters
if config["POST_DIRECTLY_IN_HDX"] == True:
    pr.post_results_to_hdx(PROJECT_DIR=PROJECT_DIR)
    print(
        "* PRODUCTION results have been posted to hydrolix at     Id: 6753, Target: Coindre_T    , Attribute: production    , Scenario: coindre_model"
    )
    print(
        "* VALVE results have been posted to hydrolix at          Id: 6754, Target: Petite-Rhue_R, Attribute: valve_position, Scenario: coindre_model"
    )
else:
    print("* Run is done, results are in run_results.xlsx")
