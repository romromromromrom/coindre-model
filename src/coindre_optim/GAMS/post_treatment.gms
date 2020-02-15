*##########################################################################################################
*###########################                                             ##################################
*###########################      POST-TREATMENT AND VISUAL OUTPUT       ##################################
*###########################                                             ##################################
*##########################################################################################################
set window(tb)         'filters the timebuckets that we want to see on the screen when plotting the .gdx file ';
scalars ordmin,ordmax  'Display parameter';
ordmin =  1 + 1/100*card(tb)*0  ;
ordmax =  1 + 1/100*card(tb)*100;
window(tb) = yes$(ord(tb)>= ordmin and ord(tb)<=ordmax and tf(tb)) OR YES;


parameter report(tb,*);
report(tb,'spot')$(window(tb)) = (spot(tb))$(spot(tb)<>0) + Eps$(not spot(tb)<>0);
report(tb,'inflows_GR')$(window(tb)) = (inflows_gr(tb))$(inflows_gr(tb)<>0) + Eps$(not inflows_gr(tb)<>0);
report(tb,'inflows_PR')$(window(tb)) = (inflows_pr(tb))$(inflows_pr(tb)<>0) + Eps$(not inflows_pr(tb)<>0);
report(tb,'indispo (%)')$(window(tb)) = (100*unavail(tb))$(unavail(tb)<>0) + Eps$(not unavail(tb)<>0);

report(tb,'p(t)')$(window(tb)) = (p.l(tb))$(p.l(tb)<>0) + Eps$(not p.l(tb)<>0);
report(tb,'P NOMINATED')$(window(tb)) = (P_REALISED(tb))$(P_REALISED(tb)<>0) + Eps$(not P_REALISED(tb)<>0);

report(tb,'x19')$(window(tb)) = ((1-unavail(tb))*19*x.l("19MW",tb))$(x.l("19MW",tb)<>0) + Eps$(not x.l("19MW",tb)<>0);
report(tb,'x25')$(window(tb)) = ((1-unavail(tb))*25*x.l("25MW",tb))$(x.l("25MW",tb)<>0) + Eps$(not x.l("25MW",tb)<>0);
report(tb,'x34')$(window(tb)) = ((1-unavail(tb))*34*x.l("34MW",tb))$(x.l("34MW",tb)<>0) + Eps$(not x.l("34MW",tb)<>0);
report(tb,'x36')$(window(tb)) = ((1-unavail(tb))*36*x.l("36MW",tb))$(x.l("36MW",tb)<>0) + Eps$(not x.l("36MW",tb)<>0);
report(tb,'Vane CLOSED')$(window(tb)) = (10*vane_closed.l(tb))$(vane_closed.l(tb) <>0) + Eps$(not vane_closed.l(tb)<>0);
report(tb,'Vane REALISED')$(window(tb)) = (10*VANE_REALISED(tb))$(VANE_REALISED(tb) <>0) + Eps$(not VANE_REALISED(tb)<>0);

report(tb,'v_gr (1E+04 m³)')$(window(tb)) = (v.l('gr',tb)/scaling_volumes)$(v.l('gr',tb)/scaling_volumes<>0) + Eps$(not v.l('gr',tb)/scaling_volumes<>0);
report(tb,'v_pr (1E+04 m³)')$(window(tb)) = (v.l('pr',tb)/scaling_volumes)$(v.l('pr',tb)/scaling_volumes<>0) + Eps$(not v.l('pr',tb)/scaling_volumes<>0);

report(tb,' z_gr  - 686.28 (in dm) ')$(window(tb)) =  ((z.l('gr',tb)-686.28)*10)$((z.l('gr',tb)-686.28)<>0) + Eps$(not z.l('gr',tb)- 686.28<>0)  ;
report(tb,' seg1_bathy_gr ')$(window(tb)) = [seg1_bathy.l('gr',tb)*10 ]$[seg1_bathy.l('gr',tb)<>0] +EPS$[seg1_bathy.l('gr',tb)=0];
report(tb,' z_pr -  684.70 (in dm)')$(window(tb)) =  ((z.l('pr',tb)-684.70)*10)$((z.l('pr',tb)-684.70)*100<>0) + Eps$(not (z.l('pr',tb)-684.70)*10<>0)  ;
report(tb,' seg1_bathy_pr ')$(window(tb)) = [seg1_bathy.l('pr',tb)*10 ]$[seg1_bathy.l('pr',tb)<>0] +EPS$[seg1_bathy.l('pr',tb)=0];

