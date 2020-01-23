
set i /'gr','pr'/
set ptBat /ptBat1*ptBat10/;


Parameter cote_gr(ptBat)
/ptBat1        686.28
ptBat2         687.3
ptBat3         688.3
ptBat4         689.3
ptBat5         690.3
ptBat6         691.3
ptBat7         692
/
;
parameter volume_gr(ptBat)
/ptBat1        0
ptBat2         202000
ptBat3         435000
ptBat4         690000
ptBat5         992000
ptBat6         1334000
ptBat7         1593000
/
;


Parameter cote_pr(ptBat)
/ptBat1        684.7
ptBat2         685
ptBat3         686
ptBat4         687
ptBat5         688
ptBat6         689
ptBat7         690
ptBat8         691
ptBat9         692
/
;
parameter volume_pr(ptBat)
/ptBat1        0
ptBat2         8000
ptBat3         28000
ptBat4         50000
ptBat5         74000
ptBat6         104000
ptBat7         138000
ptBat8         176000
ptBat9         216000
/
;

parameter Bathy(i,ptBat,*);
Bathy(i,ptBat,'cote')$(ord(i)=1) = cote_gr(ptBat);
Bathy(i,ptBat,'volume')$(ord(i)=1) = volume_gr(ptBat);
Bathy(i,ptBat,'cote')$(ord(i)=2) = cote_pr(ptBat);
Bathy(i,ptBat,'volume')$(ord(i)=2)= volume_pr(ptBat);

execute_unload 'Bathymetry.gdx' Bathy ptBat

