# Standard library imports
import os

# Third party library imports
import pytz

print("__init__.py is being called")
default_config_path = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), "config.yml"
)
TZ = pytz.timezone("Europe/Brussels")
