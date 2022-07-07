#!/bin/bash

runtime=python3.8
dir_name=lambda_dist_pkg/
mkdir -p $dir_name

python3 -m venv lambda_function/.venv
source lambda_function/.venv/bin/activate
pip install -r lambda_function/requirements.txt
deactivate

cp -r lambda_function/.venv/lib/$runtime/site-packages/ $dir_name
cp -r lambda_function/ $dir_name
rm -r $dir_name/.venv


