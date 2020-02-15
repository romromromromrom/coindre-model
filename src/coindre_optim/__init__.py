import os

import pytz

default_config_path = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), "config.yml"
)
TZ = pytz.timezone("Europe/Brussels")
