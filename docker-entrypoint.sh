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

# Default values
INVENTORY=
INVENTORYP=
BECOME="-K"
PLAYBOOK=

if [[ -f /ansible/nobecome ]] 
then
    BECOME=""
fi

# The default location are always possible.
FILES="/ansible/inventory /ansible/Inventory /ansible/INVENTORY"

if [[ -d /inventory ]]
then
    # Check if private keys are in the inventory directory 
    # (they should not be, though)
    if [[ -d /inventory/keys ]]
    then
        ssh-add $(find /inventory/keys/id_* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys)
    fi

    # The additional locations are only meaningful if the inventory root dir exists.
    FILES="$FILES /inventory/Inventory /inventory/INVENTORY /inventory/inventory /inventory/MAIN /inventory/Main /inventory/main"
fi 

# Find an inventory
for FILE in $FILES
do
    for EXT in $EXTS
    do
        if [[ -f "${FILE}.$EXT" ]]
        then
            INVENTORYP="-i"
            INVENTORY="${FILE}.$EXT"
        fi
    done
done 

# Find a playbook
PB_PREFIX="PLAYBOOK MAIN Playbook Main playbook main"

for FILE in $PB_PREFIX
do
    for EXT in $EXTS
    do
        if [[ -f "/ansible/${FILE}.${EXT}" ]]
        then
            PLAYBOOK="/ansible/${FILE}.${EXT}"
        fi
    done
done

## Bypass Commands

# Bypass to bash on request
if [[ "$@" = "shell" ]]
then
    exec "/bin/bash"
fi

# Handle the ping command if requested
if [[ "$@" = "ping" ]]
then
    if [[ ! -z $INVENTORY ]] 
    then
        exec "ansible" $INVENTORYP "$INVENTORY" "-m" "ping" "all"
    fi

    echo "no inventory to ping against"
    exit 1
fi

if [[ -z "$@" ]] && [[ -z $PLAYBOOK ]]
then
    exec "/bin/bash"
fi

## Run Ansible-Playbook

[[ ! -z $PLAYBOOK ]] && exec "ansible-playbook" $BECOME $INVENTORYP "$INVENTORY" "$@" $PLAYBOOK

[[ ! -z $INVENTORY ]] && exec "ansible-playbook" $BECOME $INVENTORYP "$INVENTORY" "$@"

# Otherwise run ansible directly

exec "ansible" "$@"
