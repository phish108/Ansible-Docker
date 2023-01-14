#!/bin/bash
set -e

# Solution from: https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
eval $(ssh-agent | sed 's/^echo/#echo/')

EXTS="YML YAML yml yaml"

# automatically include any private keys that are provided in special volumes
if [[ -d /sshkeys ]]
then
    ssh-add `find /sshkeys/id_* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

if [[ -d /keys ]]
then
    ssh-add `find /keys/id_* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

if [[ -d /ansible/keys ]]
then
    ssh-add `find /ansible/keys/* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

INVENTORY=

FILES="/ansible/inventory /ansible/Inventory /ansible/INVENTORY"

if [[ -d /inventory ]]
then
    if [[ -d /inventory/keys ]]
    then
        ssh-add `find /inventory/keys/id_* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
    fi

    FILES="$FILES /inventory/Inventory /inventory/INVENTORY /inventory/inventory /inventory/MAIN /inventory/Main /inventory/main"
fi 

for FILE in $FILES
do
    for EXT in $EXTS
    do
        if [[ -f "${FILE}.$EXT" ]]
        then
            INVENTORY="${FILE}.$EXT"
        fi
    done
done 

if [[ -z "$@" ]]
then
    PLAYBOOK=

    PREFIX="PLAYBOOK MAIN Playbook Main playbook main"

    for FILE in $PREFIX
    do
        for EXT in $EXTS
        do
            if [[ -f "/ansible/${FILE}.${EXT}" ]]
            then
                PLAYBOOK="/ansible/${FILE}.${EXT}"
            fi
        done
    done

    # if nothing is provided then enter the command line
    if [[ -z $PLAYBOOK ]]
    then
        exec "/bin/bash"
    fi

    # echo call ansible with $INVENTORY and $PLAYBOOK
    if [[ -f /ansible/nobecome ]] 
    then
        exec "ansible-playbook" "-i" "$INVENTORY" "$PLAYBOOK"
    fi

    exec "ansible-playbook" "-K" "-i" "$INVENTORY" "$PLAYBOOK"
fi

# In case we have an inventory, we use it 
if [[ ! -z $INVENTORY ]] 
then
    if [[ -f /ansible/nobecome ]] 
    then
        exec "ansible-playbook" "-i" "$INVENTORY" "$@"
    fi

    exec "ansible-playbook" -K -i "$INVENTORY" "$@"
fi

# otherwise run ansible directly
exec "ansible" "$@"
