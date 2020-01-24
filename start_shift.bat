@ECHO OFF

"%USERPROFILE%\pyxelrest\env\Scripts\python.exe" start_shift_python.py
"%USERPROFILE%\pyxelrest\env\Scripts\python.exe" "X:\02_0164\19_ETS\14_BLU\GEM\python_common\upload_meteor_prices.py"

start  "C:\Program Files\Google\Chrome\Application" chrome.exe --new-window https://hydro.bluesafire.io/admin/
