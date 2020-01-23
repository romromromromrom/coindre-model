sets k1 /k1-1*k1-51/
     k2 /k2-1*k2-51/
     case /sstr,grpr,prgr/
     zone(case,k1,k2)
     zone_fitting(case,k1,k2)
     zone_check(k1,k2)
;
parameter dz(k2)
          Qtot(k1)
          q1_expr(case,k1,k2)
          q1(k1,k2)
          delta(case,k1,k2)

;
scalars j1 /0.016473/
        j2 /0.065089/
        dzmax /10/
        dzmin /-10/
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


zone_check(k1,k2)$(zone('grpr',k1,k2) or zone('prgr',k1,k2) or zone('sstr',k1,k2)) = yes;
scalar TEST_ZONES /1/;
Loop(k1,
         Loop(k2,
                  TEST_ZONES = TEST_ZONES*(1$(zone_check(k1,k2)) + 0$(not zone_check(k1,k2)));
         );
);


q1(k1,k2)$(zone('grpr',k1,k2))  =  q1_expr('grpr',k1,k2);
q1(k1,k2)$(zone('prgr',k1,k2))  =  q1_expr('prgr',k1,k2);
q1(k1,k2)$(zone('sstr',k1,k2))  =   q1_expr('sstr',k1,k2);

******** fitting the sstr plan ****************************************************************************
scalar  origin 'a value of 1 wil lensure that the plane has the origin in it'  /0/;
scalar weight /0/;
variables a,b,c,p(k1,k2),diff(k1,k2),t(k1,k2),of;
t.lo(k1,k2)=0;
************** MODEL FORMUALTION *********************
set fit_run(k1,k2);
equations
eq1
eq2
eq3
eq4
eq5
eq_origin
;
eq1(k1,k2)$(fit_run(k1,k2))                          .. p(k1,k2) =e= a*Qtot(k1) + b*dz(k2)+c  ;
eq2(k1,k2)$(fit_run(k1,k2)) .. diff(k1,k2) =e= ((weight/(Qtot(k1)+0.0001)*1/(abs(dz(k2))+0.0001))$(weight>0) + 1$(not weight>0))*(p(k1,k2) - q1(k1,k2));
eq3(case,k1,k2)$(fit_run(k1,k2)) .. t(k1,k2) =g= diff(k1,k2);
eq4(case,k1,k2)$(fit_run(k1,k2)) .. -t(k1,k2) =l= diff(k1,k2);
eq5 .. of =e= sum((k1,k2)$(fit_run(k1,k2)) , t(k1,k2));
eq_origin$(origin)      .. c=e=0;
model approx_plan /eq1,eq2,eq3,eq4,eq5,eq_origin/;

************** definition of the fitting zones*************
set fit(case,*,k1,k2);
* SSTR CASE
         fit('sstr','0',k1,k2)$(Qtot(k1)>=35)=yes;
* GRPR CASE
         scalars
         z_grpr_01 /-0.7/
         fac_grpr_02 /0.6/
         ;
         fit('grpr','0',k1,k2)$(qtot(k1)<= fac_grpr_02*sqrt(abs(dz(k2))/j1) and dz(k2)<=0 and zone('grpr',k1,k2))=yes;
         fit('grpr','1',k1,k2)$(dz(k2)>=z_grpr_01 and zone('grpr',k1,k2)) = yes;
         fit('grpr','2',k1,k2)$(dz(k2)<-2 and qtot(k1)> 0.9*sqrt(abs(dz(k2))/j1) and qtot(k1)<= sqrt(abs(dz(k2))/j1) and zone('grpr',k1,k2)) = yes;
* PRGR CASE
         fit('prgr','0',k1,k2)$(qtot(k1) <= 2*sqrt(abs(dz(k2))/j2))=yes;


