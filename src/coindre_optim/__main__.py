import sys
sys.path.append(r"C:\Users\WH5939\Documents\coindre-model\src\coindre_optim")
import coindre_optim.runner as runner

if __name__ == "__main__":
    runner_1 = runner.Runner()
    runner_1.launch() # triggers imports from hdx for current day & runs the model




