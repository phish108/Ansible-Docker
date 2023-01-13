#!/bin/bash
set -e

PATH=/ansible/.local/bin:$PATH

# Solution from: https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
eval $(ssh-agent | sed 's/^echo/#echo/')

# automatically include any private keys that are provided in special volumes
if [[ -d /sshkeys ]]
then
    ssh-add `find /sshkeys/id_* ! -name *.pub`
fi

if [[ -d /ansible/keys ]]
then
    ssh-add `find /ansible/keys/* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

INVENTORY=

if [[ -f /ansible/inventory.yaml ]]
then
    INVENTORY=/ansible/inventory.yaml
fi

# This is very handy because the inventory is private and the playbook can be public most of the time. 
if [ -d /inventory ] && [ -f /inventory/main.yaml ]
then    
    INVENTORY=/inventory/main.yaml
fi

if [[ -z "$@" ]]
then
    PLAYBOOK=

    if [[ -f /ansible/main.yaml ]]
    then
        PLAYBOOK=/ansible/main.yaml
    fi

    # if nothing is provided then enter the command line
    if [[ -z $PLAYBOOK ]]
    then
        exec "bash"
    fi

    # echo call ansible with $INVENTORY and $PLAYBOOK
    exec "ansible-playbook" "-K" "-i" "$INVENTORY" "$PLAYBOOK"
fi

# In case we have an inventory, we use it 
if [[ ! -z $INVENTORY ]] 
then
    exec "ansible-playbook" $SSH_EXT_HOSTS -i "$INVENTORY" "$@"
fi

# otherwise run ansible directly
exec "ansible" "$@"
