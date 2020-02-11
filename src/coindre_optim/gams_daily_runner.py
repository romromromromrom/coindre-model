import os
import datetime as dt
import prepare_csv_input as prep_csv
import post_results as pr
from __init__ import config
import shutil


class coindre_model_instance:
    def __init__(self, config):
        # relative paths and directories of interest in the project
        self.PY_SRC_PATH = os.path.dirname(os.path.realpath(__file__))
        self.GAMS_SRC_PATH = os.path.join(self.PY_SRC_PATH, "GAMS")
        self.PROJECT_DIR = os.path.realpath(os.path.join(self.PY_SRC_PATH, "..", ".."))
        self.COINDRE_OPTIM_DIR = os.path.realpath(os.path.join(self.PY_SRC_PATH))
        # using YAML file to find directories to write the model input and output
        self.GDX_DIR = os.path.join(config["WORKING_DIR"], "gdx_files")
        self.CSV_INPUT_DIR = os.path.join(config["WORKING_DIR"], "input")
        self.OUT_DIR = os.path.join(config["WORKING_DIR"], "output")

        # create the working directory and associated input gdx and output directories
        print("* Creating working directories and xlsx template")
        for p in [self.GDX_DIR, self.CSV_INPUT_DIR, self.OUT_DIR]:
            if not os.path.exists(p):
                os.makedirs(p)
        try:
            shutil.copyfile(
                os.path.join(self.COINDRE_OPTIM_DIR, "run_results.xlsx"),
                os.path.join(config["WORKING_DIR"], "run_results.xlsx"),
            )
        except:
            print("* Did not find the .XLSX template in the source directory")

    def get_gams_run_options(self):
        options_cli = ""
        for k, v in config["GAMS"].items():
            if k != "GAMS_PATH":
                if k == "IDE":
                    v = f'"{v}"'
                options_cli = "--".join([options_cli, "".join([k, "=", f"{v}", " "])])
        return options_cli

    def convert_to_gdx(self):
        cli_csv2gdx = " ".join(
            [
                config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self.GAMS_SRC_PATH,"convert_to_gdx.gms")}"',
                f'--CSV_INPUT_DIR="{self.CSV_INPUT_DIR}"',
                f'--GDX_DIR="{self.GDX_DIR}"',
            ]
        )
        print("running command line:    ", cli_csv2gdx)
        os.system(cli_csv2gdx)

    def import_from_hdx(self, s_date, e_date):
        prep_csv.write_model_csv_inputs(
            PERSONAL_API_KEY=config["HDX"]["PERSONAL_API_KEY"],
            start_date=s_date,
            end_date=e_date,
            CSV_INPUT_DIR=self.CSV_INPUT_DIR,
            write_csv=True,
        )

    def post_parameters(self):
        if config["POST_TO_HDX"] == True:
            try:
                pr.post_results_to_hdx(PROJECT_DIR=self.PROJECT_DIR)
            except:
                print("A problem occured during the post in Hydrolix")

    def run_daily(self):
        cli_run_daily_model = " ".join(
            [
                config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self.GAMS_SRC_PATH, "COOPT.gms")}"',
                self.get_gams_run_options(),
                f'--GDX_DIR="{self.GDX_DIR}"',
                f'--CURRENT_TIME="{dt.datetime.now().hour}"',
                f'--IMPORT_GDX_PATH="{os.path.realpath(os.path.join(self.GDX_DIR,"import_coopt.gdx"))}"',
                f'--OUT_DIR="{self.OUT_DIR}"',
                f'--OUT_PATH="{os.path.join(self.OUT_DIR,"output.gdx")}"',
                f'--ALL_OUT_PATH="{os.path.join(self.OUT_DIR, "all_output.gdx")}"',
                f'--GAMS_SRC_PATH="{self.GAMS_SRC_PATH}"',
                f'--PZ_PATH="{os.path.join(self.GAMS_SRC_PATH,"power_zones.gdx")}"',
                f'--BAHTY_PATH="{os.path.join(self.GAMS_SRC_PATH, "bathymetry.gdx")}"',
                f'--ADDUCTION_PATH="{os.path.join(self.GAMS_SRC_PATH, "adduction_planes.gdx")}"',
                f'--XLS_OUTPUT="{os.path.join(config["WORKING_DIR"],"run_results.xlsx")}"',
            ]
        )
        print("Launching model with command line:    ", cli_run_daily_model)
        os.system(cli_run_daily_model)
        print(f"Run results stored at {config['WORKING_DIR']}")

    def import_and_run(self, start=None, post=True):
        start = (start or dt.datetime.now()).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        end = start + dt.timedelta(days=config["HDX"]["NUMBER_OF_DAYS"])
        print(
            f'* Production plan is equal to the nominated/realised up to H{config["GAMS"]["LOCK_PRODUCTION_PLAN"]} included'
        )
        print(f"* Python job started at {dt.datetime.now()}")
        print(f"* Run Start date :  {start}")
        print(f"* Run End date   :  {end}")
        self.import_from_hdx(start, end)
        self.convert_to_gdx()
        self.run_daily()
        if post == True:
            self.post_parameters(config["WORKING_DIR"])



#-----------------------------------------------------------------------------------------------------------------------------------
# start the main here
if __name__ == "__main__":
    model_1 = coindre_model_instance(config)
    model_1.import_and_run(post=False)

