*###############################################################################################
*################                                                             ##################
*################                 COindre OPTimisation tool                   ##################
*################                                                             ##################
*###############################################################################################
$setglobal XLS_OUTPUT 'C:\Users\WH5939\Documents\runs_gams\run_results.xlsx'
$setglobal GAMS_SRC_PATH 'C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\coindre-model\src\coindre_optim\GAMS'
$setglobal GDX_DIR 'C:\Users\WH5939\Documents\runs_gams\gdx_files'
$setglobal IMPORT_GDX_PATH 'C:\Users\WH5939\Documents\runs_gams\gdx_files\import_coopt.gdx'
$setglobal OUT_DIR 'C:\Users\WH5939\Documents\runs_gams\output'
$setglobal OUT_PATH 'C:\Users\WH5939\Documents\runs_gams\output\output.gdx'
$setglobal ALL_OUT_PATH 'C:\Users\WH5939\Documents\runs_gams\output\all_output.gdx'
$setglobal PZ_PATH 'C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\coindre-model\src\coindre_optim\GAMS\power_zones.gdx'
$setglobal BATHY_PATH 'C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\coindre-model\src\coindre_optim\GAMS\bathymetry.gdx'
$setglobal ADDUCTION_PATH 'C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\coindre-model\src\coindre_optim\GAMS\adduction_planes.gdx'
* Default options in gams
$setglobal OUT_NAME output_COOPT
$setglobal MIP_GAP 0.001
$setglobal RUN_TIME_LIMIT 2000
$setglobal NO_TB_FILTER 1
$setglobal ENABLE_RESERVED_FLOW_RATE 1
$setglobal N_DAYS 2
$setglobal CURRENT_TIME 16
$setglobal WARM_UP 1
$setglobal REFINED_HYDRAULICS 1
$setglobal FILTER_UC_SCHEDULE 1
$setglobal LOCK_PRODUCTION_PLAN 24
$setglobal NON_LINEAR_EFF 1
$setglobal ACTI_SLACKS 1
$setglobal ACTI_WB_SLACKS 0
$setglobal ALLO_SPILL 1
$setglobal DZ_COMP_SSTR 1
$setglobal CORR_FLO 0.3
$setglobal QTOT_THRESH_SSTR 15
$setglobal QTOT_THRESH_TRANS 10
$setglobal delta_V 2
$setglobal PCT_START 0
$setglobal PCT_END 1
$setglobal VOLUME_INIT_CONDITIONS 1
$setglobal V_INI_GR  1500000
$setglobal V_INI_PR  250000
$setglobal RUN_NUM 2
$setglobal INFLOWS_FACT_GR 1
$setglobal INFLOWS_FACT_PR 1
$setglobal EFF_TURB 0.22

*---- options for simulation
* General config
scalar activate_slacks 'if =1 the Volume slacks are allowed to be used for this run ' /%ACTI_SLACKS%/;
scalar activate_wb_slacks 'if = 1 the water balance slacks will be used' /%ACTI_WB_SLACKS%/;
scalar allow_spilling /%ALLO_SPILL%/;
* General hydraulics
scalar inflows_factor_PR 'impacts the inflows' /%INFLOWS_FACT_GR%/;
scalar inflows_factor_GR 'impacts the inflows' /%INFLOWS_FACT_PR%/;
scalar tol_vol 'minimal volume in pr and GR is raised by tol_vol and the change of power volumes are raised by this value too in order to have a plan that complies with the OURS, unit is in [scaling_volume*m³]' /%delta_V%/
* Start-Up and Shut-Down
scalar spill_costs 'in euros per m^3' /1/;
scalar start_up_costs 'in euros/occurence' /10/;
scalar vane_costs    'in euros/occurence' /100/;
scalar activate_su 'include SU and SD costs for the turbine in the objective function' /1/;
scalar activate_su_vane 'include SU and SD costs for the vane in the objective function' /1/;
* Transfer
scalar qtot_lim_transfer /%QTOT_THRESH_TRANS%/;
scalar dz_corr_sstr 'allows correction in dz of qsstr' /%DZ_COMP_SSTR%/;
scalar corr_flow 'qsstr =(approx.)= (1/3 or 2/3)*Qtot + dz*corr_flow if qtot>q_lim_corr_sstr'/%CORR_FLO%/;
scalar q_lim_corr_sstr 'for qtot<q_lim_corr_sstr there is no correction of qsstr' /%QTOT_THRESH_SSTR%/;
* Time horizon definition
scalar no_tf_filter /%NO_TB_FILTER%/;
scalar pct_start 'the model will start solving for ord(tb)>=pct_start*card(tb)'  ;  pct_start = %PCT_START% ;
scalar pct_end 'the model will stop  solving for ord(tb)<=pct_end*card(tb)'  ;      pct_end = %PCT_END% ;
* Display options
scalar volume_IC 'set to 1 by default, ICs are imposed in initial volumes without bathymetry conversion' /%VOLUME_INIT_CONDITIONS%/;
scalar scaling_volumes 'constant that scale the volumes in the display window' /1E4/;
* Backtesting of the hydraulic behaviour
scalar backtesting_hydraulics 'set it to 1 if you want to impose q1,q2 and vane' /0/;
scalar backtesting_optim 'set to 1 if you want to output the realized data with the results' /1/;
*----

*---- sets declaration
sets
tb       'time buckets used in the optimization problem (will be loaded from HDX import data file)'
tf(tb)   'filters the set tb for the time buckets defined by pct_start and pct_end'
zone     'various operating region for Coindre Hydro Power plant' /"19MW","25MW","34MW","36MW"/
i        'basin identifier'                                       /gr,pr/
cote_pr  'water height intervals in Petite-Rhue'                  /"684.70","686.00","687.00","689.00","691.80"/
cote_gr  'water height intervals in Grande-Rhue'                  /"686.28","689.00","691.60"/
case     'the different flow cases "Without transfer" , "Grande-Rhue to Petite-Rhue" , "Petite-Rhue to Grande-Rhue"' /sstr,grpr,prgr/
;
**  OPTIONS FOR THE SOLVE STATEMENT **
set refine_transfer(tb);
sets first_order(tb),second_order(tb);
sets additive(tb),addi_refined(tb)'addi_refined used 2segs on GR and 4 segs in PR',ours_bat(tb)'replicates bathy of shemWa exactly';
** sets FOR THE DIFFERENT GRANULARITIES
set DAILY(tb) 'This is a filter for the first 24 TBs';
set THREE_DAILY(tb) 'This is a filter for the first 72 TBs';
set WEEKLY(tb) 'This is a filter for the first Week TBs';
set MONTHLY(tb) 'This is a filter for the first Month TBs';
parameter water_value(i) /gr 0,pr 0/;
scalars first_time,last_time;

