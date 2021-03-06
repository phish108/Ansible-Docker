#!/bin/bash
set -e

# Solution from: https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
eval `ssh-agent | sed 's/^echo/#echo/'`

# automatically include any private keys that are provided in special volumes
if [[ -d /sshkeys ]]
then
    ssh-add `find /sshkeys/* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

if [[ -d /ansible/keys ]]
then
    ssh-add `find /ansible/keys/* ! -name config ! -name *.pub ! -name known_hosts ! -name authorized_keys`
fi

# if nothing is provided then enter the command line
if [[ -z "$@" ]]
then
    exec "bash"
fi

# otherwise run ansible directly
exec "ansible" "$@"
