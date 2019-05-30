"""
Missing value imputation
"""
import numpy as np
import pandas as pd

def generate_values(n_reps, desired_mean, desired_std):
    np.random.seed(99)
    random_data = np.random.normal(loc=0.0, scale=desired_std, size=n_reps)
    means = np.mean(random_data, axis=0)
    new_data = pd.Series(((random_data - means) * np.array((desired_std/(np.std(random_data-means, axis=0)))) + np.array(desired_mean))) 
    return new_data
    
def impute(data):
    missing_data = data.loc[data.isnull().sum(axis=1) > 0].copy()
    data_min = np.min(data.min())
    missing_data.fillna(data_min, inplace=True)
    for rows in missing_data.iterrows():
        name = rows[0]
        random_values = generate_values(n_reps = np.shape(data)[1], 
                                        desired_mean = missing_data.mean(axis=1).loc[name], 
                                        desired_std = np.mean(data.std(axis=1)))
        random_values.index = rows[1].index
        missing_data.loc[name] = random_values
    data.loc[missing_data.index] = missing_data
    data.fillna(data_min, inplace=True)
    return data