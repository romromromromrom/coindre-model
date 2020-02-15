import coindre_optim.runner
import logging
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--help", action="help")
    parser.add_argument("--config_file", dest="config_file", nargs="?", default=None,
                        required=True,
                        help="Path to a yaml config file")
    parser.add_argument("--log_file", dest="log_file", nargs="?", default="coindre_optim.log",
                        required=False,
                        help="Path the file to be used for logging")
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s",
        datefmt="%y-%m-%d %H:%M:%S",
        handlers=[logging.FileHandler(args.log_file), logging.StreamHandler()],
        level=logging.INFO,
    )

    runner = coindre_optim.runner.Runner(config_path=args.config_file)
    runner.launch()