*###############################################################################################
*################                                                             ##################
*################                              INPUTS                         ##################
*################                                                             ##################
*###############################################################################################
* Dynamic inputs (Hydrolix)
parameter
          spot(tb)
          inflows_gr(tb)
          inflows_pr(tb)
          INFLOW(i,tb)
          unavail(tb)
          P_REALISED(tb)
          VANE_REALISED(tb)
          Z_REALISED(i,tb)
          DZ_REALISED(tb)
          Q_REALISED(i,tb)
          V_REALISED(i,tb)
;

* read the gdx input for gams
$gdxin %IMPORT_GDX_PATH%
$load tb spot unavail inflows_pr inflows_gr P_REALISED VANE_REALISED Z_REALISED DZ_REALISED Q_REALISED V_REALISED

parameter Itot(tb),INFLOW(i,tb);
inflows_pr(tb) = inflows_factor_PR*inflows_pr(tb);
inflows_gr(tb) = inflows_factor_GR*inflows_gr(tb);
INFLOW(i,tb)= (inflows_gr(tb))$(ord(i) = 1) + (inflows_pr(tb))$(ord(i) = 2);
Itot(tb) = inflows_pr(tb) + inflows_gr(tb);

* initial conditions
parameter Vini(i) 'initial conditions';
scalars U_ini , Vane_ini , y_ini , z_ini;
;

*--------------------------------------- Hard written inputs  ----------------------------------
*---- Power Zones
parameter VolPZ_GR(cote_gr)   'Volumes of Grande-Rhue at the breakpoints of the power characteristic' ;
parameter VolPZ_PR(cote_pr)   'Volumes of Petite-Rhue at the breakpoints of the power characteristic' ;
$gdxin %PZ_PATH%
$load VolPZ_PR VolPZ_GR
parameter P_max(zone) 'Maximum available power in the different zones of the operating chart'   ;
P_max(zone) = 19$(ord(zone)=1) + 25$(ord(zone)=2 ) + 34$(ord(zone)=3) + 36$(ord(zone) = 4);

*---- Bathymetry
sets ptBat    'Point index for Petite-Rhue s bathymetry';
parameter Bathy(i,ptBat,*)  'Volume - Water level characteristic in the basins';
$gdxin %BATHY_PATH%
$load ptBat Bathy

*---- Adduction domains imported parameter
set alpha 'the equation of the segments are written sg(dz) = dz*alpha1 + alpha2 '
    var   '[q , dz , 1] is the vector of variables'
    index 'just an index'
    k1      'set that is used for discretization of the double adduction function in Qtot'
    k2      'set that is used for discretization of the double adduction function in dz'
    zone_add(case,k1,k2) 'domains of the different trasnfer regions of the qtot - dz characteristic'
    plan_index(case,index)'same function as seg_index but for the number of approximation plans in the transfer characteristic for each transfer case'
    seg_index(case,index) 'serves to give the maximal indexes for different cases, i.e if there is a different number of segments for prgr and for grpr the filter serves'
;
scalars j1,j2,dz_threshold;
parameter seg(case,alpha,index) 'coefficients of the segments that outline the transfer domains'
           n(var,case,index)     'coefficients of the transfer planes'
           q1(k1,k2)             'exact transfer characteristic'
           q1_approx(k1,k2)      'approximated transfer characteristic '
;
$gdxin %ADDUCTION_PATH%
$load var dz_threshold alpha index seg n j1 j2 k1 k2 q1 q1_approx plan_index seg_index
$load  zone_add = zone



*##########################################################################################################
*###########################                                             ##################################
*###########################                   Variables                 ##################################
*###########################                                             ##################################
*##########################################################################################################
* ----------- Declaration of variables  -------------------------------------------------------------------
set sign /'+','-'/;
set seg_bat_refined /segBatRef1*segBatRef4/;
binary variables u(tb)                   'ON/OFF state variable '
                 x(zone,tb)              'this is the variable that tells you what is the maximal power allowed in each region'
                 vane_closed(tb)         'this variable is 1 if the vane is closed'
                 sign_qtot(tb)           '1 if qtot >= qtot trans_lim 0 if qtot<= qtot trans_lim  '
                 seg1_bathy(i,tb)        'is 1 if the concerned segment of the piecewise bathymetry is active'
                 seg_bathy_refined(i,seg_bat_refined,tb) '=1 if the segment is active in the refined additive formulation of bathymetry'
                 seg_q1_dz(sign,tb)      'These two variables + and - are exclusive to each other and give the active segment of the transfer characteristic'
                 dz_loc(sign,tb)         'These two binaries + and - are exclusive to each other by definition and serve to define q1trans additively by adding small corrections '
;

variables p(tb)            'Power of the turbine in [MW]'
          v(i,tb)          'Volume of the reservoirs is usualy positive but slack variables allow it to be negative.'
          su(tb)           'start up variable, is forced to 1 when there is a start up, note that the start up behaves just like a binary eventhough it is not one'
          sd(tb)           'start up variable, is forced to 1 when there is a shutdown, note that the start up behaves just like a binary eventhough it is not one'
          su_vane(tb)      'is forced to 1 if the vane is closed'
          sd_vane(tb)      'is forced to 1 if the vane is opened'
          pSUP(tb)         'Time dependent power upper bound'
          pINF(tb)         'Time dependent lower upper bound'
          q1tr_avg(tb)      'averaged value in time interval [tb;tb+1[ of transfer flow rate '
          gradient(i,tb)   'is the gradient of the water balance equation'
          q_sstr(i,tb)     'flow rate in m³/s in each basin in the problem without transfer'
          q1_trans(tb)     'flow rate that transfers between GR and PR is taken >0 for a transfer from GR to PR, this is an instantaneous value, (look at q1tr_avg for the integrated value)'
          q1_trans_add(sign,tb)'components of q1_trans in the additive formulation'
          z(i,tb)          'free surface water level @GR'
          z_add(i,tb)      'correction for the V to z linear equation in the additive formulation'
          z_add_ref(i,seg_bat_refined,tb) 'corrections on the bathymetry in the additive refined formulation'
          qtot(tb)         'Total flow rate going out of the system'
          spill(i,tb)      'spilled flow in m³/s in Petite-Rhue from the basins'
          dz(tb)           'difference in free surface water levels in [m]'
          of               'Objective function includes start up costs and slack variables'
          pnl              'Profit is a sum of the energy sold on every time bucket through the simulation'
          C_slacks         'total cost of slacks'
          C_su             'total start_up costs'
          C_spill          'total cost of spilling, meant to help the model converge faster'
          q_reserved(i,tb) 'PR has a reserved flow rate of approx. 0.3 m³/s and GR 0.6-0.7 m³/s'