report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=8000 and v.l('pr',tb)>=0)=10*(3.74999999999943E-05*v.l('pr',tb)+684.7-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=28000 and v.l('pr',tb)>=8000)=10*(0.00005*v.l('pr',tb)+684.6-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=50000 and v.l('pr',tb)>=28000)=10*(4.54545454545455E-05*v.l('pr',tb)+684.727272727273-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=74000 and v.l('pr',tb)>=50000)=10*(4.16666666666667E-05*v.l('pr',tb)+684.916666666667-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=104000 and v.l('pr',tb)>=74000)=10*(3.33333333333333E-05*v.l('pr',tb)+685.533333333333-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=138000 and v.l('pr',tb)>=104000)=10*(2.94117647058824E-05*v.l('pr',tb)+685.941176470588-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=176000 and v.l('pr',tb)>=138000)=10*(2.63157894736842E-05*v.l('pr',tb)+686.368421052632-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=216000 and v.l('pr',tb)>=176000)=10*(0.000025*v.l('pr',tb)+686.6-684.7);
report(tb,'zpr_norm RECALC')$(window(tb) and v.l('pr',tb)<=264000 and v.l('pr',tb)>=216000)=10*(2.08333333333333E-05*v.l('pr',tb)+687.5-684.7);
report(tb,'zpr_norm RECALC')=report(tb,'zpr_norm RECALC')/10 + 684.7;
*report(tb,'zpr_norm RECALC')$(window(tb) and report(tb,'zpr_norm RECALC')=0)=EPS;

report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=202000 and v.l('gr',tb)>=0)=10*(5.04950495049496E-06*v.l('gr',tb)+686.28-686.28);
report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=435000 and v.l('gr',tb)>=202000)=10*(4.29184549356223E-06*v.l('gr',tb)+686.4330472103-686.28);
report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=690000 and v.l('gr',tb)>=435000)=10*(3.92156862745098E-06*v.l('gr',tb)+686.594117647059-686.28);
report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=992000 and v.l('gr',tb)>=690000)=10*(3.3112582781457E-06*v.l('gr',tb)+687.015231788079-686.28);
report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=1334000 and v.l('gr',tb)>=992000)=10*(2.92397660818713E-06*v.l('gr',tb)+687.399415204678-686.28);
report(tb,'zgr_norm RECALC')$(window(tb) and v.l('gr',tb)<=1593000 and v.l('gr',tb)>=1334000)=10*(2.70270270270288E-06*v.l('gr',tb)+687.694594594594-686.28);
report(tb,'zgr_norm RECALC')=report(tb,'zgr_norm RECALC')/10 + 686.28;
*report(tb,'zgr_norm RECALC')$(window(tb) and report(tb,'zgr_norm RECALC')=0)=EPS;


report(tb,' dz (dm)')$(window(tb)) =  (dz.l(tb)*10)$(dz.l(tb)*10<>0) + Eps$(not dz.l(tb)*100 <>0)  ;
report(tb,'v_max_GR (1E+04 m³)')$(window(tb)) =  Vmax_gr/scaling_volumes;
report(tb,'v_max_PR (1E+04 m³)')$(window(tb)) =  Vmax_pr/scaling_volumes;

*********  power zones levels **********************************************
report(tb,'PR 689.00(1E+04 m³)')$(window(tb)) =  VolPZ_PR("689.00")/scaling_volumes;
report(tb,'PR 687.00(1E+04 m³)')$(window(tb)) =  VolPZ_PR("687.00")/scaling_volumes;
report(tb,'PR 686.00(1E+04 m³)')$(window(tb)) =  VolPZ_PR("686.00")/scaling_volumes;
report(tb,'PR 684.70(1E+04 m³)')$(window(tb)) =  VolPZ_PR("684.70")/scaling_volumes;
report(tb,'GR 689.00(1E+04 m³)')$(window(tb)) =  VolPZ_GR("689.00")/scaling_volumes;

