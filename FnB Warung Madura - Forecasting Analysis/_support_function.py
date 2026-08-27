import pandas as pd
import numpy as np

def result_reporting(
                                data_train,
                                data_valid,
                                data_test,
                                columns,
                                model_name = None,
                                data_type = None,
                                idx = None,
                                melt_var = {'id_vars' : None, 'var_name' : None, 'value_name' : None}
) :

    train_for_reporting = pd.DataFrame(
                                index   = idx[0],
                                columns = columns,
                                data    = data_train
    )
    valid_for_reporting = pd.DataFrame(
                                index   = idx[1],
                                columns = columns,
                                data    = data_valid
    )
    test_for_reporting  = pd.DataFrame(
                                index   = idx[2],
                                columns = columns,
                                data = data_test
    )

    # Unpivot Data
    train_for_reporting =   train_for_reporting.reset_index().melt(id_vars = melt_var['id_vars'], var_name = melt_var['var_name'], value_name = melt_var['value_name'])
    valid_for_reporting =   valid_for_reporting.reset_index().melt(id_vars = melt_var['id_vars'], var_name = melt_var['var_name'], value_name = melt_var['value_name'])
    test_for_reporting  =   test_for_reporting.reset_index().melt(id_vars = melt_var['id_vars'], var_name = melt_var['var_name'], value_name = melt_var['value_name'])

    if model_name == None :
        train_for_reporting['model'] = '-'
        valid_for_reporting['model'] = '-'
        test_for_reporting['model']  = '-'
    else :
        train_for_reporting['model'] = model_name
        valid_for_reporting['model'] = model_name
        test_for_reporting['model']  = model_name

    if data_type == None :
        train_for_reporting['type']  = 'Actual'
        valid_for_reporting['type']  = 'Actual'
        test_for_reporting['type']   = 'Actual'
    else :
        train_for_reporting['type']  = data_type
        valid_for_reporting['type']  = data_type
        test_for_reporting['type']   = data_type

    train_for_reporting['part']  = 'Train'
    valid_for_reporting['part']  = 'Valid'
    test_for_reporting['part']   = 'Test'

    all_results = pd.concat([ train_for_reporting,   valid_for_reporting,  test_for_reporting])

    return all_results

def splitting_data(X, y, train_size, valid_size, test_size) :
    
    if train_size < 1 :
        train_size = int(len(X) * train_size)

    if valid_size < 1 :
        valid_size = int(len(X) * valid_size)

    if test_size < 1 :
        test_size = int(len(X) * test_size)

    X_train = X[:train_size]
    y_train = y[:train_size]
    X_valid = X[train_size:train_size + valid_size]
    y_valid = y[train_size:train_size + valid_size]
    X_test  = X[train_size + valid_size:]
    y_test  = y[train_size + valid_size:]

    return (X_train, y_train), (X_valid, y_valid), (X_test, y_test)

def create_window(data, window_size):
    feature_data = []
    pred_data = []

    for i in range(window_size, len(data)) :
        seq_data  = data[i - window_size : i]
        prediction_data = data[i]

        feature_data.append(seq_data)
        pred_data.append(prediction_data)

    return feature_data, pred_data