;

*---------------------------          slacks        ------------------------------------------------------
positive variables slack_Vmin(i,tb),slack_Vmax(i,tb) 'slacks allow us to look at the results even when runs are failed, hte model will try at any cost not to activate them'
                   slack_wb_neg(i,tb),slack_wb_pos(i,tb) 'slacks in the water balance equation'
                   su(tb)           'start up variable, is forced to 1 when there is a start up, note that the start up behaves just like a binary eventhough it is not one'
                   sd(tb)           'start up variable, is forced to 1 when there is a shutdown, note that the start up behaves just like a binary eventhough it is not one'
                   su_vane(tb)      'is forced to 1 if the vane is closed'
                   sd_vane(tb)      'is forced to 1 if the vane is opened'

;
*##########################################################################################################
*###########################                                             ##################################
*###########################               INITIAL CONDITIONS            ##################################
*###########################                                             ##################################
*##########################################################################################################
Scalars Pmax /36/
        Pmin /10/;
Pmin$(backtesting_hydraulics=1) = -5;
pSUP.up(tb) = Pmax;   pSUP.lo(tb) = 0;
pINF.up(tb) = Pmax;   pINF.lo(tb) = 0;
p.up(tb)    = Pmax;   p.lo(tb)    = 0;
****** sometimes the flow rates are negative because of numerical imprecisions ********
p.fx(tb)$(backtesting_hydraulics=1) = max(sum(i,Q_REALISED(i,tb))*%EFF_TURB%*3600/1000,0);
vane_closed.fx(tb)$(backtesting_hydraulics=1) = [1]$[VANE_REALISED(tb)<1];

Scalars Vmax_gr 'water level corresponding 692.0 mNGF' /1593000/
        Vmin_gr /0/
        Vmax_pr 'water level corresponding 693.0 mNGF'/264000/
        Vmin_pr /0/
;
z_add.lo(i,tb) = -100;z_add.up(i,tb)=100;

scalars Qtot_max /55/
        Qtot_min 'minimal value of Qtot in operations' /4.4/
;
Qtot_min$(backtesting_hydraulics)=-5;



qtot.up(tb) = Qtot_max;   qtot.lo(tb)$(backtesting_hydraulics=0) = 0; qtot.lo(tb)$(backtesting_hydraulics=1) = -5;
q_sstr.up('pr',tb) = 1/3*Qtot_max ;  q_sstr.lo('pr',tb) = 0;
q_sstr.up('gr',tb) = Qtot_max ;      q_sstr.lo('gr',tb) = 0;
q1_trans.up(tb) = Qtot_max; q1_trans.lo(tb) = -Qtot_max;
q1_trans_add.up(sign,tb)=Qtot_max; q1_trans_add.lo(sign,tb)=-Qtot_max;

spill.up('pr',tb) = 25 ; spill.up('gr',tb) = 25 ;
spill.lo('pr',tb) = 0  ;spill.lo('gr',tb) = 0  ;

spill.fx(i,tb)$(not allow_spilling=1)=0;

slack_wb_neg.fx(i,tb)$(activate_wb_slacks=0)=0;
slack_wb_pos.fx(i,tb)$(activate_wb_slacks=0)=0;

scalars DZ_MAX  /7/
        DZ_MIN  /-7/
;
dz.up(tb) = DZ_MAX;
dz.lo(tb) = DZ_MIN;

z.fx('gr',tb)$(ord(tb)=floor(pct_start*card(tb)) and volume_IC=0) = Z_REALISED('gr',tb);
z.fx('pr',tb)$(ord(tb)=floor(pct_start*card(tb)) and volume_IC=0) = Z_REALISED('pr',tb);
v.fx('gr',tb)$(ord(tb)=1+0*floor(pct_start*card(tb)) and volume_IC=1) = V_REALISED('gr',tb);
v.fx('pr',tb)$(ord(tb)=1+0*floor(pct_start*card(tb)) and volume_IC=1) = V_REALISED('pr',tb);

slack_Vmax.fx('gr',tb)$(activate_slacks=0) = 0 ;
slack_Vmin.fx('gr',tb)$(activate_slacks=0) = 0 ;
slack_Vmax.fx('pr',tb)$(activate_slacks=0) = 0 ;
slack_Vmin.fx('pr',tb)$(activate_slacks=0) = 0 ;



*##########################################################################################################
*###########################                                             ##################################
*###########################                      MODEL                  ##################################
*###########################                                             ##################################
*##########################################################################################################
*---- DECLARATION
equations
EQ_SU_U                    'forces the value of the start up variable to 1'
EQ_SD_U                    'forces the value of the shutdown of u to 1 '
EQ_SU_VANE_CLOSED          'forces the value of the '
EQ_SD_VANE_CLOSED          'forces the value of the start up vane to 1'
EQ_UNAVAIL_U               'U=0 if unavailability > 99%'
EQ_POWER_ZONES_EXCLUSIVITY 'choose 1 of the many power zones that are defined in the problem'
EQ_VANE_CLOSED             'if the vane is closed then only the 19MW regime is available'

EQ_PZ_WATER_LEVELS   'all of the water levels power zones constraints condensed into one simple equation'
EQ_PZ_REGIME_36MW    'in order to have a double water level necessity to enable the 36MW power regime it is better to add a single constraint on x36 than creating another binary variable'

EQ_P_UP_LIM1,  EQ_P_UP_LIM2,  EQ_P_LO_LIM1,  EQ_P_LO_LIM2   'definition of time dependent ranges for p(tb)'

EQ_QTOT_UP_LIM,EQ_QTOT_LO_LIM   'definition of the time dependant bounds for qtot(tb)'

