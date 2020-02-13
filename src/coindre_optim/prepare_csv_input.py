import os
import datetime as dt
import logging

import pandas as pd

from . import hydrolix_client as hx, TZ


logger = logging.getLogger(__name__)

def complete_last_day(df):
    dr = pd.date_range(
        start=df.index[0],
        end=df.index[-1].replace(hour=0,
                                 second=0,
                                 microsecond=0)
        + dt.timedelta(days=1)
        - dt.timedelta(hours=1),
        freq="1h"
    )
    df2 = df.reindex(dr) \
        .fillna(method="ffill")
    return df2


def write_model_csv_inputs(
    hx_api_key, start_date, end_date, csv_input_dir, write_csv=True,
):
    c_hydro = hx.Client(api_key=hx_api_key)

    total_drange = pd.date_range(
        start = start_date,
        end = end_date - dt.timedelta(hours=1),
        freq = "1h",
        tz=TZ
    )

    i_gr_proposed = complete_last_day(
        c_hydro.get_node_calculated_timeseries(
            target_name="Grande-Rhue_R",
            param="inflow",
            start_date=start_date,
            end_date=end_date,
            scenario="proposed_forecast",
            ).rename(columns={"value": "inflows_gr"})
    )

    i_pr_proposed = complete_last_day(
        c_hydro.get_node_calculated_timeseries(
            target_name="Petite-Rhue_R",
            param="inflow",
            start_date=start_date,
            end_date=end_date,
            scenario="proposed_forecast",
            ).rename(columns={"value": "inflows_pr"})
    )

    i_gr_q50 = complete_last_day(
        c_hydro.get_node_calculated_timeseries(
            target_name="Grande-Rhue_R",
            param="inflow",
            start_date=start_date,
            end_date=end_date,
            scenario="proposed_forecast_q50",
        ).rename(columns={"value": "igr_q50"})
    )

    i_pr_q50 = complete_last_day(
        c_hydro.get_node_calculated_timeseries(
            target_name="Petite-Rhue_R",
            param="inflow",
            start_date=start_date,
            end_date=end_date,
            scenario="proposed_forecast_q50",
            ).rename(columns={"value": "ipr_q50"})
    )

    dr_q50 = i_gr_q50.index
    i_gr = i_gr_proposed.reindex(dr_q50)
    i_pr = i_pr_proposed.reindex(dr_q50)
    i_gr.loc[i_gr[i_gr.isna().values].index, :] = i_gr_q50[i_gr.isna().values].values
    i_pr.loc[i_pr[i_pr.isna().values].index, :] = i_pr_q50[i_pr.isna().values].values
    i_gr = i_gr.reindex(total_drange).fillna(method="ffill")
    i_pr = i_pr.reindex(total_drange).fillna(method="ffill")


    # Import de l'état de la vanne
    valve_position = c_hydro.get_parameter_timeseries_data(
        target="Petite-Rhue_R",
        parameter="valve_position",
        scenario="productionplan",
        start_date=start_date,
        end_date=end_date,
    ).rename(columns={"value": "vane_closed"}).reindex(total_drange)

    # Import des volumes
    v_gr = c_hydro.get_node_calculated_timeseries(
        target_name="Grande-Rhue_R",
        param="final_volume",
        start_date=start_date,
        end_date=end_date,
        scenario="final_volume_pi",
    ).rename(columns={"value":"vgr"}).reindex(total_drange)

    v_pr = c_hydro.get_node_calculated_timeseries(
        target_name="Petite-Rhue_R",
        param="final_volume",
        start_date=start_date,
        end_date=end_date,
        scenario="final_volume_pi",
    ).rename(columns={"value":"vpr"}).reindex(total_drange)

    # import des prix et complétion du prix clearé avec les prix forecastés
    spot1 = c_hydro.get_node_calculated_timeseries(
        target_name="Spot",
        param="spot_price",
        start_date=start_date,
        end_date=end_date,
        scenario="price_phoenix",
    ).rename(columns={"value": "spot1"})

    spot2 = c_hydro.get_node_calculated_timeseries(
        target_name="Spot",
        param="spot_price",
        start_date=start_date,
        end_date=end_date,
        scenario="price_epexspot",
    ).rename(columns={"value": "spot2"})

    spot3 = c_hydro.get_node_calculated_timeseries(
        target_name="Spot",
        param="spot_price",
        start_date=start_date,
        end_date=end_date,
        scenario="price_41740",
    ).rename(columns={"value": "spot3"})

    merged_df = pd.concat([spot1, spot2], axis=1)
    merged_df.loc[merged_df["spot2"].isna().values, "spot2"] = (
        merged_df[merged_df["spot2"].isna().values].loc[:, "spot1"].values
    )
    spot_merged = pd.DataFrame(merged_df.loc[:, "spot2"]).rename(
        columns={"spot2": "spot_merged"}
    )
    merged_df2 = pd.concat([spot_merged, spot3], axis=1)
    merged_df2.loc[merged_df2["spot_merged"].isna().values, "spot_merged"] = (
        merged_df2[merged_df2["spot_merged"].isna().values].loc[:, "spot3"].values
    )
    spot = merged_df2.loc[:, "spot_merged"].rename(columns={"spot_merged": "spot"})
    spot = pd.DataFrame(data=spot, index=spot.index, columns=["spot"]).reindex(total_drange)

    # Import des puissances
    p = c_hydro.get_node_calculated_timeseries(
        target_name="Coindre_T",
        param="production",
        start_date=start_date,
        end_date=end_date,
        scenario="productionplan",
    ).rename(columns={"value": "power"}).reindex(total_drange)

    # Import des unavails
    scen_unavail = "Default"
    unavail = c_hydro.get_node_calculated_timeseries(
        target_name="Coindre_T",
        param="unavailability",
        start_date=start_date,
        end_date=end_date,
        scenario=scen_unavail,
    ).rename(columns={"value": "unavail"}).reindex(total_drange)

    df = pd.concat(
        [
            i_gr,
            i_pr,
            p,
            valve_position,
            spot,
            unavail,
            v_gr,
            v_pr,
        ],
        axis=1,
    ).fillna(method="ffill")

    if write_csv:
        for k in df.keys():
            df.loc[:,k].to_csv(path_or_buf=os.path.join(csv_input_dir, k + ".csv"), header=True)




if __name__ == "__main__":
    api_key = '5bpodg6vmy18lqtq949u4psgh0mb5lfxg0bz326jmpxnma3w8r7tntb9y4j1hzlj'
    start = dt.datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)
    end = start + dt.timedelta(days=14)
    write_model_csv_inputs(hx_api_key=api_key, start_date=start, end_date=end, csv_input_dir=r"C:\Users\WH5939\Documents\coindre-model\src\coindre_optim\csv_input_test")


