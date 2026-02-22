import os

import numpy as np
import pandas as pd

np.random.seed(622)

n = 100

df = pd.DataFrame(
    {
        "x": np.random.rand(n),
        "y": np.random.rand(n),
        "z": np.random.rand(n),
    }
)

os.makedirs("data", exist_ok=True)

df.to_csv("data/raw.csv", index=False)