EQ_QTOT_DEF          'Qtot is at least equal to the theoretical expression, technically the bound will be reached because qtot makes the water volume decrease so it will try to use the less water possible '
EQ_QTOT_NON_LINEAR_EFF_1  'a 4 segments max-convex definition of the total flow rate is adopted in order to represent the non linear efficiency'
EQ_QTOT_NON_LINEAR_EFF_2
EQ_QTOT_NON_LINEAR_EFF_3
EQ_QTOT_NON_LINEAR_EFF_4

EQ_QSSTR_GR              'the flow rate in Grande Rhue is proportional to the total outflow (true for Qtot > 20m³/s)'
EQ_QSSTR_GR_VANE_CLOSED  'if the vane is closed qgr >= qtot'
EQ_QSSTR_PR              'the flow rate in Petite-Rhue is proportinal total outflow (true for Qtot > 20m³/s)'

EQ_QSSTR_NODAL_BALANCE   'when the turbine is unavailable the basins must spill, thus the flow rates have to be forced to 0'

EQ_DZ_SEGMENT_LOCALISATION_NEG_ON   'computation of the right segment to work on for the piecewise linear approximatoin of the q1trans instantaneous'
EQ_DZ_SEGMENT_LOCALISATION_NEG_OFF  'computation of the right segment to work on for the piecewise linear approximatoin of the q1trans instantaneous'
EQ_DZ_SEGMENT_LOCALISATION_POS_ON   'computation of the right segment to work on for the piecewise linear approximatoin of the q1trans instantaneous'
EQ_DZ_SEGMENT_LOCALISATION_POS_OFF  'computation of the right segment to work on for the piecewise linear approximatoin of the q1trans instantaneous'

EQ_Q_TRANS_COMPONENTS_NEG_UP        'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_NEG_LO        'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_NEG_UP_OFF    'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_NEG_LO_OFF    'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'

EQ_Q_TRANS_COMPONENTS_POS_UP        'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_POS_LO        'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_POS_UP_OFF    'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'
EQ_Q_TRANS_COMPONENTS_POS_LO_OFF    'calculation of the components of q1trnas in the additive formualtion of the piecewise linear approximation'

EQ_Q_TRANS_ADDITION                 'computation of qtr = f(dz,Qtot), approximation using three segments.'

EQ_QTOT_LIM_TRANS_ON     'There is no transfer when Qtot is over 20m³/s so the corresponding binaries have to be shut off accordingly'
EQ_QTOT_LIM_TRANS_OFF    'complementary equation of the one above'

EQ_QTR_AVG_VANE_OFF_UP   'if vane is closed in the time period t in [tb,tb+1[ then the average transfer is 0'
EQ_QTR_AVG_VANE_OFF_LO   'same'
EQ_QTR_AVG_QTOT_OFF_UP   'if qtot is >20m³/s on interval t in [tb,tb+1[ then no transfer can happen in this time period'
EQ_QTR_AVG_QTOT_OFF_LO   'same'
EQ_QTR_AVG_DEF_UP        'defintion of the average(qtr_avg(tb) = average(q1tr instantaneous, t in [tb,tb+1[)   ) transfer flow rate'
EQ_QTR_AVG_DEF_LO        'same'




EQ_V_UP_SLACK     'Vmax can be exceeded at a cost of 1E12 €/m³'
EQ_V_LO_SLACK     'v can be under Vmin at a cost of 1E12€/m³'
EQ_WATER_BALANCE_GRADIENT 'computation of the DV(i,tb)/DT that is used in the water balance equation to calculate v(t+1) from v(t)'
EQ_WATER_BALANCE     'v@t+1 is maximum equal to the water balance equation, the bound is tight because water has value and the solver will take as much of it as possible'
EQ_SPILL             'definition of the spill in Grande-Rhue'


EQ_BATHY_SEG_1_ON                     'activates the binary seg1_pr'
EQ_BATHY_SEG_1_OFF                    'de-activates the binary seg1_pr'
EQ_BATHY_REF_SEG_ON                   'calculation of the binaries for refined bathymetry'
EQ_BATHY_REF_SEG_OFF                  'calculaion  of the binaries for refined bathymetry'
EQ_Z_ADD_REFINED_UP_ON                'formulas for the corrections on the bathymetry'
EQ_Z_ADD_REFINED_LO_ON                'formulas for the corrections on the bathymetry'
EQ_Z_ADD_REFINED_UP_OFF               'turn the corrections off when they are not needed anymore'
EQ_Z_ADD_REFINED_LO_OFF               'turn the corrections off when they are not needed anymore'


EQ_Z_ADD_UP_ON       'equation for the additive formulation of the z'
EQ_Z_ADD_UP_OFF      'equation for the additive formulation of the z'
EQ_Z_ADD_LO_ON       'equation for the additive formulation of the z'
EQ_Z_ADD_LO_OFF      'equation for the additive formulation of the z'
EQ_CONVERSION_V_TO_WATER_LEVELS_ADD_UP 'z is the sum of a linear function + a correction that occurs only after the breakpoint'
EQ_CONVERSION_V_TO_WATER_LEVELS_ADD_LO 'z is the sum of a linear function + a correction that occurs only after the breakpoint'
EQ_DEF_DZ            'Calculation of dz according to the different z'

EQ_DEF_PNL           'Classical definition of the PNL (more like a profit at the moment 2019 - 17th - oct'
EQ_DEF_SLACKS_COST   'Slacks are a useful debug tool, they allow us to access the results of a run that would have otherwise failed'
EQ_DEF_SPILL_COST    'definition of the total spilling cost: makes sense in Coindre since every spilling episode entails tedious administrative procedures with the local authorities'
EQ_DEF_SU_SD_COST    'Start up total cost is proprotional to the number of start-ups'
EQ_DEF_OF            'Objective function is a weighed sum of todays profits and the value of the remaining water at the end of the optimization period'
;



*---- MODEL FORMULATION
*********************     LOGICAL EQUATIONS   ****************************************************************************
EQ_SU_U(tb)$(ord(tb)<=card(tb)-1 and activate_su and tf(tb)) ..                                   su(tb) =g= u(tb+1)-u(tb);
EQ_SD_U(tb)$(ord(tb)<=card(tb)-1 and activate_su and tf(tb) and no) ..                            sd(tb) =g= -(u(tb+1)-u(tb));
EQ_SU_VANE_CLOSED(tb)$(ord(tb)<=card(tb)-1 and activate_su_vane and tf(tb)) ..  su_vane(tb) =g=  vane_closed(tb+1)-vane_closed(tb);
EQ_SD_VANE_CLOSED(tb)$(ord(tb)<=card(tb)-1 and activate_su_vane and tf(tb)) ..  sd_vane(tb) =g= -(vane_closed(tb+1)-vane_closed(tb));
EQ_UNAVAIL_U(tb)$(tf(tb)and backtesting_hydraulics=0) ..                                 100*unavail(tb) - 99 =l= (1-u(tb));
EQ_POWER_ZONES_EXCLUSIVITY(tb)$(tf(tb)and backtesting_hydraulics=0) ..                   sum(zone,x(zone,tb)) =l= u(tb);
EQ_VANE_CLOSED(tb)$(tf(tb)and backtesting_hydraulics=0) ..          sum(zone$(ord(zone)>1),x(zone,tb)) =l= 3*(1-vane_closed(tb));

EQ_PZ_WATER_LEVELS(tb+1)$(tf(tb)and backtesting_hydraulics=0 and (ord(tb)>%LOCK_PRODUCTION_PLAN%)) ..  1E4*x('19MW',tb) + (1E4 + VolPZ_PR("686.00")+ tol_vol*scaling_volumes)*x('25MW',tb)
                                                                                                    + (1E4 + VolPZ_PR("687.00")+ tol_vol*scaling_volumes)*x('34MW',tb)
                                                                                                    + (1E4 + VolPZ_PR("689.00")+ tol_vol*scaling_volumes)*x('36MW',tb)  =l= 1E4 + v('pr',tb+1) ;

EQ_PZ_REGIME_36MW(tb+1)$(tf(tb)and backtesting_hydraulics=0)..    x('36MW',tb)*(VolPZ_GR("689.00")+ tol_vol*scaling_volumes) =l= v('gr',tb+1) ;


*********************     POWER DEFINITION    ****************************************************************************
EQ_P_UP_LIM1(tb)$(tf(tb)and backtesting_hydraulics=0) ..                   p(tb) =l= pSUP(tb);
EQ_P_LO_LIM1(tb)$(tf(tb)and backtesting_hydraulics=0) ..                   p(tb) =g= pINF(tb);
EQ_P_UP_LIM2(tb)$(tf(tb) and backtesting_hydraulics=0) ..                  pSUP(tb) =l= sum(zone,P_max(zone)*x(zone,tb))*(1-unavail(tb));
EQ_P_LO_LIM2(tb)$(tf(tb)and backtesting_hydraulics=0) ..                   pINF(tb) =g= Pmin*u(tb);

********************  POWER TO FLOW TRANSFER FUNCTION IN THE SSTR CASE ********************************************************************
EQ_QTOT_DEF(tb)$(tf(tb)) ..                                                qtot(tb) =G= 1000*p(tb)/%EFF_TURB%/3600;
EQ_QTOT_NON_LINEAR_EFF_1(tb)$(tf(tb) and %NON_LINEAR_EFF%) ..              qtot(tb) =G= 0.964506173*p(tb) + 5.787037037 - Qtot_max*(1-u(tb));
EQ_QTOT_NON_LINEAR_EFF_2(tb)$(tf(tb) and %NON_LINEAR_EFF%) ..              qtot(tb) =G= 1.467061149*p(tb) - 3.258952534 ;
EQ_QTOT_NON_LINEAR_EFF_3(tb)$(tf(tb) and %NON_LINEAR_EFF%) ..              qtot(tb) =G= 1.660878863*p(tb) - 7.910577679 ;
EQ_QTOT_NON_LINEAR_EFF_4(tb)$(tf(tb) and %NON_LINEAR_EFF%) ..              qtot(tb) =G= 1.958733425*p(tb) - 18.03763277 ;

EQ_QTOT_UP_LIM(tb)$(tf(tb) and backtesting_hydraulics=0) ..                      qtot(tb) =l= Qtot_max*u(tb);
EQ_QTOT_LO_LIM(tb)$(tf(tb) and backtesting_hydraulics=0) ..                      qtot(tb) =g= Qtot_min*u(tb);

EQ_QSSTR_NODAL_BALANCE(tb)$(tf(tb)) ..                    qtot(tb) =e= q_sstr('pr',tb) + q_sstr('gr',tb);
EQ_QSSTR_GR(tb)$(tf(tb)) ..                        q_sstr('gr',tb) =g= n('qt','sstr','index1')*qtot(tb)+[-corr_flow*dz(tb)]$(dz_corr_sstr=1) - Qtot_max*(1-u(tb));

EQ_QSSTR_GR_VANE_CLOSED(tb)$(tf(tb)) ..            q_sstr('gr',tb) =g= qtot(tb) - (1 - vane_closed(tb))*Qtot_max;
EQ_QSSTR_PR(tb)$(tf(tb)) ..                        q_sstr('pr',tb) =g= (1-n('qt','sstr','index1'))*qtot(tb)+ [corr_flow*dz(tb)]$(dz_corr_sstr=1) - Qtot_max*vane_closed(tb)- Qtot_max*(1-u(tb));

********************  TRANSFER  ************************************************************************************
scalars
         transfer_flow_corrected /-1.5486/
         intersect_flow  /1.75/
         DZ_0 /0.266630/
;
parameter flow_0(tb);flow_0(tb) = -8.112;

* computation of the instantaneous flow rate as a function of the water height difference
EQ_DZ_SEGMENT_LOCALISATION_NEG_ON(tb)$(tf(tb)and refine_transfer(tb)) ..          -dz_loc('-',tb)*DZ_MAX/DZ_0  =l= dz(tb)/DZ_0 -  (-1);
EQ_DZ_SEGMENT_LOCALISATION_NEG_OFF(tb)$(tf(tb)and refine_transfer(tb))..        (1-dz_loc('-',tb))*DZ_MAX/DZ_0 =g= dz(tb)/DZ_0 -  (-1);
EQ_DZ_SEGMENT_LOCALISATION_POS_ON(tb)$(tf(tb)and refine_transfer(tb))..             dz_loc('+',tb)*DZ_MAX/DZ_0 =g= dz(tb)/DZ_0 -    1;
EQ_DZ_SEGMENT_LOCALISATION_POS_OFF(tb)$(tf(tb)and refine_transfer(tb))..       -(1-dz_loc('+',tb))*DZ_MAX/DZ_0 =l= dz(tb)/DZ_0 -    1;

