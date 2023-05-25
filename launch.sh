#!/bin/bash

# Bash script for launching Rescale App using jupyter4all hack

## Apply Rescale Jupyter Notebook hack
. ~/jupyter-venv/bin/activate
RESCALE_PYTHON_TOKEN=`jupyter notebook list | grep token | sed --regexp-extended 's/.*token=([a-z0-9]*).*/\1/g'`
MATCH="jupyter"

function killall() {
  proc_arry=($(ps -ef | grep $1 | awk '{print $2}'))

  for i in "${proc_arry[@]}"
  do
    kill -9 $i
  done
}

killall $MATCH
deactivate

## Set up desired Python environment
PYTHON_VERSION=3.9

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
eval "$(/${HOME}/miniconda/bin/conda shell.bash hook)"
rm ~/miniconda.sh

conda create -y --name RESCALE python=$PYTHON_VERSION
conda activate RESCALE
pip install --upgrade pip

## Install dependencies and start the web server
pip install -r requirements.txt

export PYMAPDL_MAPDL_EXEC=`find /program/ -type f -name mapdl | head -1`
gunicorn --certfile $HOME/.certs/nb.pem --keyfile $HOME/.certs/nb.key -b 0.0.0.0:8888 app:server
