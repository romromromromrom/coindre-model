import coindre_optim.runner as runner
import logging

if __name__ == "__main__":
    # setup logging
    logging.basicConfig(
        format="%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s",
        datefmt="%y-%m-%d %H:%M:%S",
        handlers=[logging.FileHandler("coindre_optim.log"), logging.StreamHandler()],
        level=logging.INFO,
    )

    runner_1 = runner.Runner()
    runner_1.launch()  # triggers imports from hdx for current day & runs the model
