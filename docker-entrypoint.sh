#!/bin/bash
set -e

# Solution from: https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
eval $(ssh-agent | sed 's/^echo/#echo/')

EXTS="YML YAML yml yaml"

KEYPATH=""

# check for ssh keys in preset paths, first match wins
for tempKEYPATH in "/sshkeys" "/keys" "/ansible/keys"
do
    if [[ -d $tempKEYPATH ]]
    then
        if [[ -z $KEYPATH ]]
        then
            KEYPATH="$tempKEYPATH"
        else
            echo "Warning: Multiple key paths found, using $KEYPATH and ignoring $tempKEYPATH"
        fi
    fi
done

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
        echo "Force use ssh keys from /inventory/keys" 
        KEYPATH="/inventory/keys"
    fi

    # The additional locations are only meaningful if the inventory root dir exists.
    FILES="$FILES /inventory/Inventory /inventory/INVENTORY /inventory/inventory /inventory/MAIN /inventory/Main /inventory/main"
fi 

if [[ -z $KEYPATH ]]
then
    echo "No ssh-keys path found, not adding any keys."
    echo "If you want to add private ssh keys, mount them to /sshkeys or /keys"
else
    echo "Adding ssh keys from $KEYPATH"
    ssh-add $(find ${KEYPATH}/* ! -name config ! -name '*.pub' ! -name known_hosts ! -name authorized_keys ! -name *.old ! -name .* )
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

# Bypass to bash on request (usefull for debugging)
if [[ "$@" = "shell" ]] || [[ "$@" = "bash" ]] || [[ "$@" = "sh" ]] || [[ "$@" = "/bin/bash" ]] || [[ "$@" = "/bin/sh" ]]  
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

# If no arguments are given, and no playbook is found, open a bash shell
[[ -z "$@" ]] && [[ -z $PLAYBOOK ]] && exec "/bin/bash"

## Run Ansible-Playbook

[[ ! -z $PLAYBOOK ]] && exec "ansible-playbook" $BECOME $INVENTORYP "$INVENTORY" "$@" $PLAYBOOK

[[ ! -z $INVENTORY ]] && exec "ansible-playbook" $BECOME $INVENTORYP "$INVENTORY" "$@"

# Otherwise run ansible directly with the given arguments
exec "ansible" "$@"
