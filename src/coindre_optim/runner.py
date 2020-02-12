# python standard library
import os
import datetime as dt
import shutil

# Third party library
import yaml

# Application specific
import coindre_optim.prepare_csv_input as prep_csv
import coindre_optim.post_results as pr
from . import default_config_path


class Runner:
    def __init__(self, config_path=default_config_path):
        # opening the yaml file to write the configuration as model_instance attribute
        with open(config_path) as file:
            Loaded_file = yaml.load(file, Loader=yaml.FullLoader)
        self._config = Loaded_file
        # relative paths and directories of interest in the project
        self._PY_SRC_PATH = os.path.dirname(os.path.realpath(__file__))
        self._GAMS_SRC_PATH = os.path.join(self._PY_SRC_PATH, "GAMS")
        self._PROJECT_DIR = os.path.realpath(
            os.path.join(self._PY_SRC_PATH, "..", "..")
        )
        self._COINDRE_OPTIM_DIR = os.path.realpath(os.path.join(self._PY_SRC_PATH))
        # using YAML file to find directories to write the model input and output
        self._GDX_DIR = os.path.join(self._config["WORKING_DIR"], "gdx_files")
        self._CSV_INPUT_DIR = os.path.join(self._config["WORKING_DIR"], "input")
        self._OUT_DIR = os.path.join(self._config["WORKING_DIR"], "output")

    def _create_workspace(self):
        # create the working directory and associated input gdx and output directories
        print("* Creating working directories and xlsx template")
        for p in [self._GDX_DIR, self._CSV_INPUT_DIR, self._OUT_DIR]:
            if not os.path.exists(p):
                os.makedirs(p)
        print("* Copying excel template to working directory")
        # check if there is a run_results.xslx template to write in and copy-paste one from the source directory if necessary
        if not os.path.exists(
            os.path.join(self._config["WORKING_DIR"], "run_results.xlsx")
        ):
            shutil.copyfile(
                os.path.join(self._COINDRE_OPTIM_DIR, "run_results.xlsx"),
                os.path.join(self._config["WORKING_DIR"], "run_results.xlsx"),
            )

    def _get_gams_run_config(self):
        options_cli = ""
        for k, v in self._config["GAMS"].items():
            if k != "GAMS_PATH":
                if k == "IDE":
                    v = f'"{v}"'
                options_cli = "--".join([options_cli, "".join([k, "=", f"{v}", " "])])
        return options_cli

    def _convert_to_gdx(self):
        cli_csv2gdx = " ".join(
            [
                self._config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self._GAMS_SRC_PATH,"convert_to_gdx.gms")}"',
                f'--CSV_INPUT_DIR="{self._CSV_INPUT_DIR}"',
                f'--GDX_DIR="{self._GDX_DIR}"',
            ]
        )
        print("running command line:    ", cli_csv2gdx)
        os.system(cli_csv2gdx)

    def _import_from_hdx(self, s_date, e_date):
        prep_csv.write_model_csv_inputs(
            hx_api_key=self._config["HDX"]["PERSONAL_API_KEY"],
            start_date=s_date,
            end_date=e_date,
            csv_input_dir=self._CSV_INPUT_DIR,
            write_csv=True,
        )

    def _post_parameters(self):
        if self._config["POST_TO_HDX"] == True:
            try:
                pr.post_results_to_hdx(
                    WORKING_DIR=self._config["WORKING_DIR"],
                    PERSONAL_API_KEY=self._config["HDX"]["PERSONAL_API_KEY"],
                )
            except:
                print("A problem occured during the post in Hydrolix")

    def _get_gams_run_options(self):
        cli_run_daily_model = " ".join(
            [
                self._config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self._GAMS_SRC_PATH, "COOPT.gms")}"',
                self._get_gams_run_config(),
                f'--GDX_DIR="{self._GDX_DIR}"',
                f'--CURRENT_TIME="{dt.datetime.now().hour}"',
                f'--IMPORT_GDX_PATH="{os.path.realpath(os.path.join(self._GDX_DIR, "import_coopt.gdx"))}"',
                f'--OUT_DIR="{self._OUT_DIR}"',
                f'--OUT_PATH="{os.path.join(self._OUT_DIR, "output.gdx")}"',
                f'--ALL_OUT_PATH="{os.path.join(self._OUT_DIR, "all_output.gdx")}"',
                f'--GAMS_SRC_PATH="{self._GAMS_SRC_PATH}"',
                f'--GAMS_POST_TREATMENT_PATH="{os.path.join(self._GAMS_SRC_PATH,"post_treatment.gms")}"',
                f'--PZ_PATH="{os.path.join(self._GAMS_SRC_PATH, "power_zones.gdx")}"',
                f'--BATHY_PATH="{os.path.join(self._GAMS_SRC_PATH, "bathymetry.gdx")}"',
                f'--ADDUCTION_PATH={os.path.join(self._GAMS_SRC_PATH, "adduction_planes.gdx")}',
                f'--XLS_OUTPUT="{os.path.join(self._config["WORKING_DIR"], "run_results.xlsx")}"',
            ]
        )
        return cli_run_daily_model

    def _run_daily(self):
        cli_run_daily_model = self._get_gams_run_options()
        print("Launching model with command line:")
        print(cli_run_daily_model)
        os.system(cli_run_daily_model)
        print(f"Run results stored at {self._config['WORKING_DIR']}")

    def launch(self, start=None, post=False):
        start = (start or dt.datetime.now()).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        end = start + dt.timedelta(days=self._config["HDX"]["NUMBER_OF_DAYS"])
        print(
            f'* Production plan is equal to the nominated/realised up to H{self._config["GAMS"]["LOCK_PRODUCTION_PLAN"]} included'
        )
        print(f"* Python job started at {dt.datetime.now()}")
        print(f"* Run Start date :  {start}")
        print(f"* Run End date   :  {end}")
        self._create_workspace()
        self._import_from_hdx(start, end)
        self._convert_to_gdx()
        self._run_daily()
        if post == True:
            self._post_parameters()
