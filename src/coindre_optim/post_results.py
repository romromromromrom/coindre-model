# Python standard library
import os
import datetime as dt
# Third party library
import pandas as pd
# Local application library
import coindre_optim.hydrolix_client as hx
from . import TZ


def post_results_to_hdx(WORKING_DIR,PERSONAL_API_KEY):

    print(r"... POSTING RESULTS ... POSTING RESULTS ... POSTING RESULTS ... ")
    c = hx.Client(
        api_key=PERSONAL_API_KEY
    )
    version = TZ.localize(dt.datetime.now().replace(minute=0, second=0, microsecond=0))
    scenario = "coindre_model"

    df = pd.read_excel(
        os.path.join(WORKING_DIR, r"run_results.xlsx"),
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
