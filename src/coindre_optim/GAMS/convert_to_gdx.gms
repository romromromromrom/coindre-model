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
         V_REALISED(i,tb)
         vpr(tb)
         vgr(tb)
;

$setGlobal CSV_INPUT_DIR C:\Users\WH5939\Documents\coindre-model\src\coindre_optim\csv_input_test
$setGlobal GDX_DIR C:\Users\WH5939\Documents\coindre-model\src\coindre_optim\csv_input_test
$setGlobal import_opts "useHeader=y index=1 ColCount=2 value=2 storeZero=y"


*************** CREATION OF THE SEPARTE GDX FILES ******************
$call csv2gdx input="%CSV_INPUT_DIR%\spot.csv" output="%GDX_DIR%\spot.gdx" id=spot %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\unavail.csv" output="%GDX_DIR%\unavail.gdx" id=unavail %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\inflows_gr.csv" output="%GDX_DIR%\inflows_gr.gdx" id=inflows_gr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\inflows_pr.csv" output="%GDX_DIR%\inflows_pr.gdx" id=inflows_pr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\vane_closed.csv" output="%GDX_DIR%\vane_closed.gdx" id=vane_closed %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\power.csv" output="%GDX_DIR%\power.gdx" id=power %import_opts%

$call csv2gdx input="%CSV_INPUT_DIR%\vgr.csv" output="%GDX_DIR%\vgr.gdx" id=vgr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\vpr.csv" output="%GDX_DIR%\vpr.gdx" id=vpr %import_opts%

********** CREATION OF THE FULL FILE ************

$gdxin "%GDX_DIR%\spot.gdx"
$load tb=Dim1 spot

$gdxin "%GDX_DIR%\inflows_gr.gdx"
$load inflows_gr

$gdxin "%GDX_DIR%\inflows_pr.gdx"
$load inflows_pr

$gdxin "%GDX_DIR%\unavail.gdx"
$load unavail

$gdxin "%GDX_DIR%\power.gdx"
$load P_REALISED=power

$gdxin "%GDX_DIR%\vane_closed.gdx"
$load VANE_REALISED=vane_closed

$gdxin "%GDX_DIR%\vpr.gdx"
$load vpr

$gdxin "%GDX_DIR%\vgr.gdx"
$load vgr

V_REALISED('gr',tb) = vgr(tb);
V_REALISED('pr',tb) = vpr(tb);


execute_unload "%GDX_DIR%\import_coopt.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED vpr vgr V_REALISED


*execute_unload "%GDX_DIR%\import_backtesting.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED

