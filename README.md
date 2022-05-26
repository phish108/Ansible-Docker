## Ansible 

A small container provides the latest ansible runtime for immediate use.

### SYNOPSIS

```
docker run -it --rm -v ~/.ssh:/sshkeys -v ${my_inventory}:/ansible phish108/ansible:latest
```

To enter the shell (starts into bash).

or run ansible commands directly 

```
docker run -it --rm -v ~/.ssh:/sshkeys -v ${my_inventory}:/ansible phish108/ansible:latest -i myinventory.yml myplaybook.yml
```

### Autorunning 

If you organise your playbooks that the inventory file is named ``inventory.yaml`` and the playbook is named ``playbook.yaml``, then these files are taken up automatically. Any other naming convention will not be automatically executed. 

The container always includes ``inventory.yaml`` if present. This allows to call the container as such: 

```
docker run -it --rm -v ~/.ssh:/sshkeys -v ${my_inventory}:/ansible phish108/ansible:latest myplaybook.yml myotherplaybook.yml
```

### Remarks 

This container is based on ubuntu 22.04 (jammy) and comes with a minimal setup that includes ansible plus a few useful tools. 

If run directly ansible expects to find the inventroy in the ```/ansible``` folder. 

You can include your private keys in the ```/sshkeys``` or the ```/ansible/keys``` folder. All private keys in this folder will be added automatically to the ssh-agent for password free authentication. Note that if your private keys are password protected, you need to enter (all) your key passwords before the container runs.

### Included tools for better handling

* git 
* curl

## Building the container from scratch

```
docker build \
       -t phish108/ansible:latest \
       -t phish108/ansible:${ANSIBLE_VERSION} \
       -t phish108/ansible:${ANSIBLE_VERSION}-20200106 .
```