EQ_Q_TRANS_COMPONENTS_NEG_UP(tb)$(tf(tb)and refine_transfer(tb))..       q1_trans_add('-',tb) =l= -flow_0(tb)*dz(tb) +transfer_flow_corrected*dz(tb) + intersect_flow+ Qtot_max*(1-dz_loc('-',tb));
EQ_Q_TRANS_COMPONENTS_NEG_LO(tb)$(tf(tb)and refine_transfer(tb))..       q1_trans_add('-',tb) =g= -flow_0(tb)*dz(tb) +transfer_flow_corrected*dz(tb) + intersect_flow - Qtot_max*(1-dz_loc('-',tb));
EQ_Q_TRANS_COMPONENTS_NEG_UP_OFF(tb)$(tf(tb)and refine_transfer(tb))..   q1_trans_add('-',tb) =l=  Qtot_max*(dz_loc('-',tb));
EQ_Q_TRANS_COMPONENTS_NEG_LO_OFF(tb)$(tf(tb)and refine_transfer(tb))..   q1_trans_add('-',tb) =g= -Qtot_max*(dz_loc('-',tb));

EQ_Q_TRANS_COMPONENTS_POS_UP(tb)$(tf(tb)and refine_transfer(tb) )..       q1_trans_add('+',tb) =l= -flow_0(tb)*dz(tb) +transfer_flow_corrected*dz(tb)- intersect_flow + Qtot_max*(1-dz_loc('+',tb));
EQ_Q_TRANS_COMPONENTS_POS_LO(tb)$(tf(tb)and refine_transfer(tb))..        q1_trans_add('+',tb) =g= -flow_0(tb)*dz(tb) +transfer_flow_corrected*dz(tb)- intersect_flow - Qtot_max*(1-dz_loc('+',tb));
EQ_Q_TRANS_COMPONENTS_POS_UP_OFF(tb)$(tf(tb)and refine_transfer(tb))..    q1_trans_add('+',tb) =l= Qtot_max*(dz_loc('+',tb));
EQ_Q_TRANS_COMPONENTS_POS_LO_OFF(tb)$(tf(tb)and refine_transfer(tb))..    q1_trans_add('+',tb) =g= -Qtot_max*(dz_loc('+',tb));

EQ_Q_TRANS_ADDITION(tb)$(tf(tb)) ..             q1_trans(tb) =e= flow_0(tb)*dz(tb)
                                                                 + [q1_trans_add('-',tb)
                                                                 +  q1_trans_add('+',tb)]$(refine_transfer(tb)) ;

set sqrt_domain(tb),simple(tb);sqrt_domain(tb) =no;simple(tb)=yes;
EQ_QTOT_LIM_TRANS_ON(tb)$(tf(tb)) ..          sign_qtot(tb)*Qtot_max  =g= qtot(tb) - [qtot_lim_transfer];
EQ_QTOT_LIM_TRANS_OFF(tb)$(tf(tb))..     -(1-sign_qtot(tb))*Qtot_max  =l= qtot(tb) - [qtot_lim_transfer];

EQ_QTR_AVG_VANE_OFF_UP(tb)$(tf(tb)) ..                    q1tr_avg(tb) =l=   Qtot_max*(1 - vane_closed(tb));
EQ_QTR_AVG_VANE_OFF_LO(tb)$(tf(tb)) ..                    q1tr_avg(tb) =g=  -Qtot_max*(1 - vane_closed(tb));
EQ_QTR_AVG_QTOT_OFF_UP(tb)$(tf(tb)) ..                    q1tr_avg(tb) =l=   Qtot_max*(1-sign_qtot(tb));
EQ_QTR_AVG_QTOT_OFF_LO(tb)$(tf(tb)) ..                    q1tr_avg(tb) =g=  -Qtot_max*(1-sign_qtot(tb));

EQ_QTR_AVG_DEF_UP(tb)$(tf(tb)) ..       q1tr_avg(tb) =l=  [0.5*q1_trans(tb)+0.5*q1_trans(tb+1)                      ]$[first_order(tb)]
                                                         +[5/12*q1_trans(tb)+ 2/3*q1_trans(tb+1)-1/12*q1_trans(tb+2)]$[second_order(tb)]
                                                         + Qtot_max*(sign_qtot(tb) + vane_closed(tb));

EQ_QTR_AVG_DEF_LO(tb)$(tf(tb)) ..       q1tr_avg(tb) =g=  [0.5*q1_trans(tb)+0.5*q1_trans(tb+1)                      ]$[first_order(tb)]
                                                         +[5/12*q1_trans(tb)+ 2/3*q1_trans(tb+1)-1/12*q1_trans(tb+2)]$[second_order(tb)]
                                                         - Qtot_max*(sign_qtot(tb) + vane_closed(tb));

********************  FLOWS AND WATER BALANCE ****************************************************************************
EQ_V_UP_SLACK(i,tb)$(tf(tb) and (ord(tb)>%LOCK_PRODUCTION_PLAN%+1)) ..  v(i,tb) =l=  slack_Vmax(i,tb)  + [Vmax_gr$(ord(i)=1) + Vmax_pr$(ord(i)=2)-tol_vol*1E4] ;
EQ_V_LO_SLACK(i,tb)$(tf(tb) and (ord(tb)>%LOCK_PRODUCTION_PLAN%+1)) ..  v(i,tb) =g= -slack_Vmin(i,tb)  + [Vmin_gr$(ord(i)=1) + Vmin_pr$(ord(i)=2)+tol_vol*1E4] ;

parameter Q_ECO_RESERVED(i) /pr 0.309 ,gr 0.63 /;
EQ_WATER_BALANCE_GRADIENT(i,tb)$(tf(tb))..   gradient(i,tb)=e= 3600*( INFLOW(i,tb)
                                                                  -[  q_sstr(i,tb)
                                                                  + Q_ECO_RESERVED(i)$(%ENABLE_RESERVED_FLOW_RATE%)
                                                                  + q1tr_avg(tb)$[ord(i)=1]
                                                                  - q1tr_avg(tb)$[ord(i)=2]]);

