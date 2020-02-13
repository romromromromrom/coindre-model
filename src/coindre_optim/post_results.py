import os
import datetime as dt
import logging

import pandas as pd

import coindre_optim.hydrolix_client as hx
from . import TZ

logger = logging.getLogger(__name__)


def post_results_to_hdx(working_dir, hx_api_key, scenario):
    logger.info(r"POSTING RESULTS")

    c = hx.Client(api_key=hx_api_key)
    version = TZ.localize(dt.datetime(1980, 1, 1))

    df = pd.read_excel(
        os.path.join(working_dir, r"run_results.xlsx"),
        index_col=0,
        sheet_name="results",
    )
    drange = pd.to_datetime(df.index).tz_convert(TZ)
    df2 = pd.DataFrame(data=df.values, index=drange, columns=df.keys())
    power_schedule = df2.loc[:, ["p(t)"]].rename(columns={"p(t)": "Value"})

    vane_schedule = (1 - df2.loc[:, ["Vane CLOSED"]] / 10).rename(
        columns={"Vane CLOSED": "Value"}
    )

    c.post_parameter_timeseries_data(
        power_schedule, "Coindre_T", "production", scenario, version
    )
    c.post_parameter_timeseries_data(
        vane_schedule, "Petite-Rhue_R", "valve_position", scenario, version
    )


