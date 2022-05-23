#!/bin/bash
set -e

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

# if nothing is provided then enter the command line

if [[ -z "$@" ]]
then
    PLAYBOOK=
    INVENTORY=

    if [[ -f /ansible/inventory.yaml ]]
    then
        INVENTORY=/ansible/inventory.yaml
    fi

    if [[ -f /ansible/playbook.yaml ]]
    then
        PLAYBOOK=/ansible/playbook.yaml
    fi

    if [[ -z $PLAYBOOK ]]
    then
        exec "bash"
    fi

    # echo call ansible with $INVENTORY and $PLAYBOOK
    # FIXME: Drop -K again as it always asks for the password, which makes headless updates impossible
    exec "ansible-playbook" "-K" "-i" "$INVENTORY" "$PLAYBOOK"
fi

# otherwise run ansible directly
exec "ansible-playbook" "$@"