EQ_WATER_BALANCE(i,tb+1)$(ord(tb)<=card(tb)-1 and tf(tb)) ..   v(i,tb+1) =L= v(i,tb) + gradient(i,tb) + slack_wb_pos(i,tb) - slack_wb_neg(i,tb) ;

EQ_SPILL(i,tb)$(ord(tb)<=card(tb)-1 and tf(tb) and backtesting_hydraulics=0 ) ..  spill(i,tb)*3600 =G= v(i,tb) -v(i,tb+1) + gradient(i,tb) ;

********************  CONVERSION V TO Z ************************************************************************************
set segment /seg1,seg2/;
parameter alpha_bat(i,segment),beta_bat(i,segment);
alpha_bat('pr','seg1')= 4.5104261/(1E5); alpha_bat('gr','seg1')= 4.4871971/(1E6);
beta_bat('pr','seg1') = 684.7; beta_bat('pr','seg2') = 686.24429; beta_bat('gr','seg1') = 686.28 ;

*** for 2 segments ****
EQ_BATHY_SEG_1_ON(i,tb)$(tf(tb) and (additive(tb)) and (not addi_refined(tb)))..
-seg1_bathy(i,tb)*[Vmax_pr$(ord(i)=2) + Vmax_gr$(ord(i)=1)] =L=  v(i,tb) - [Bathy(i,'ptBat5','volume')$(ord(i)=2)
                                                                         +  Bathy(i,'ptBat4','volume')$(ord(i)=1)] ;

EQ_BATHY_SEG_1_OFF(i,tb)$(tf(tb) and (additive(tb)) and (not addi_refined(tb)))..
(1-seg1_bathy(i,tb))*[Vmax_pr$(ord(i)=2) + Vmax_gr$(ord(i)=1)] =G=  v(i,tb) - [Bathy(i,'ptBat5','volume')$(ord(i)=2)
                                                                            +  Bathy(i,'ptBat4','volume')$(ord(i)=1)];

**** for 2 segments on GR and 4 segments on PR *****
parameter nb_segs_bat(i) /pr 4,gr 2/;
parameter alpha_corr_refined(i,seg_bat_refined);
parameter vol_corr_refined(i,seg_bat_refined);
alpha_corr_refined('pr','segBatRef2') = -1.45*1E-5; vol_corr_refined('pr','segBatRef2') = Bathy('pr','ptBat5','volume') ;
alpha_corr_refined('pr','segBatRef3') = -0.5*1E-5; vol_corr_refined('pr','segBatRef3') = Bathy('pr','ptBat7','volume') ;
alpha_corr_refined('pr','segBatRef4') = -0.5*1E-5; vol_corr_refined('pr','segBatRef4') = Bathy('pr','ptBat9','volume') ;
alpha_corr_refined('gr','segBatRef2') = -1.55*1E-6; vol_corr_refined('gr','segBatRef2') = Bathy('gr','ptBat4','volume') ;

