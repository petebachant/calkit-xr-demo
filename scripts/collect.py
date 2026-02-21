import os

import numpy as np
import pandas as pd

np.random.seed(622)

df = pd.DataFrame(
    {
        "x": np.random.rand(100),
        "y": np.random.rand(100),
        "z": np.random.rand(100),
    }
)

os.makedirs("data", exist_ok=True)

df.to_csv("data/raw.csv", index=False)
