#!/bin/sh
export PATH=/opt/gams/gams30.2_linux_x64_64_sfx:$PATH
cd /home/romain.michel/coindre/
rm logfile.log
rm stdout.log
source ./venv/bin/activate
cd coindre-model/src
python -m coindre_optim --config_file /home/romain.michel/coindre/config.yml --log_file /home/romain.michel/coindre/logfile.log 2>&1 | tee /home/romain.michel/coindre/stdout.log
