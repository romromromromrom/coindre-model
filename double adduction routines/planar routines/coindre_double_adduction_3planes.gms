********************************************
********** CONTROL OPTIONS *****************
********************************************
scalar use_dz_threshold 'set to 1 if you want to have a dz \in  [-dz_threshol , dz_threshold] where the ' /1/;

********************************************
sets k1 /k1-1*k1-101/
     k2 /k2-1*k2-101/
     case /sstr,grpr,prgr/
     zone(case,k1,k2)
     zone_fitting(case,k1,k2)
     zone_check(k1,k2)
     index /index1*index100/
;
parameter dz(k2)
          Qtot(k1)
          q1_expr(case,k1,k2)
          q1(k1,k2)
          delta(case,k1,k2)

;
scalars j1 /0.016473/
        j2 /0.065089/
        dzmax /3/
        dzmin /-3/
        Qtot_min /0/
        Qtot_max /50/
;

Qtot(k1) = Qtot_min + (Qtot_max - Qtot_min)*(ord(k1) - 1)/(card(k1) - 1);
dz(k2) = dzmin + (dzmax - dzmin)*(ord(k2) -1)/(card(k2) -1);


delta('grpr',k1,k2) = power(j2*Qtot(k1),2) - (j1 + j2)*(dz(k2) + j2*power(Qtot(k1),2));
delta('prgr',k1,k2) = power(j2*Qtot(k1),2) + (j1 + j2)*(dz(k2) - j2*power(Qtot(k1),2));
delta('sstr',k1,k2)  = power(j2*Qtot(k1),2) - (j1 - j2)*(dz(k2) - j2*power(Qtot(k1),2));

q1_expr('grpr',k1,k2)$(delta('grpr',k1,k2) >= 0) = 1/(j1 + j2)*( j2*qtot(k1) + sqrt(delta('grpr',k1,k2))  )  ;
q1_expr('prgr',k1,k2)$(delta('prgr',k1,k2) >= 0) = 1/(j1 + j2)*( j2*qtot(k1) - sqrt(delta('prgr',k1,k2))  )  ;
q1_expr('sstr',k1,k2)$(delta('sstr',k1,k2) >= 0) = 1/(j1 - j2)*(  -j2*qtot(k1) + sqrt(delta('sstr', k1,k2))  )  ;

zone('grpr',k1,k2)$(dz(k2) < 0 and qtot(k1)<= sqrt(abs(dz(k2))/j1)) = yes ;
zone('prgr',k1,k2)$(dz(k2) >=  0 and qtot(k1)<= sqrt( abs(dz(k2))/j2)) = yes ;
zone('sstr',k1,k2)$((not zone('grpr',k1,k2)) and (not zone('prgr',k1,k2)$(dz(k2)))) = yes;

* The reunion of all the zones should cover the whole domain
zone_check(k1,k2)$(zone('grpr',k1,k2) or zone('prgr',k1,k2) or zone('sstr',k1,k2)) = yes;
scalar TEST_ZONES /1/;
Loop(k1,
         Loop(k2,
                  TEST_ZONES = TEST_ZONES*(1$(zone_check(k1,k2)) + 0$(not zone_check(k1,k2)));
         );
);


* IF the zones are completive and exclusive then, the actual transfer characteristic is built
if(TEST_ZONES=1,
         q1(k1,k2)$(zone('grpr',k1,k2))  =  q1_expr('grpr',k1,k2);
         q1(k1,k2)$(zone('prgr',k1,k2))  =  q1_expr('prgr',k1,k2);
         q1(k1,k2)$(zone('sstr',k1,k2))  =  q1_expr('sstr',k1,k2);

);


************** MODEL INSTANCE *********************
scalar  origin 'a value of 1 wil lensure that the plane has the origin in it'  /0/;
variables a,b,c,p(k1,k2),diff(k1,k2),t(k1,k2),of;
t.lo(k1,k2)=0;
set fit_run(k1,k2);
scalar z_tune /1/
       tol    /0.5/;
equations
eq1
eq2
eq3
eq4
eq5
eq6
eq7
eq_origin
;
eq1(k1,k2)$(fit_run(k1,k2))                          .. p(k1,k2) =e= a*Qtot(k1) + b*dz(k2)+c  ;
eq2(k1,k2)$(fit_run(k1,k2)) .. diff(k1,k2) =e= p(k1,k2) - q1(k1,k2);
eq3(k1,k2)$(fit_run(k1,k2)) .. t(k1,k2) =g= diff(k1,k2);
eq4(k1,k2)$(fit_run(k1,k2)) .. -t(k1,k2) =l= diff(k1,k2);
eq5 .. of =e= sum((k1,k2)$(fit_run(k1,k2)) , t(k1,k2));
eq6(k1,k2)$(fit_run(k1,k2) and dz(k2)<=z_tune and  dz(k2)>= -z_tune) .. diff(k1,k2) =l=  tol ;
eq7(k1,k2)$(fit_run(k1,k2) and dz(k2)<=z_tune and  dz(k2)>= -z_tune) .. diff(k1,k2) =g= -tol ;

