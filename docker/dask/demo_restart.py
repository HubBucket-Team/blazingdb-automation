from distributed import Client
from time import sleep
from random import random


import os
print("=== blazing-orchestrator ===")
os.system("supervisorctl restart blazing-orchestrator")
sleep(random() / 10)


def restart_ral():
    import os
    print("=== blazing-ral ===")
    os.system("supervisorctl restart blazing-ral")
    sleep(random() / 10)
    return True


client = Client('127.0.0.1:8786')
job = client.run(restart_ral)