EQ_BATHY_REF_SEG_ON(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
    seg_bathy_refined(i,seg_bat_refined,tb)*[Vmax_pr$(ord(i)=2) + Vmax_gr$(ord(i)=1)]   =G=  v(i,tb) -  vol_corr_refined(i,seg_bat_refined) ;

EQ_BATHY_REF_SEG_OFF(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
-(1-seg_bathy_refined(i,seg_bat_refined,tb))*[Vmax_pr$(ord(i)=2) + Vmax_gr$(ord(i)=1)]  =L=  v(i,tb) - vol_corr_refined(i,seg_bat_refined) ;

EQ_Z_ADD_REFINED_UP_ON(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
z_add_ref(i,seg_bat_refined,tb) =G= alpha_corr_refined(i,seg_bat_refined)*(v(i,tb) - vol_corr_refined(i,seg_bat_refined)) - 10*(1-seg_bathy_refined(i,seg_bat_refined,tb)) ;

EQ_Z_ADD_REFINED_LO_ON(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
z_add_ref(i,seg_bat_refined,tb) =L= alpha_corr_refined(i,seg_bat_refined)*(v(i,tb) - vol_corr_refined(i,seg_bat_refined)) + 10*(1-seg_bathy_refined(i,seg_bat_refined,tb)) ;

EQ_Z_ADD_REFINED_UP_OFF(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
z_add_ref(i,seg_bat_refined,tb) =L=  10*seg_bathy_refined(i,seg_bat_refined,tb) ;

EQ_Z_ADD_REFINED_LO_OFF(i,seg_bat_refined,tb)$(tf(tb) and (additive(tb)) and addi_refined(tb) and ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2)  ..
z_add_ref(i,seg_bat_refined,tb) =G=  -10*seg_bathy_refined(i,seg_bat_refined,tb) ;


parameter alpha_add(i);
alpha_add('pr') = -1.7*0.00001; alpha_add('gr') = -1.55*0.000001;
EQ_Z_ADD_UP_ON(i,tb)$(tf(tb) and additive(tb))..  z_add(i,tb) =l= alpha_add(i)*(v(i,tb)-[Bathy(i,'ptBat5','volume')$(ord(i)=2)+Bathy(i,'ptBat4','volume')$(ord(i)=1)]) + (seg1_bathy(i,tb))*10;
EQ_Z_ADD_LO_ON(i,tb)$(tf(tb) and additive(tb))..  z_add(i,tb) =g= alpha_add(i)*(v(i,tb)-[Bathy(i,'ptBat5','volume')$(ord(i)=2)+Bathy(i,'ptBat4','volume')$(ord(i)=1)]) - (seg1_bathy(i,tb))*3;
EQ_Z_ADD_UP_OFF(i,tb)$(tf(tb) and additive(tb)).. z_add(i,tb) =l= (1-seg1_bathy(i,tb))*10;
EQ_Z_ADD_LO_OFF(i,tb)$(tf(tb) and additive(tb)).. z_add(i,tb) =g= -(1-seg1_bathy(i,tb))*10;

EQ_CONVERSION_V_TO_WATER_LEVELS_ADD_UP(i,segment,tb)$(tf(tb))..
                         z(i,tb) =L= [alpha_bat(i,'seg1')]*v(i,tb) + beta_bat(i,'seg1') + z_add(i,tb)$[additive(tb) and (not addi_refined(tb))]
+sum(seg_bat_refined$(ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2),z_add_ref(i,seg_bat_refined,tb))$[addi_refined(tb) and additive(tb)];

EQ_CONVERSION_V_TO_WATER_LEVELS_ADD_LO(i,segment,tb)$(tf(tb))..
                         z(i,tb) =G= [alpha_bat(i,'seg1')]*v(i,tb) + beta_bat(i,'seg1') + z_add(i,tb)$[additive(tb) and (not addi_refined(tb))]
+sum(seg_bat_refined$(ord(seg_bat_refined)<=nb_segs_bat(i) and ord(seg_bat_refined)>=2),z_add_ref(i,seg_bat_refined,tb))$[addi_refined(tb) and additive(tb)];

EQ_DEF_DZ(tb)$(tf(tb)) ..                                           dz(tb) =e= (z('pr',tb) - z('gr',tb));


***********************  COSTS AND PROFITS  ********************************************************************************
EQ_DEF_PNL    ..             pnl =l=                  sum(tb$(ord(tb)<=card(tb)-1 and tf(tb)), spot(tb)*p(tb));
EQ_DEF_SLACKS_COST ..   C_slacks =g=              1E3*sum((tb,i)$(ord(tb)<=card(tb)-1 and tf(tb)), slack_Vmin(i,tb) + slack_Vmax(i,tb) + slack_wb_neg(i,tb) + slack_wb_pos(i,tb));
EQ_DEF_SPILL_COST ..     C_spill =g= 3600*spill_costs*sum((tb,i)$(ord(tb)<=card(tb)-1 and tf(tb)), spill(i,tb));
EQ_DEF_SU_SD_COST  ..       C_su =g=      sum(tb$(ord(tb)<=card(tb)-1 and tf(tb)), start_up_costs*(su(tb) + sd(tb)) + vane_costs*(su_vane(tb) + sd_vane(tb)));

EQ_DEF_OF       ..            of =l= pnl - C_slacks - C_spill - C_su + sum((tb,i)$(ord(tb)=first_time+23),v(i,tb)*water_value(i));




option limrow = 1000;
model coindre_model /all/;
scalar warm_start /%WARM_UP%/;
scalar second_solve /%REFINED_HYDRAULICS%/;
scalar keep_UC_schedule /%FILTER_UC_SCHEDULE%/;
display warm_start, second_solve, keep_UC_schedule;

******** SUBDIVISION OF THE TIME HORIZON INTO DIFFERENT TERMS WITH DIFFERENT GRANULARITIES *********
*        The further the term the less refined the model
*        This will allow us to have precision on the short term in terms of water exchange
*        On the long run only a rough estimate of the scheldule is necessary in order to have the right water value.

first_time =  floor(card(tb)*pct_start) ;
last_time  =  first_time + 24*%N_DAYS% -1 ;
tf(tb)$(no_tf_filter) = YES;
*do not optimize the time buckets that are in the past use the realised data instead.
tf(tb)$(ord(tb) <= %CURRENT_TIME%) = NO;
*use the realised data instead power is locked until h13 = 12:00:00 - 13:00:00
p.fx(tb)$(ord(tb) <= %LOCK_PRODUCTION_PLAN%) = P_REALISED(tb);
vane_closed.fx(tb)$(ord(tb) <= %LOCK_PRODUCTION_PLAN%) = 1-VANE_REALISED(tb);
*volume value is the value at the beginnig of the current time bucket. If current time is 14:20:00 PM the last volume fixed value is v.fx('14:20:00 PM')
v.fx(i,tb)$(ord(tb) <= %CURRENT_TIME%+1) = V_REALISED(i,tb);

DAILY(tb)$(ord(tb)>= first_time and ord(tb)<= first_time + %N_DAYS%*24-1)= yes ;
THREE_DAILY(tb)$(ord(tb)>= first_time and ord(tb)<= first_time+3*24-1)= yes ;
WEEKLY(tb)$(ord(tb)>= first_time and ord(tb)<= first_time+7*24-1)= yes ;
MONTHLY(tb)$(ord(tb)>= first_time and ord(tb)<= first_time + 30*24-1 and ord(tb)<=last_time)= yes ;


OPTION MIP = Gurobi ;
OPTION resLim = %RUN_TIME_LIMIT% ;

***** warm up run *******
IF(warm_start=1,
      flow_0(tb) = -3;
      transfer_flow_corrected = -1.5486;
      intersect_flow = 1.75;
      refine_transfer(tb) = NO ;
* First order if qtrans_average = 0.5(qtr(tb) + qtr(tb+1))
      first_order(tb) = NO ; second_order(tb) = NO ;
* additive(tb)= YES for 2 segments bathymetry and addi_refined(tb)= YES for 4 (resp. 2) segments bathymetry in PR (resp. PR)
      additive(tb) = NO ; addi_refined(tb) = NO;
      activate_slacks = 1 ;
      activate_wb_slacks = 0 ;
      allow_spilling =1;
      dz_corr_sstr = 0;
      corr_flow = 0.3;
      OPTION optCR = 0.01 ;
      SOLVE coindre_model us MIP max of ;
);

***** second solve sevres to have the approx. solution comply with the precise rules of transfer *****
IF(second_solve=1,
       IF(keep_UC_schedule=1,
           u.fx(tb)$(u.l(tb)=0 and DAILY(tb)) = 0;
       );
       backtesting_hydraulics = 0;
       flow_0(tb)$(DAILY(tb)) = -8.112 ; flow_0(tb)$(not DAILY(tb)) = -3;
       refine_transfer(tb)$(DAILY(tb)) = YES;
       dz_corr_sstr = 1;
       first_order(tb)= YES ; second_order(tb)$(DAILY(tb))= NO;
       additive(tb)$(DAILY(tb)) = YES; addi_refined(tb)$(DAILY(tb)) = YES;
       OPTION optCR = %MIP_GAP%;
       SOLVE coindre_model us MIP max of;

);


*##########################################################################################################
*###########################                                             ##################################
*###########################                POST TREATMENTS              ##################################
*###########################                                             ##################################
*##########################################################################################################
$batinclude "%GAMS_SRC_PATH%\post_treatment.gms"


****** Write the results in GDXs files **************************************
execute_unload '%OUT_PATH%' report BACKTEST tb tf  KPI cum_pnl
execute_unload '%ALL_OUT_PATH%'
execute 'gdxxrw.exe input="%OUT_PATH%" output="%XLS_OUTPUT%" par=report rng=raw_results!a1'














