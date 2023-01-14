## Ansible-Docker

A small container provides the latest ansible runtime for immediate use.

### SYNOPSIS

```
docker run -it --rm \
    -v ~/.ssh:/sshkeys \
    -v ${my_playbook_inventory}:/ansible \
    ghcr.io/phish108/ansible-docker:v7.1.3-4
```

This assumes that there is a `main.yaml` file in the playbook volume that contains all relevant information about your play. See Section Autorunning below.

To enter the shell (starts into bash).

or run ansible commands directly 

```
docker run -it --rm \
    -v ~/.ssh:/sshkeys \
    -v ${my_inventory}:/inventory \
    -v ${my_playbooks}:/ansible \
    ghcr.io/phish108/ansible-docker:v7.1.3-4 \
        myplaybook.yml
```

To force to ask for the become password add ansible's `-K` option: 

```
docker run -it --rm \
    -v ~/.ssh:/sshkeys \
    -v ${my_inventory}:/inventory \
    -v ${my_playbooks}:/ansible \
    ghcr.io/phish108/ansible-docker:v7.1.3-4 \
        -K myplaybook.yml
```

Limiting to specific inventory groups, use ansible's `-l` option.

```
docker run -it --rm \
           -v ~/.ssh:/sshkeys \
           -v ${my_inventory}:/inventory \
           -v ${my_playbooks}:/ansible \
           ghcr.io/phish108/ansible-docker:v7.1.3-4 \
              -l testing myplaybook.yml
```

### Autorunning 

If you organise your playbooks that the inventory file is named ``inventory.yaml`` and the playbook is named ``playbook.yaml``, then these files are taken up automatically. Any other naming convention will not be automatically executed. 

If the inventory and the playbooks are separated, then the container looks for the files `/inventory/main.yaml` and `/ansible/main.yaml` for autoplay, if no other options are provided.

The container always includes ``inventory.yaml`` or ``/inventory/main.yaml``, if any of those is present. This allows to call the container as such: 

```
docker run -it --rm \
           -v ~/.ssh:/sshkeys \
           -v ${my_inventory}:/ansible \
           ghcr.io/phish108/ansible-docker:7.1.3-4  \
               myplaybook.yml myotherplaybook.yml
```

If `/ansible/main.yaml` or `/ansible/playbook.yaml` are present, then the container can be run without extra parameters.

```
docker run -it --rm \
           -v ~/.ssh:/sshkeys \
           -v ${my_inventory}:/ansible \
           ghcr.io/phish108/ansible-docker:7.1.3-4
```

When both files exists, then the container always uses `/ansible/main.yaml`.

***IMPORTANT*** When autorunning, then it is not possible to pass extra parameters. 

#### Avoid become password interaction

While autorunning this container asks for the become password by default. If no become password is required, then add the file `nobecome` to the root of the playbook volume. This will cause the container not to use the `-K` flag on `ansible-playbook`. 

The content of the file `nobecome` is irrelevant. The container just checks, if the file exists.

If run directly ansible expects to find the inventroy in the ```/ansible``` folder. 

## SSH Key Handling

You can include your private keys in the ```/sshkeys```, the ``/keys``, the ```/ansible/keys```, or the ``/inventory/keys`` folder. All private keys in this folder will be added automatically to the ssh-agent for password free authentication. 

Note that if your private keys are password protected, you need to enter (all) your key passwords before the container runs. Therefore, it is recommended to have a separate folder with special deployment keys. 

### Final Remarks 

This container is based on ubuntu 22.04 (jammy) and comes with a minimal setup that includes ansible plus a few useful tools. 