report(tb,'vPR = 34/36 + tol_vol')$(window(tb)) =  [VolPZ_PR("689.00")]/scaling_volumes + tol_vol;
report(tb,'vPR = 25/34 + tol_vol')$(window(tb)) = [ VolPZ_PR("687.00")+tol_vol]/scaling_volumes + tol_vol;
report(tb,'vPR = 19/25 + tol_vol')$(window(tb)) =  [VolPZ_PR("686.00")+tol_vol]/scaling_volumes + tol_vol;
report(tb,'vPR = 0 + tol_vol')$(window(tb)) =  [VolPZ_PR("684.70")+tol_vol]/scaling_volumes + tol_vol;
report(tb,'vGR = 34/36 +tol_vol')$(window(tb)) =  [VolPZ_GR("689.00")+tol_vol]/scaling_volumes + tol_vol;

report(tb,'qsstr_pr m³/s')$(window(tb)) = (q_sstr.l('pr',tb))$(q_sstr.l('pr',tb)<>0) + Eps$(not q_sstr.l('pr',tb)<>0);
report(tb,'qsstr_gr m³/s')$(window(tb)) = (q_sstr.l('gr',tb))$(q_sstr.l('gr',tb)<>0) + Eps$(not q_sstr.l('gr',tb)<>0);

report(tb,'q2 m³/s')$(window(tb)) = (q_sstr.l('pr',tb)-q1tr_avg.l(tb))$(q_sstr.l('pr',tb)-q1tr_avg.l(tb)<>0) + Eps$(not q_sstr.l('pr',tb)-q1tr_avg.l(tb)<>0);
report(tb,'q1 m³/s')$(window(tb)) = (q_sstr.l('gr',tb)+q1tr_avg.l(tb))$(q_sstr.l('gr',tb)+q1tr_avg.l(tb)<>0) + Eps$(not q_sstr.l('gr',tb)+q1tr_avg.l(tb)<>0);
report(tb,'QTOT m³/s')$(window(tb)) = (qtot.l(tb))$(qtot.l(tb) <>0) + EPS$(not qtot.l(tb) <> 0);
report(tb,'QTOT>lim transfer ')$(window(tb)) = (qtot_lim_transfer *sign_qtot.l(tb))$(qtot_lim_transfer*sign_qtot.l(tb) <>0) + EPS$(not qtot_lim_transfer*sign_qtot.l(tb) <> 0);
report(tb,'qtot-1000p(t)/0.22/3600')$(window(tb)) = (qtot.l(tb)-1000*p.l(tb)/0.22/3600)$(qtot.l(tb)-1000*p.l(tb)/0.22/3600 <>0) + EPS$(not qtot.l(tb)-1000*p.l(tb)/0.22/3600 <> 0);

report(tb,'q1_trans m³/s')$(window(tb)) = q1tr_avg.l(tb)$(q1tr_avg.l(tb) <>0)  + Eps$(q1tr_avg.l(tb)=0) ;
report(tb,'q1_tr NEG m³/s')$(window(tb)) = q1_trans_add.l('-',tb)$(q1_trans_add.l('-',tb) <>0)  + EPS$(q1_trans_add.l('-',tb)=0) ;
report(tb,'q1_tr POS m³/s')$(window(tb)) = q1_trans_add.l('+',tb)$(q1_trans_add.l('+',tb) <>0)  + EPS$(q1_trans_add.l('+',tb)=0) ;
report(tb,'SEG TRANS NEG ')$(window(tb)) = (50*dz_loc.l('-',tb))$(dz_loc.l('-',tb)<>0) + EPS$(dz_loc.l('-',tb)=0);
report(tb,'SEG TRANS POS')$(window(tb)) =  (60*dz_loc.l('+',tb))$(dz_loc.l('+',tb)<>0) + EPS$(dz_loc.l('+',tb)=0);
report(tb,'SEG TRANS SYM')$(window(tb)) =  (40)$(dz_loc.l('+',tb)=0 and dz_loc.l('-',tb)=0) + EPS$(dz_loc.l('+',tb)=0 or dz_loc.l('-',tb)=0);


