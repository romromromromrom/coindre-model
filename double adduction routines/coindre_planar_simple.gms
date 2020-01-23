sets k1 /k1-1*k1-101/
     k2 /k2-1*k2-401/
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
         fit('grpr','0',k1,k2)$(zone('grpr',k1,k2))=yes;
* PRGR CASE
         fit('prgr','0',k1,k2)$(zone('prgr',k1,k2))=yes;


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
p_grpr(k1,k2) = plane('grpr','0',k1,k2);

* PRGR CASE
*        0
         fit_run(k1,k2) = fit('prgr','0',k1,k2);
         origin = 0; weight = 0;
         solve approx_plan us LP min of;
         origin = 0; weight = 0;
         coeffs('nq','prgr','0')=a.l;
         coeffs('nz','prgr','0')=b.l;
         coeffs('nc','prgr','0')=c.l;
         plane('prgr','0',k1,k2)= coeffs('nq','prgr','0')*qtot(k1) + coeffs('nz','prgr','0')*dz(k2) + coeffs('nc','prgr','0');
p_prgr(k1,k2) = plane('prgr','0',k1,k2);





************ compute the approximated characteristic ******
parameter q1_approx(k1,k2), error(k1,k2);
scalars
         dz_grpr_1
         dz_grpr_2 /-1/
         dz_grpr_3 /0/
         dz_prgr_1 /0/
         dz_prgr_2 /1/
         dz_prgr_3

         Qt_grpr_1
         Qt_grpr_2
         Qt_grpr_3
         Qt_prgr_1
         Qt_prgr_2
         Qt_prgr_3
;
dz_grpr_1 = dzmin; dz_prgr_3 = dzmax;
Qt_grpr_1 = sqrt(abs(dz_grpr_1)/j1);
Qt_grpr_2 = sqrt(abs(dz_grpr_2)/j1);
Qt_grpr_3 = sqrt(abs(dz_grpr_3)/j1);
Qt_prgr_1 = sqrt(abs(dz_prgr_1)/j2);
Qt_prgr_2 = sqrt(abs(dz_prgr_2)/j2);
Qt_prgr_3 = sqrt(abs(dz_prgr_3)/j2);


parameter seg_grpr_1(k2),seg_grpr_2(k2);
parameter seg_prgr_1(k2),seg_prgr_2(k2);

seg_grpr_1(k2) = (Qt_grpr_2 - Qt_grpr_1)/(dz_grpr_2 - dz_grpr_1)*(dz(k2) - dz_grpr_1) + Qt_grpr_1;
seg_grpr_2(k2) = (Qt_grpr_3 - Qt_grpr_2)/(dz_grpr_3 - dz_grpr_2)*(dz(k2) - dz_grpr_2) + Qt_grpr_2;
seg_prgr_1(k2) = (Qt_prgr_2 - Qt_prgr_1)/(dz_prgr_2 - dz_prgr_1)*(dz(k2) - dz_prgr_1) + Qt_prgr_1;
seg_prgr_2(k2) = (Qt_prgr_3 - Qt_prgr_2)/(dz_prgr_3 - dz_prgr_2)*(dz(k2) - dz_prgr_2) + Qt_prgr_2;

scalar
fac_grpr /1/
offset_grpr /0/
fac_prgr /1/
offset_prgr /0/
q1_lim 'flow rate of transfer under which the flow rate will be approximated to 0 m³/s ' /0.5/
;

q1_approx(k1,k2) = p_sstr(k1,k2);
q1_approx(k1,k2)$(qtot(k1)<=fac_grpr*seg_grpr_1(k2)+offset_grpr and qtot(k1) <= fac_grpr*seg_grpr_2(k2)+offset_grpr and dz(k2)<=-0.2) =  p_grpr(k1,k2);
q1_approx(k1,k2)$(qtot(k1)<=fac_prgr*seg_prgr_1(k2) and qtot(k1) <= fac_prgr*seg_prgr_2(k2) and dz(k2)>= 0.2) =  p_prgr(k1,k2);




************error computation *****************************
error(k1,k2)$(yes) = q1_approx(k1,k2) - q1(k1,k2);
parameter q2(k1,k2); q2(k1,k2) = Qtot(k1) - q1(k1,k2)  ;




execute_unload 'adduction_planes.gdx'


