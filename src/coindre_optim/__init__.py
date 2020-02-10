import pytz
import yaml
import os

print("__init__.py is being called")
with open(
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "config.yml")
) as config:
    config = yaml.load(config, Loader=yaml.FullLoader)

TZ = pytz.timezone(config["TIME_ZONE"])


if __name__ == "__main__":
    print(config)
