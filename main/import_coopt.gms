SETS tb
     i /gr,pr/
;
PARAMETERS
         spot(tb)
         inflows_gr(tb)
         inflows_pr(tb)
         unavail(tb)
         P_REALISED(tb)
         VANE_REALISED(tb)
         zgr(tb)
         zpr(tb)
         DZ_REALISED(tb)
         Z_REALISED(i,tb)
         qgr(tb)
         qpr(tb)
         Q_REALISED(i,tb)
         V_REALISED(i,tb)
         vpr(tb)
         vgr(tb)
         spill_pr(tb)
         spill_gr(tb)
         wb_gr(tb)
         wb_pr(tb)
         WB_REALISED(i,tb)
         SPILL_REALISED(i,tb)
;

$setGlobal csv_data_dir C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0\input
$setGlobal input_gdx_dir C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0\gdx_files
$setGlobal import_opts "useHeader=y index=1 ColCount=2 value=2 storeZero=y"


*************** CREATION OF THE SEPARTE GDX FILES ******************
$call csv2gdx input="%csv_data_dir%\spot.csv" output="%input_gdx_dir%\spot.gdx" id=spot %import_opts%
$call csv2gdx input="%csv_data_dir%\unavail.csv" output="%input_gdx_dir%\unavail.gdx" id=unavail %import_opts%
$call csv2gdx input="%csv_data_dir%\inflows_gr.csv" output="%input_gdx_dir%\inflows_gr.gdx" id=inflows_gr %import_opts%
$call csv2gdx input="%csv_data_dir%\inflows_pr.csv" output="%input_gdx_dir%\inflows_pr.gdx" id=inflows_pr %import_opts%
$call csv2gdx input="%csv_data_dir%\vane_closed.csv" output="%input_gdx_dir%\vane_closed.gdx" id=vane_closed %import_opts%
$call csv2gdx input="%csv_data_dir%\power.csv" output="%input_gdx_dir%\power.gdx" id=power %import_opts%

$call csv2gdx input="%csv_data_dir%\zpr.csv" output="%input_gdx_dir%\zpr.gdx" id=zpr %import_opts%
$call csv2gdx input="%csv_data_dir%\zgr.csv" output="%input_gdx_dir%\zgr.gdx" id=zgr %import_opts%
$call csv2gdx input="%csv_data_dir%\dz.csv"  output="%input_gdx_dir%\dz.gdx"  id=dz %import_opts%


$call csv2gdx input="%csv_data_dir%\qgr.csv"  output="%input_gdx_dir%\qgr.gdx"  id=qgr %import_opts%
$call csv2gdx input="%csv_data_dir%\qpr.csv"  output="%input_gdx_dir%\qpr.gdx"  id=qpr %import_opts%

$call csv2gdx input="%csv_data_dir%\vgr.csv" output="%input_gdx_dir%\vgr.gdx" id=vgr %import_opts%
$call csv2gdx input="%csv_data_dir%\vpr.csv" output="%input_gdx_dir%\vpr.gdx" id=vpr %import_opts%

$call csv2gdx input="%csv_data_dir%\spill_gr.csv" output="%input_gdx_dir%\spill_gr.gdx" id=spill_gr %import_opts%
$call csv2gdx input="%csv_data_dir%\spill_pr.csv" output="%input_gdx_dir%\spill_pr.gdx" id=spill_pr %import_opts%

$call csv2gdx input="%csv_data_dir%\wb_gr.csv" output="%input_gdx_dir%\wb_gr.gdx" id=wb_gr %import_opts%
$call csv2gdx input="%csv_data_dir%\wb_pr.csv" output="%input_gdx_dir%\wb_pr.gdx" id=wb_pr %import_opts%

********** CREATION OF THE FULL FILE ************

$gdxin "%input_gdx_dir%\spot.gdx"
$load tb=Dim1 spot

$gdxin "%input_gdx_dir%\qgr.gdx"
$load qgr

$gdxin "%input_gdx_dir%\qpr.gdx"
$load qpr

$gdxin "%input_gdx_dir%\inflows_gr.gdx"
$load inflows_gr

$gdxin "%input_gdx_dir%\inflows_pr.gdx"
$load inflows_pr

$gdxin "%input_gdx_dir%\unavail.gdx"
$load unavail

$gdxin "%input_gdx_dir%\power.gdx"
$load P_REALISED=power

$gdxin "%input_gdx_dir%\vane_closed.gdx"
$load VANE_REALISED=vane_closed

$gdxin "%input_gdx_dir%\zgr.gdx"
$load zgr

$gdxin "%input_gdx_dir%\zpr.gdx"
$load zpr

$gdxin "%input_gdx_dir%\dz.gdx"
$load DZ_REALISED=dz

$gdxin "%input_gdx_dir%\vpr.gdx"
$load vpr

$gdxin "%input_gdx_dir%\vgr.gdx"
$load vgr

$gdxin "%input_gdx_dir%\spill_gr.gdx"
$load spill_gr

$gdxin "%input_gdx_dir%\spill_pr.gdx"
$load spill_pr

$gdxin "%input_gdx_dir%\wb_gr.gdx"
$load wb_gr

$gdxin "%input_gdx_dir%\wb_pr.gdx"
$load wb_pr



Z_REALISED('gr',tb) = zgr(tb);
Z_REALISED('pr',tb) = zpr(tb);
Q_REALISED('gr',tb) = qgr(tb);
Q_REALISED('pr',tb) = qpr(tb);
V_REALISED('gr',tb) = vgr(tb);
V_REALISED('pr',tb) = vpr(tb);
WB_REALISED('pr',tb) = wb_pr(tb);
WB_REALISED('gr',tb) = wb_gr(tb);
SPILL_REALISED('pr',tb) = spill_pr(tb);
SPILL_REALISED('gr',tb) = spill_gr(tb);

execute_unload "%input_gdx_dir%\import_coopt.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED Z_REALISED zgr zpr DZ_REALISED Q_REALISED qgr qpr vpr vgr V_REALISED WB_REALISED SPILL_REALISED


*execute_unload "%input_gdx_dir%\import_backtesting.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED Z_REALISED zgr zpr DZ