report(tb,'spill_pr')$(window(tb)) = (spill.l('pr',tb))$(spill.l('pr',tb)<>0) + Eps$(not spill.l('pr',tb)<>0);
report(tb,'spill_gr')$(window(tb)) = (spill.l('gr',tb))$(spill.l('gr',tb)<>0) + Eps$(not spill.l('gr',tb)<>0);
report(tb,'q_gr - 2/3 ou 3/3 Qtot')$(window(tb)) = (q_sstr.l('gr',tb)-((2/3)$(vane_closed.l(tb)=0) + 1$(vane_closed.l(tb)=1))*qtot.l(tb))$(q_sstr.l('gr',tb)-((2/3)$(vane_closed.l(tb)=0) + 1$(vane_closed.l(tb)=1))*qtot.l(tb)<>0) + Eps$(not q_sstr.l('gr',tb)-((2/3)$(vane_closed.l(tb)=0) + 1$(vane_closed.l(tb)=1))*qtot.l(tb)<>0);
report(tb,'q_pr - 1/3Qtot')$(window(tb)) = (q_sstr.l('pr',tb)-((1/3)$(vane_closed.l(tb)=0)+0$(vane_closed.l(tb)=1))*qtot.l(tb))$(q_sstr.l('pr',tb)-((1/3)$(vane_closed.l(tb)=0)+0$(vane_closed.l(tb)=1))*qtot.l(tb)<>0) + Eps$(not q_sstr.l('pr',tb)-((1/3)$(vane_closed.l(tb)=0)+0$(vane_closed.l(tb)=1))*qtot.l(tb)<>0);
report(tb,'pmax-p')$(window(tb)) = (-p.l(tb) + sum(zone,P_max(zone)*x.l(zone,tb))*(1-unavail(tb)))$(-p.l(tb) + sum(zone,P_max(zone)*x.l(zone,tb))*(1-unavail(tb))<>0) + Eps$(not -p.l(tb) + sum(zone,P_max(zone)*x.l(zone,tb))*(1-unavail(tb)) <>0);

report(tb,'0 error in water lvl')$(window(tb) and backtesting_hydraulics=1) = -20 ;
report(tb,'24H')$(window(tb)) = 160$(ord(tb)=first_time+24) + EPS$(not ord(tb)=first_time+24) ;



set optimizer /hydro_team,COOPT/;
alias(tb,h);
parameter cum_pnl(optimizer,tb);
cum_pnl("COOPT",tb)$(window(tb))=  sum(h$(ord(h)<=ord(tb) and ord(h)>=first_time), p.l(h)*spot(h) );
cum_pnl(optimizer,tb)$(cum_pnl(optimizer,tb)=0)=EPS;

report(tb,'hydro_team cumulated PNL (kâ‚¬)')$(window(tb))= cum_pnl("hydro_team",tb)/1000+100;
report(tb,'COOPT cumulated PNL (kâ‚¬)')$(window(tb))= cum_pnl("COOPT",tb)/1000+100;

***** sets of inconssistent TBs ************************************
parameter water_imbal(i,tb);
water_imbal('gr',tb)$(tf(tb))=abs(-v.l('gr',tb+1) + v.l('gr',tb) + gradient.l('gr',tb) );
water_imbal('pr',tb)$(tf(tb))=abs(-v.l('pr',tb+1) + v.l('pr',tb) + gradient.l('pr',tb));
parameter nodal_wb(tb); parameter p_not_pmax(tb);
nodal_wb(tb)$(tf(tb)) = q_sstr.l('pr',tb) + q_sstr.l('gr',tb) - qtot.l(tb) ;
p_not_pmax(tb)$(tf(tb)) = -p.l(tb) + sum(zone,P_max(zone)*x.l(zone,tb))*(1-unavail(tb)) ;
parameter qtot_not_at_bound(tb); qtot_not_at_bound(tb)$(tf(tb))=   qtot.l(tb) - 1000*p.l(tb)/0.22/3600;


set TBs_WB_GR_not_at_bound(tb); TBs_WB_GR_not_at_bound(tb)$(water_imbal('gr',tb)>1E-7) = yes;
set TBs_WB_PR_not_at_bound(tb); TBs_WB_PR_not_at_bound(tb)$(water_imbal('pr',tb)>1E-7) = yes;
set TBs_WB_NODAL_not_at_bound(tb); TBs_WB_NODAL_not_at_bound(tb)$(nodal_wb(tb)> 1E-7) = yes;
set TBs_P_is_not_Pmax(tb); TBs_P_is_not_Pmax(tb)$(p_not_pmax(tb)>1E-7) = yes;
set TBs_Slack_PR_Vmax(tb); TBs_Slack_PR_Vmax(tb)$(slack_Vmax.l('pr',tb)>0) = yes ;
set TBs_Slack_PR_Vmin(tb); TBs_Slack_PR_Vmin(tb)$(slack_Vmin.l('pr',tb)>0) = yes ;
set TBs_Slack_GR_Vmax(tb); TBs_Slack_GR_Vmax(tb)$(slack_Vmax.l('gr',tb)>0) = yes ;
set TBs_Slack_GR_Vmin(tb); TBs_Slack_GR_Vmin(tb)$(slack_Vmin.l('gr',tb)>0) = yes ;
set TBs_qtot_p_not_at_bound(tb); TBs_qtot_p_not_at_bound(tb)$(qtot.l(tb) - 1000*p.l(tb)/0.22/3600 > 1E-7) = yes  ;
set TBs_spill_in_GR(tb); TBs_spill_in_GR(tb)$(spill.l('gr',tb)>1E-7) = yes;
set TBs_spill_in_PR(tb); TBs_spill_in_PR(tb)$(spill.l('pr',tb)>1E-7) = yes;

