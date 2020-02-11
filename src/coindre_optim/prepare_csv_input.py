import datetime as dt
import numpy as np
import pandas as pd
from . import pi_simple_client as psc
from .__init__ import TZ
import os

#############################################


def write_model_csv_inputs(
    PERSONAL_API_KEY, start_date, end_date, CSV_INPUT_DIR, write_csv=False,
):

    c = psc.Client(bypass_proxy=True)
    c_hydro = hx.Client(api_key=PERSONAL_API_KEY)

    I_gr_proposed = c_hydro.get_node_calculated_timeseries(
        target_name="Grande-Rhue_R",
        param="inflow",
        start_date=start_date,
        end_date=end_date,
        scenario="proposed_forecast",
    ).rename(columns={"value": "igr"})

    I_pr_proposed = c_hydro.get_node_calculated_timeseries(
        target_name="Petite-Rhue_R",
        param="inflow",
        start_date=start_date,
        end_date=end_date,
        scenario="proposed_forecast",
    ).rename(columns={"value": "ipr"})

    drange = pd.date_range(
        start=start_date,
        end=dt.datetime(
            I_gr_proposed.index[-1].year,
            I_gr_proposed.index[-1].month,
            I_gr_proposed.index[-1].day,
        )
        + dt.timedelta(days=1)
        - dt.timedelta(hours=1),
        freq="1h",
        tz=TZ,
    )
    I_gr_proposed = I_gr_proposed.reindex(drange).fillna(method="ffill")
    I_pr_proposed = I_pr_proposed.reindex(drange).fillna(method="ffill")

    I_gr_q50 = c_hydro.get_node_calculated_timeseries(
        target_name="Grande-Rhue_R",
        param="inflow",
        start_date=start_date,
        end_date=end_date,
        scenario="proposed_forecast_q50",
    ).rename(columns={"value": "igr_q50"})

    I_pr_q50 = c_hydro.get_node_calculated_timeseries(
        target_name="Petite-Rhue_R",
        param="inflow",
        start_date=start_date,
        end_date=end_date,
        scenario="proposed_forecast_q50",
    ).rename(columns={"value": "ipr_q50"})

    I_gr = I_gr_proposed.reindex(I_gr_q50.index)
    I_pr = I_pr_proposed.reindex(I_pr_q50.index)
    I_gr.loc[I_gr[I_gr.isna().values].index, :] = I_gr_q50[I_gr.isna().values].values
    I_pr.loc[I_pr[I_pr.isna().values].index, :] = I_pr_q50[I_pr.isna().values].values

    # Import de l'état de la vanne
    valve_position = c_hydro.get_parameter_timeseries_data(
        target="Petite-Rhue_R",
        parameter="valve_position",
        scenario="productionplan",
        start_date=start_date,
        end_date=end_date,
    )
    valve_position = (
        valve_position.rename(columns={"value": "valve"}).resample("1h").pad()
    )

    # import des débits
    tag = "FRCOINDR_2_____FLOW________MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    q_pr = df.set_index(df.keys()[0])
    q_pr = q_pr.rename(columns={"Value": "qpr"})

    tag = "FRCOINDR_1_____FLOW________MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    q_gr = df.set_index(df.keys()[0])
    q_gr = q_gr.rename(columns={"Value": "qgr"})

    # import des déversés
    tag = "FRCOINDDM2SP__1FLOW________MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    spill_pr = df.set_index(df.keys()[0])
    spill_pr = spill_pr.rename(columns={"Value": "spill_pr"})

    tag = "FRCOINDDM1SP__1FLOW________MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    spill_gr = df.set_index(df.keys()[0])
    spill_gr = spill_gr.rename(columns={"Value": "spill_gr"})

    # Import des débits réservés
    tag = "FRCOINDDM2_____FLOW_MIN_CW_MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    dr_pr = df.set_index(df.keys()[0])
    dr_pr = dr_pr.rename(columns={"Value": "dr_pr"})

    tag = "FRCOINDDM1_____FLOW_MIN_CW_MMB"
    resp = c.get_pi_summary_data(
        start_date, end_date, tag=tag, step="1h", type="Average"
    )
    df = psc.summary_resp_to_df(resp)
    dr_gr = df.set_index(df.keys()[0])
    dr_gr = dr_gr.rename(columns={"Value": "dr_gr"})

    # imports des côtes
    tag = "FRCOINDR_1CP__1ALT_________MMB"
    resp = c.get_interpolated_data(start_date, end_date, tag=tag, step="1h")
    df = psc._interpolated_resp_to_df(resp)
    z_gr = df.set_index(df.keys()[0])
    z_gr = z_gr.rename(columns={"Value": "zgr"})
    z_gr_norm = pd.DataFrame(z_gr.loc[:, "zgr"] - 686.28).rename(
        columns={"zgr": "zgr_norm"}
    )

    tag = "FRCOINDR_2CP__1ALT_________MMB"
    resp = c.get_interpolated_data(start_date, end_date, tag=tag, step="1h")
    df = psc._interpolated_resp_to_df(resp)
    z_pr = df.set_index(df.keys()[0])
    z_pr = z_pr.rename(columns={"Value": "zpr"})
    z_pr_norm = pd.DataFrame(z_pr.loc[:, "zpr"] - 684.7).rename(
        columns={"zpr": "zpr_norm"}
    )

    # Import volumes
    tag = "FRCOINDR_2_____VOL_________MMB"
    resp = c.get_interpolated_data(start_date, end_date, tag=tag, step="1h")
    df = psc._interpolated_resp_to_df(resp)
    v_pr = df.set_index(df.keys()[0])
    v_pr = v_pr.rename(columns={"Value": "vpr"})
    # conversion en m³
    v_pr = v_pr * 1e3

    tag = "FRCOINDR_1_____VOL_________MMB"
    resp = c.get_interpolated_data(start_date, end_date, tag=tag, step="1h")
    df = psc._interpolated_resp_to_df(resp)
    v_gr = df.set_index(df.keys()[0])
    v_gr = v_gr.rename(columns={"Value": "vgr"})
    v_gr = v_gr * 1e3

    # computation of the water level difference
    dz = pd.DataFrame(data=z_pr["zpr"] - z_gr["zgr"], columns=["dz"], index=z_pr.index)

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
    spot = pd.DataFrame(data=spot, index=spot.index, columns=["spot"])

    # Import des puissances
    P = c_hydro.get_node_calculated_timeseries(
        target_name="Coindre_T",
        param="production",
        start_date=start_date,
        end_date=end_date,
        scenario="productionplan",
    ).rename(columns={"value": "MW"})

    # Import des unavails
    scen_unavail = "Default"
    unavail = c_hydro.get_node_calculated_timeseries(
        target_name="Coindre_T",
        param="unavailability",
        start_date=start_date,
        end_date=end_date,
        scenario=scen_unavail,
    ).rename(columns={"value": "unavail"})

    # Convert to TIME ZONE BRUSSELS
    zgr2 = z_gr.tz_convert(TZ)
    zpr2 = z_pr.tz_convert(TZ)
    qgr = q_gr.loc[:, "qgr"].tz_convert(TZ)
    qpr = q_pr.loc[:, "qpr"].tz_convert(TZ)
    igr2 = I_gr["igr"].tz_convert(TZ)
    ipr2 = I_pr["ipr"].tz_convert(TZ)
    p2 = P.tz_convert(TZ)
    valve2 = valve_position["valve"].tz_convert(TZ)
    dz2 = dz.tz_convert(TZ)
    v_pr = v_pr.tz_convert(TZ)
    v_gr = v_gr.tz_convert(TZ)
    spill_pr2 = spill_pr.tz_convert(TZ).rename(columns={"Value": "spill_pr"})
    spill_gr2 = spill_gr.tz_convert(TZ).rename(columns={"Value": "spill_gr"})

    # computation of the water imbalance in the system taking into account the spilled waters
    vpr_t_plus_1 = pd.DataFrame(
        data=np.roll(v_pr, -1), index=v_pr["vpr"].index, columns=["Vt+1"]
    )
    WB_PR = -(
        (-I_pr["ipr"] + q_pr["qpr"] + spill_pr["spill_pr"])
        + (vpr_t_plus_1["Vt+1"] - v_pr["vpr"]) / 3600
    )
    WB_PR = pd.DataFrame(data=WB_PR, columns=["wb_pr"])
    vgr_t_plus_1 = pd.DataFrame(
        data=np.roll(v_gr, -1), index=v_gr["vgr"].index, columns=["Vt+1"]
    )
    WB_GR = -(
        (-I_gr["igr"] + q_gr["qgr"] + spill_gr["spill_gr"])
        + (vgr_t_plus_1["Vt+1"] - v_gr["vgr"]) / 3600
    )
    WB_GR = pd.DataFrame(data=WB_GR, columns=["wb_gr"])
    wb_pr2 = WB_PR.tz_convert(TZ).fillna(0)
    wb_gr2 = WB_GR.tz_convert(TZ).fillna(0)

    df = pd.concat(
        [
            spill_gr2,
            spill_pr2,
            wb_gr2,
            wb_pr2,
            qpr,
            qgr,
            igr2,
            ipr2,
            p2,
            valve2,
            spot["spot"],
            unavail["unavail"],
            zpr2,
            zgr2,
            dz2,
            v_gr,
            v_pr,
        ],
        axis=1,
    ).fillna(method="ffill")

    # transformation of the DataFrames into series
    igr2 = df["igr"]
    ipr2 = df["ipr"]
    p2 = df["MW"]
    vane = df["valve"]
    spot = df["spot"]
    unavail = df["unavail"]
    qpr = df["qpr"]
    qgr = df["qgr"]
    zgr = df["zgr"]
    zpr = df["zpr"]
    vpr = df["vpr"]
    vgr = df["vgr"]
    wb_gr2 = df["wb_gr"]
    wb_pr2 = df["wb_pr"]
    spill_gr2 = df["spill_gr"]
    spill_pr2 = df["spill_pr"]

    if write_csv == True:

        df.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "df.csv"), header=True)
        qgr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "qgr.csv"), header=True)
        qpr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "qpr.csv"), header=True)
        zgr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "zgr.csv"), header=True)
        zpr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "zpr.csv"), header=True)
        dz2.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "dz.csv"), header=True)
        igr2.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "inflows_gr.csv"), header=True
        )
        ipr2.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "inflows_pr.csv"), header=True
        )
        p2.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "power.csv"), header=True)
        vgr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "vgr.csv"), header=True)
        vpr.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "vpr.csv"), header=True)
        wb_gr2.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "wb_gr.csv"), header=True)
        wb_pr2.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "wb_pr.csv"), header=True)
        spill_gr2.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "spill_gr.csv"), header=True
        )
        spill_pr2.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "spill_pr.csv"), header=True
        )
        vane.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "vane_closed.csv"), header=True
        )
        spot.to_csv(path_or_buf=os.path.join(CSV_INPUT_DIR, "spot.csv"), header=True)
        unavail.to_csv(
            path_or_buf=os.path.join(CSV_INPUT_DIR, "unavail.csv"), header=True
        )


if __name__ == "__main__":
    PERSONAL_API_KEY = (
        "5bpodg6vmy18lqtq949u4psgh0mb5lfxg0bz326jmpxnma3w8r7tntb9y4j1hzlj"
    )
    start_date = dt.datetime(2020, 1, 1)
    number_of_days = 14
    end_date = start_date + dt.timedelta(days=number_of_days)
    common_dir = r"C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0"
    write_model_inputs(
        PERSONAL_API_KEY=PERSONAL_API_KEY,
        start_date=start_date,
        end_date=end_date,
        common_directory=common_dir,
        write_csv=True,
        plot_brut=False,
        plot_imbal_pr=False,
        plot_imbal_gr=False,
        moving_averages=False,
        plot_scatters=False,
    )
