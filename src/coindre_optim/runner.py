import os
import datetime as dt
import shutil
import logging

import yaml
import pandas as pd

import coindre_optim.prepare_csv_input as prep_csv
import coindre_optim.post_results as pr
from . import default_config_path


logger = logging.getLogger(__name__)


class Runner:
    def __init__(self, config_path=default_config_path):
        # opening the yaml file to write the configuration as model_instance attribute
        with open(config_path) as file:
            self._config = yaml.load(file, Loader=yaml.FullLoader)
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
        self._visu_filename = "run_results.xlsx"

    def _write_visu_file(self):
        import xlwings as xw
        df_raw = pd.read_csv(
            filepath_or_buffer=os.path.join(self._config["WORKING_DIR"],
                                            "raw_results.csv"),
            header=None,
            index_col=False
        )
        try:
            wb = xw.Book(
                os.path.join(self._config["WORKING_DIR"], self._visu_filename)
            )
            sht = wb.sheets['raw_results']
            sht.range("A1:BM700").clear_contents()
            sht.range('A1').value = df_raw.values
            wb.save()
        except Exception as ex:
            logger.exception(ex)
        finally:
            wb.close()

    def _create_workspace(self):
        # create the working directory and associated input gdx and output directories
        logger.info("* Creating working directories and xlsx template")
        for p in [self._GDX_DIR, self._CSV_INPUT_DIR, self._OUT_DIR]:
            if not os.path.exists(p):
                os.makedirs(p)
        logger.info("* Copying excel template to working directory")
        # check if there is a run_results.xslx template to write in and copy-paste one from the source directory if necessary
        self._visu_filename = "run_results.xlsx"
        if not os.path.exists(
            os.path.join(self._config["WORKING_DIR"], self._visu_filename)
        ):
            shutil.copyfile(
                os.path.join(self._COINDRE_OPTIM_DIR, self._visu_filename),
                os.path.join(self._config["WORKING_DIR"], self._visu_filename),
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
        logger.info("running command line:    ", cli_csv2gdx)
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
        if self._config["POST_TO_HDX"]:
            try:
                pr.post_results_to_hdx(
                    working_dir=self._config["WORKING_DIR"],
                    hx_api_key=self._config["HDX"]["PERSONAL_API_KEY"],
                    scenario=self._config["HDX"]["SCENARIO"],
                )
            except Exception as ex:
                logger.exception(ex)
                logger.error("A problem occurred during the post in Hydrolix")

    def _get_gams_run_options(self):
        cli_run_daily_model = " ".join(
            [
                self._config["GAMS"]["GAMS_PATH"],
                f'"{os.path.join(self._GAMS_SRC_PATH, "COOPT.gms")}"',
                self._get_gams_run_config(),
                f'--GDX_DIR="{self._GDX_DIR}"',
                f'--CURRENT_TIME="{dt.datetime.now().hour}"',
                f'--WORKING_DIR="{os.path.join(self._config["WORKING_DIR"])}"',
                f'--GAMS_SRC_PATH="{self._GAMS_SRC_PATH}"',
            ]
        )
        return cli_run_daily_model

    def _run_daily(self):
        cli_run_daily_model = self._get_gams_run_options()
        logger.info("Launching model with command line:")
        logger.info(cli_run_daily_model)
        os.system(cli_run_daily_model)
        logger.info(f"Run results stored at {self._config['WORKING_DIR']}")

    def launch(self, start=None):
        try:
            start = (start or dt.datetime.now()).replace(
                hour=0, minute=0, second=0, microsecond=0
            )
            end = start + dt.timedelta(days=self._config["HDX"]["NUMBER_OF_DAYS"])
            logger.info(
                f'* Production plan is equal to the nominated/realised up to H{self._config["GAMS"]["LOCK_PRODUCTION_PLAN"]} included'
            )
            logger.info(f"* Python job started at {dt.datetime.now()}")
            logger.info(f"* Run Start date :  {start}")
            logger.info(f"* Run End date   :  {end}")
            self._create_workspace()
            self._import_from_hdx(start, end)
            self._convert_to_gdx()
            self._run_daily()
            self._post_parameters()
            if self._config.get('WRITE_EXCEL_RESULTS', False):
                self._write_visu_file()



        except Exception as ex:
            logger.exception(ex)