parameter TESTS(*);
TESTS('TEST_WATER_BALANCE_GR') = 1$( smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('gr',tb)) < 1E-7) + Eps$(not smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('gr',tb)) < 1E-7);
TESTS('TEST_WATER_BALANCE_PR') = 1$( smax(tb$(ord(tb)<card(tb) and tf(tb)), water_imbal('pr',tb)) < 1E-7) + Eps$(not smax(tb$(ord(tb)<card(tb) and tf(tb)), water_imbal('pr',tb)) < 1E-7);
TESTS('TEST_SPILL_PRICE') = 1$(smin(tb,Pmin*(1-unavail(tb))*max(0,-spot(tb)))> spill_costs or smin(tb,spot(tb))>0) + Eps$(not Pmin*smin(tb,max(0,-spot(tb)))> spill_costs or smin(tb,spot(tb))>0 );
TESTS('TEST_NO_SLACKS_USED') = 1$(smax(tb,slack_Vmax.l('gr',tb))<1E-7 and smax(tb, slack_Vmax.l('pr',tb))<1E-7 and smax(tb, slack_Vmin.l('gr',tb))<1E-7 and smax(tb, slack_Vmin.l('pr',tb))<1E-7 ) + Eps$(not smax(tb,slack_Vmax.l('gr',tb))<1E-7 and smax(tb, slack_Vmax.l('pr',tb))<1E-7 and smax(tb, slack_Vmin.l('gr',tb))<1E-7 and smax(tb, slack_Vmin.l('pr',tb))<1E-7  );
TESTS('TEST_NODAL_WATER_BALANCE') = 1$(smax(tb,nodal_wb(tb))<1E-7) + Eps$(not smax(tb,nodal_wb(tb))<1E-7 );
TESTS('TEST_QTOT_AT_BOUND') =1$(smax(tb,qtot.l(tb) - 1000*p.l(tb)/0.22/3600)<1E-7) + Eps$(not smax(tb,qtot.l(tb) - 1000*p.l(tb)/0.22/3600)<1E-7 );



********** parameter for backtesting_hydraulics **********************************
parameter BACKTEST(*),untightness_qsstr(i,tb);

untightness_qsstr('pr',tb)$( vane_closed.l(tb)=1 ) = q_sstr.l('pr',tb) - 0  ;
untightness_qsstr('pr',tb)$( vane_closed.l(tb)=0 and u.l(tb)=1) = q_sstr.l('pr',tb) - [ (1 - n('qt','sstr','index1'))*qtot.l(tb) + corr_flow*dz.l(tb)  ];
untightness_qsstr('pr',tb)$( vane_closed.l(tb)=0 and u.l(tb)=0) = q_sstr.l('pr',tb) - 0 ;

untightness_qsstr('gr',tb)$( vane_closed.l(tb)=1 and u.l(tb)=1) = q_sstr.l('gr',tb) - qtot.l(tb)  ;
untightness_qsstr('gr',tb)$( vane_closed.l(tb)=0 and u.l(tb)=0) = q_sstr.l('gr',tb) ;
untightness_qsstr('gr',tb)$( vane_closed.l(tb)=0 and u.l(tb)=1) = q_sstr.l('gr',tb) - [n('qt','sstr','index1')*qtot.l(tb) - corr_flow*dz.l(tb)];


BACKTEST(' qsstr GR not @bound  ') =[smax(tb$(tf(tb)),untightness_qsstr('gr',tb) )]$[smax(tb$(tf(tb)),untightness_qsstr('gr',tb) )>1E-7];
BACKTEST(' qsstr PR not @bound  ') =[smax(tb$(tf(tb)),untightness_qsstr('pr',tb) )]$[smax(tb$(tf(tb)),untightness_qsstr('pr',tb) )>1E-7];


