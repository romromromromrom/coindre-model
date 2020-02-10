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

$setGlobal CSV_INPUT_DIR C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0\input
$setGlobal GDX_DIR C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0\gdx_files
$setGlobal import_opts "useHeader=y index=1 ColCount=2 value=2 storeZero=y"


*************** CREATION OF THE SEPARTE GDX FILES ******************
$call csv2gdx input="%CSV_INPUT_DIR%\spot.csv" output="%GDX_DIR%\spot.gdx" id=spot %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\unavail.csv" output="%GDX_DIR%\unavail.gdx" id=unavail %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\inflows_gr.csv" output="%GDX_DIR%\inflows_gr.gdx" id=inflows_gr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\inflows_pr.csv" output="%GDX_DIR%\inflows_pr.gdx" id=inflows_pr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\vane_closed.csv" output="%GDX_DIR%\vane_closed.gdx" id=vane_closed %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\power.csv" output="%GDX_DIR%\power.gdx" id=power %import_opts%

$call csv2gdx input="%CSV_INPUT_DIR%\zpr.csv" output="%GDX_DIR%\zpr.gdx" id=zpr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\zgr.csv" output="%GDX_DIR%\zgr.gdx" id=zgr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\dz.csv"  output="%GDX_DIR%\dz.gdx"  id=dz %import_opts%


$call csv2gdx input="%CSV_INPUT_DIR%\qgr.csv"  output="%GDX_DIR%\qgr.gdx"  id=qgr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\qpr.csv"  output="%GDX_DIR%\qpr.gdx"  id=qpr %import_opts%

$call csv2gdx input="%CSV_INPUT_DIR%\vgr.csv" output="%GDX_DIR%\vgr.gdx" id=vgr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\vpr.csv" output="%GDX_DIR%\vpr.gdx" id=vpr %import_opts%

$call csv2gdx input="%CSV_INPUT_DIR%\spill_gr.csv" output="%GDX_DIR%\spill_gr.gdx" id=spill_gr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\spill_pr.csv" output="%GDX_DIR%\spill_pr.gdx" id=spill_pr %import_opts%

$call csv2gdx input="%CSV_INPUT_DIR%\wb_gr.csv" output="%GDX_DIR%\wb_gr.gdx" id=wb_gr %import_opts%
$call csv2gdx input="%CSV_INPUT_DIR%\wb_pr.csv" output="%GDX_DIR%\wb_pr.gdx" id=wb_pr %import_opts%

********** CREATION OF THE FULL FILE ************

$gdxin "%GDX_DIR%\spot.gdx"
$load tb=Dim1 spot

$gdxin "%GDX_DIR%\qgr.gdx"
$load qgr

$gdxin "%GDX_DIR%\qpr.gdx"
$load qpr

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

$gdxin "%GDX_DIR%\zgr.gdx"
$load zgr

$gdxin "%GDX_DIR%\zpr.gdx"
$load zpr

$gdxin "%GDX_DIR%\dz.gdx"
$load DZ_REALISED=dz

$gdxin "%GDX_DIR%\vpr.gdx"
$load vpr

$gdxin "%GDX_DIR%\vgr.gdx"
$load vgr

$gdxin "%GDX_DIR%\spill_gr.gdx"
$load spill_gr

$gdxin "%GDX_DIR%\spill_pr.gdx"
$load spill_pr

$gdxin "%GDX_DIR%\wb_gr.gdx"
$load wb_gr

$gdxin "%GDX_DIR%\wb_pr.gdx"
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

execute_unload "%GDX_DIR%\import_coopt.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED Z_REALISED zgr zpr DZ_REALISED Q_REALISED qgr qpr vpr vgr V_REALISED WB_REALISED SPILL_REALISED


*execute_unload "%GDX_DIR%\import_backtesting.gdx" tb spot inflows_pr inflows_gr unavail P_REALISED VANE_REALISED Z_REALISED zgr zpr DZ

