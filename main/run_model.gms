$setglobal ide ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1
$SETGLOBAL COMMON_DIRECTORY C:\Users\WH5939\Documents\gamsdir\projdir\Coindre modelling\Versions\COOPT_V6.0

$call gams "%COMMON_DIRECTORY%\main\COOPT.gms" --MIP_GAP=0.01 --RUN_NUM=0 --INFLOWS_FACT=1 %ide% --COMMON_DIRECTORY="%COMMON_DIRECTORY%"
$if errorlevel 1 $abort RUN HAS FAILED




