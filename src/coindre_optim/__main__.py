import coindre_optim.runner
import logging
import argparse

if __name__ == "__main__":
    # setup logging
    logging.basicConfig(
        format="%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s",
        datefmt="%y-%m-%d %H:%M:%S",
        handlers=[logging.FileHandler("coindre_optim.log"), logging.StreamHandler()],
        level=logging.INFO,
    )

    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--help", action="help")
    parser.add_argument("--config_file", dest="config_file", nargs="?", default=None,
                        required=True,
                        help="Path to a yaml config file")
    args = parser.parse_args()

    runner = coindre_optim.runner.Runner(config_path=args.config_file)
    runner.launch()
