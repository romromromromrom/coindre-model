import os
import datetime as dt
from . import prepare_csv_input as prep_csv
from . import post_results as pr
from .__init__ import default_config_path
import shutil
import yaml


class instance:
    def __init__(self, config_path=default_config_path):
        # opening the yaml file to write the configuration as model_instance attribute
        with open(config_path) as file:
            Loaded_file = yaml.load(file, Loader=yaml.FullLoader)
        self.config = Loaded_file
        # relative paths and directories of interest in the project
        self.PY_SRC_PATH = os.path.dirname(os.path.realpath(__file__))
        self.GAMS_SRC_PATH = os.path.join(self.PY_SRC_PATH, "GAMS")
        self.PROJECT_DIR = os.path.realpath(os.path.join(self.PY_SRC_PATH, "..", ".."))
        self.COINDRE_OPTIM_DIR = os.path.realpath(os.path.join(self.PY_SRC_PATH))
        # using YAML file to find directories to write the model input and output
        self.GDX_DIR = os.path.join(self.config["WORKING_DIR"], "gdx_files")
        self.CSV_INPUT_DIR = os.path.join(self.config["WORKING_DIR"], "input")
        self.OUT_DIR = os.path.join(self.config["WORKING_DIR"], "output")

        # create the working directory and associated input gdx and output directories
        print("* Creating working directories and xlsx template")
        for p in [self.GDX_DIR, self.CSV_INPUT_DIR, self.OUT_DIR]:
            if not os.path.exists(p):
                os.makedirs(p)
        print("* Copying excel template to working directory")
        # check if there is a run_results.xslx template to write in and copy-paste one from the source directory if necessary
        try:
            if not os.path.exists(os.path.join(self.config["WORKING_DIR"], "run_results.xlsx")):
                shutil.copyfile(
                    os.path.join(self.COINDRE_OPTIM_DIR, "run_results.xlsx"),
                    os.path.join(self.config["WORKING_DIR"], "run_results.xlsx"),
                )
        except:
            print("* Did not find the .XLSX template in the source directory")


    def get_gams_run_options(self):
        options_cli = ""
        for k, v in self.config["GAMS"].items():
            if k != "GAMS_PATH":
                if k == "IDE":
                    v = f'"{v}"'
                options_cli = "--".join([options_cli, "".join([k, "=", f"{v}", " "])])
        return options_cli

    def convert_to_gdx(self):
        cli_csv2gdx = " ".join(
            [
                self.config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self.GAMS_SRC_PATH,"convert_to_gdx.gms")}"',
                f'--CSV_INPUT_DIR="{self.CSV_INPUT_DIR}"',
                f'--GDX_DIR="{self.GDX_DIR}"',
            ]
        )
        print("running command line:    ", cli_csv2gdx)
        os.system(cli_csv2gdx)

    def import_from_hdx(self, s_date, e_date):
        prep_csv.write_model_csv_inputs(
            PERSONAL_API_KEY=self.config["HDX"]["PERSONAL_API_KEY"],
            start_date=s_date,
            end_date=e_date,
            CSV_INPUT_DIR=self.CSV_INPUT_DIR,
            write_csv=True,
        )

    def post_parameters(self):
        if self.config["POST_TO_HDX"] == True:
            try:
                pr.post_results_to_hdx(WORKING_DIR=self.config["WORKING_DIR"])
            except:
                print("A problem occured during the post in Hydrolix")

    def run_daily(self):
        cli_run_daily_model = " ".join(
            [
                self.config["GAMS"]["GAMS_PATH"],
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
                f'--XLS_OUTPUT="{os.path.join(self.config["WORKING_DIR"],"run_results.xlsx")}"',
            ]
        )
        print("Launching model with command line:    ", cli_run_daily_model)
        os.system(cli_run_daily_model)
        print(f"Run results stored at {self.config['WORKING_DIR']}")

    def launch(self, start=None, post=False):
        start = (start or dt.datetime.now()).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        end = start + dt.timedelta(days=self.config["HDX"]["NUMBER_OF_DAYS"])
        print(
            f'* Production plan is equal to the nominated/realised up to H{self.config["GAMS"]["LOCK_PRODUCTION_PLAN"]} included'
        )
        print(f"* Python job started at {dt.datetime.now()}")
        print(f"* Run Start date :  {start}")
        print(f"* Run End date   :  {end}")
        self.import_from_hdx(start, end)
        self.convert_to_gdx()
        self.run_daily()
        if post == True:
            self.post_parameters(self.config["WORKING_DIR"])



#-----------------------------------------------------------------------------------------------------------------------------------
# start the main here
if __name__ == "__main__":
    mod1 = instance()
    mod1.post_parameters()