eq_origin$(origin=1)      .. c=e=0;

model approx_plan /eq1,eq2,eq3,eq4,eq5,eq6,eq7,eq_origin/;

************** points for fitting the planes *************
set fit(case,*,k1,k2);
* SSTR CASE
         fit('sstr','index1',k1,k2)$(Qtot(k1)>=35)=yes;
* GRPR CASE
         fit('grpr','index1',k1,k2)$(zone('grpr',k1,k2) )=yes;
* PRGR CASE
         fit('prgr','index1',k1,k2)$(zone('prgr',k1,k2) )=yes;



************* run the models ***************************
set var /qt,dz,const/

parameters n(var,case,index);
parameters plane(case,*,k1,k2),p_sstr(k1,k2),p_grpr(k1,k2),p_prgr(k1,k2);
* SSTR CASE
         fit_run(k1,k2) = fit('sstr','index1',k1,k2);
         origin = 1;
         solve approx_plan us LP min of;
         origin = 0;
         n('qt','sstr','index1')=a.l;
         n('dz','sstr','index1')=b.l;
         n('const','sstr','index1')=c.l;
         plane('sstr','index1',k1,k2)= n('qt','sstr','index1')*qtot(k1) + n('dz','sstr','index1')*dz(k2) + n('const','sstr','index1');
p_sstr(k1,k2) = plane('sstr','index1',k1,k2);

* GRPR CASE
*        0
         fit_run(k1,k2) = fit('grpr','index1',k1,k2);
         solve approx_plan us LP min of;
         n('qt','grpr','index1')=a.l;
         n('dz','grpr','index1')=b.l;
         n('const','grpr','index1')=c.l;
         plane('grpr','index1',k1,k2)= n('qt','grpr','index1')*qtot(k1) + n('dz','grpr','index1')*dz(k2) + n('const','grpr','index1');
p_grpr(k1,k2) = plane('grpr','index1',k1,k2);

* PRGR CASE
*        0
         fit_run(k1,k2) = fit('prgr','index1',k1,k2);
         origin = 0;
         solve approx_plan us LP min of;
         origin = 0;
         n('qt','prgr','index1')=a.l;
         n('dz','prgr','index1')=b.l;
         n('const','prgr','index1')=c.l;
         plane('prgr','index1',k1,k2)= n('qt','prgr','index1')*qtot(k1) + n('dz','prgr','index1')*dz(k2) + n('const','prgr','index1');
p_prgr(k1,k2) = plane('prgr','index1',k1,k2);





************ compute the approximated characteristic ******
parameter q1_approx(k1,k2), error(k1,k2);
scalars  dz_threshold 'flow rate of transfer under which the flow rate will be approximated to 0 m�/s ' /0.06/;

parameter bkpt(case,var,index) 'the breakpoints on both limits sstr-grpr and sstr-prgr';
bkpt('grpr','dz','index1') = dzmin;
bkpt('grpr','dz','index2') = -1;
bkpt('grpr','dz','index3') = Eps;
bkpt('prgr','dz','index1') = Eps;
bkpt('prgr','dz','index2') = 1;
bkpt('prgr','dz','index3') = dzmax;


bkpt(case,'qt',index)$(ord(case)>=2) = sqrt(abs(bkpt(case,'dz',index))/(j1$(ord(case)=2) + j2$(ord(case)=3)  )) ;


set alpha /alpha1,alpha2/;
parameter seg(case,alpha,index);
seg(case,'alpha1',index)$(ord(index)<3 and ord(case)>1) = (bkpt(case,'qt',index+1)-bkpt(case,'qt',index))/(bkpt(case,'dz',index+1)-bkpt(case,'dz',index));
seg(case,'alpha2',index)$(ord(index)<3 and ord(case)>1) = bkpt(case,'qt',index) - bkpt(case,'dz',index)*seg(case,'alpha1',index);


q1_approx(k1,k2) = p_sstr(k1,k2);
q1_approx(k1,k2)$(    qtot(k1)<= seg('grpr','alpha1','index1')*dz(k2) + seg('grpr','alpha2','index1')
                      and qtot(k1)<= seg('grpr','alpha1','index2')*dz(k2) + seg('grpr','alpha2','index2')
                      and dz(k2)<=-dz_threshold) =  p_grpr(k1,k2);
q1_approx(k1,k2)$(    qtot(k1)<= seg('prgr','alpha1','index1')*dz(k2) + seg('prgr','alpha2','index1')
                      and qtot(k1) <= seg('prgr','alpha1','index2')*dz(k2) + seg('prgr','alpha2','index2')
                      and dz(k2)>= dz_threshold) =  p_prgr(k1,k2);




************error computation *****************************
error(k1,k2)$(yes) = q1_approx(k1,k2) - q1(k1,k2);
parameter q2(k1,k2); q2(k1,k2) = Qtot(k1) - q1(k1,k2)  ;



execute_unload 'adduction_planes.gdx'