BACKTEST(' QTOT =/= 1000*p/0.22/3600')$(not %NON_LINEAR_EFF%) = (smax(tb$(tf(tb)),abs( qtot.l(tb)-1000*p.l(tb)/%EFF_TURB%/3600))>1E-7)$(smax(tb$(tf(tb)),abs( qtot.l(tb)-1000*p.l(tb)/%EFF_TURB%/3600))>1E-7) ;
BACKTEST(' QTOT =/= 1000*p/0.22/3600')$(%NON_LINEAR_EFF%) =smax(tb, min(qtot.l(tb) -(0.964506173*p.l(tb) + 5.787037037 - Qtot_max*(1-u.l(tb))),
                                                                        qtot.l(tb) -( 1.467061149*p.l(tb) - 3.258952534 ) ,
                                                                        qtot.l(tb) -( 1.660878863*p.l(tb) - 7.910577679) ,
                                                                        qtot.l(tb) -( 1.958733425*p.l(tb) - 18.03763277)))  <1E-7;


BACKTEST(' WB BALANCE BROKEN GR ') = [smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('gr',tb))/scaling_volumes]$[ smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('gr',tb))> 1E-7];
BACKTEST(' WB BALANCE BROKEN PR ') = [smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('pr',tb))/scaling_volumes]$[ smax(tb$(ord(tb)<card(tb) and tf(tb)),water_imbal('pr',tb))> 1E-7];
BACKTEST(' SLACKS VOL GR ') = [smax(tb$(tf(tb)), slack_Vmin.l('gr',tb)+ slack_Vmax.l('gr',tb))]$(smax(tb$(tf(tb)), slack_Vmin.l('gr',tb)+ slack_Vmax.l('gr',tb)) >1E-7);
BACKTEST(' SLACKS VOL PR ') = [smax(tb$(tf(tb)), slack_Vmin.l('pr',tb)+ slack_Vmax.l('pr',tb))]$(smax(tb$(tf(tb)), slack_Vmin.l('pr',tb)+ slack_Vmax.l('pr',tb))>1E-7);
BACKTEST(' SLACKS WB GR ') = [smax(tb$(tf(tb)),  slack_wb_pos.l('gr',tb) + slack_wb_neg.l('pr',tb))]$(smax(tb$(tf(tb)),  slack_wb_pos.l('gr',tb) + slack_wb_neg.l('pr',tb))>1E-7);
BACKTEST(' SLACKS WB PR ') = [smax(tb$(tf(tb)),  slack_wb_pos.l('pr',tb) + slack_wb_neg.l('pr',tb))]$(smax(tb$(tf(tb)),  slack_wb_pos.l('pr',tb) + slack_wb_neg.l('pr',tb))>1E-7);


BACKTEST('SPILL_GR') = [sum(tb$(tf(tb)), spill.l('gr',tb))]$(sum(tb$(tf(tb)), spill.l('gr',tb))>1E-7);
BACKTEST('SPILL_PR') = [sum(tb$(tf(tb)), spill.l('pr',tb))]$(sum(tb$(tf(tb)), spill.l('pr',tb))>1E-7);

BACKTEST('ZGR error approx bathy for 24 hours (cm)') = smax(tb$(tf(tb) and DAILY(tb)),abs(z.l('gr',tb) - [report(tb,'zgr_norm RECALC')/10+686.28]))*100  ;
BACKTEST('ZPR error approx bathy for 24 hours (cm)') = smax(tb$(tf(tb) and DAILY(tb)),abs(z.l('pr',tb) - [report(tb,'zpr_norm RECALC')/10+684.7 ]))*100 ;
BACKTEST('vGR error approx bathy (scaled mÂ³)') = BACKTEST('ZGR error approx bathy for 24 hours (cm)')/100*1/2.5*1E6/scaling_volumes  ;
BACKTEST('vPR error approx bathy (scaled mÂ³)') = BACKTEST('ZPR error approx bathy for 24 hours (cm)')/100*1/2.5*1E5/scaling_volumes ;

parameter KPI(optimizer,*);

KPI('COOPT','PNL 24h') = sum(tb$(DAILY(tb)),spot(tb)*p.l(tb));

KPI('COOPT','PNL/MÂ³ 24h') = KPI('COOPT','PNL 24h') / sum(tb$(DAILY(tb)),3600*qtot.l(tb));