************* run the models ***************************
parameters coeffs(*,case,*);
parameters plane(case,*,k1,k2),p_sstr(k1,k2),p_grpr(k1,k2),p_prgr(k1,k2);
* SSTR CASE
         fit_run(k1,k2) = fit('sstr','0',k1,k2);
         origin = 1;
         solve approx_plan us LP min of;
         origin = 0;
         coeffs('nq','sstr','0')=a.l;
         coeffs('nz','sstr','0')=b.l;
         coeffs('nc','sstr','0')=c.l;
         plane('sstr','0',k1,k2)= coeffs('nq','sstr','0')*qtot(k1) + coeffs('nz','sstr','0')*dz(k2) + coeffs('nc','sstr','0');
p_sstr(k1,k2) = plane('sstr','0',k1,k2);

* GRPR CASE
*        0
         fit_run(k1,k2) = fit('grpr','0',k1,k2);
         solve approx_plan us LP min of;
         coeffs('nq','grpr','0')=a.l;
         coeffs('nz','grpr','0')=b.l;
         coeffs('nc','grpr','0')=c.l;
         plane('grpr','0',k1,k2)= coeffs('nq','grpr','0')*qtot(k1) + coeffs('nz','grpr','0')*dz(k2) + coeffs('nc','grpr','0');
*        1
         fit_run(k1,k2) = fit('grpr','1',k1,k2);
         origin = 1; weight = 0;
         solve approx_plan us LP min of;
         origin = 0; weight = 0;
         coeffs('nq','grpr','1')=a.l;
         coeffs('nz','grpr','1')=b.l;
         coeffs('nc','grpr','1')=c.l;
         plane('grpr','1',k1,k2)= coeffs('nq','grpr','1')*qtot(k1) + coeffs('nz','grpr','1')*dz(k2) + coeffs('nc','grpr','1');
*        2
         fit_run(k1,k2) = fit('grpr','2',k1,k2);
         solve approx_plan us LP min of;
         coeffs('nq','grpr','2')=a.l;
         coeffs('nz','grpr','2')=b.l;
         coeffs('nc','grpr','2')=c.l;
         plane('grpr','2',k1,k2)= coeffs('nq','grpr','2')*qtot(k1) + coeffs('nz','grpr','2')*dz(k2) + coeffs('nc','grpr','2');
p_grpr(k1,k2) = min(plane('grpr','0',k1,k2),plane('grpr','1',k1,k2),plane('grpr','2',k1,k2));

* PRGR CASE
*        0
         fit_run(k1,k2) = fit('prgr','0',k1,k2);
         origin = 1; weight = 0;
         solve approx_plan us LP min of;
         origin = 0; weight = 0;
         coeffs('nq','prgr','0')=a.l;
         coeffs('nz','prgr','0')=b.l;
         coeffs('nc','prgr','0')=c.l;
         plane('prgr','0',k1,k2)= coeffs('nq','prgr','0')*qtot(k1) + coeffs('nz','prgr','0')*dz(k2) + coeffs('nc','prgr','0');
p_prgr(k1,k2) = plane('prgr','0',k1,k2);





************ compute the approximated characteristic ******
parameter q1_approx(k1,k2), error(k1,k2); q1_approx(k1,k2) = Eps;
q1_approx(k1,k2) = max(p_sstr(k1,k2),p_grpr(k1,k2));
q1_approx(k1,k2)$(dz(k2)>=0) = min(q1_approx(k1,k2),p_prgr(k1,k2));


************error computation *****************************
error(k1,k2)$(yes) = q1_approx(k1,k2) - q1(k1,k2);
parameter difference(k1,k2);
difference(k1,k2) = Eps;
difference(k1,k2) = q1(k1,k2) - p_sstr(k1,k2);
parameter q1_mini(k1,k2);q1_mini(k1,k2) = Eps; q1_mini(k1,k2)$(Qtot(k1)>=4) = q1(k1,k2);
alias(k1,i);alias(k2,j);
q1_mini(k1,k2)$(q1(k1,k2)=smax((i,j),q1(i,j)) or q1(k1,k2)=smin((i,j),q1(i,j))) = q1(k1,k2);













execute_unload 'adduction_planes.gdx'


