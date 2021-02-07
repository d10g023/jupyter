#!/bin/bash
create() {
    # function used tu create and configurate virtualenv and jupyter 
    # python instalation
    sudo apt update
    sudo apt install python3-pip python3-dev python3-setuptools -y
    sudo -H pip3 install --upgrade pip
    # virtualenv instalation
    sudo -H pip3 install virtualenv
    mkdir $1
    cd $1
    # virtual env creation
    virtualenv $1_env
    source $1_env/bin/activate
    # jupyter instalation and configuration 
    pip install jupyter
    jupyter notebook --generate-config
    mkdir $1_env/cert
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout $1_env/cert/mykey.key -out $1_env/cert/mycert.pem -subj "/CN=$HOSTNAME"
    sed -i "s,^#.*c.NotebookApp.certfile = '',c.NotebookApp.certfile = u'$(pwd)/$1_env/cert/mycert.pem',g" ~/.jupyter/jupyter_notebook_config.py
    sed -i "s,^#.*c.NotebookApp.ip = 'localhost',c.NotebookApp.ip = '*',g" ~/.jupyter/jupyter_notebook_config.py
    sed -i "s,^#.*c.NotebookApp.keyfile = '',c.NotebookApp.keyfile = u'$(pwd)/$1_env/cert/mykey.key',g" ~/.jupyter/jupyter_notebook_config.py
    sed -i "s,^#.*c.NotebookApp.open_browser = True,c.NotebookApp.open_browser = False,g" ~/.jupyter/jupyter_notebook_config.py
    sed -i "s,^#.*c.NotebookApp.port = 8888,c.NotebookApp.port = 9999,g" ~/.jupyter/jupyter_notebook_config.py
    jupyter notebook password
    echo ""
    echo "Usage: source ${1}/${1}_env/bin/activate"
}
delete(){
    # function used to remove virtualenv and jupyter 
    source $1/$1_env/bin/activate || exit 1
    pip freeze > $1/req.out
    pip uninstall -r $1/req.out -y
    deactivate
    rm -rf $1
}
info(){
    # function used to get information
    echo "Usage: source ${1}/${1}_env/bin/activate"
}
if [[ $# -eq 2 ]]
then
    if [[ "$1" == "create" ]]
    then
        create $2
    elif [[ "$1" == "delete" ]]
    then
        delete $2
    elif [[ "$1" == "info" ]]
    then
        info $2
    fi
else
    echo "Usage: $0 <create|delete|info> <project_name>"
fi
