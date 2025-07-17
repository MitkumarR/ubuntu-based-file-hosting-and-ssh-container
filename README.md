# Ubuntu-based File Hosting and SSH Container

I have built custom docker image. It's based on Ubuntu 22.04 running Apache and SSH. It is allowing file hosting and remote shell access using openSSH.

### Features
- Based on Ubuntu 22.04
- Customized docker image
- File hosting. For now we can access defualt apache html page
- Remote shell access

### Getting started
Here, you have to follow some task to implement it.

**1. Install docker engine on host OS**

Docker Engine is the core software that lets you build and run containers. We need to install it so we can create and run Docker images and containers.

You can write bash script of all listed commands. 

Preparation:

Update the local list of available packages and package versions.
```bash
sudo apt update -y 
```

Install essential packages required for secure communication, downloading files, managing GPG keys, and identifying the Ubuntu release.
```bash
sudo apt install ca-certificates curl gnupg lsb-release -y
```

Create the directory for storing trusted APT keyring files, setting proper permissions.
```bash
sudo mkdir -m 0755 -p /etc/apt/keyrings
```

Download Docker’s official GPG key and converts it for safe storage in the APT keyrings directory.
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Add the Docker APT repository to your system’s package sources, specifying architecture and signed GPG key for security.
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine, CLI, container runtime, Buildx builder, and Compose plugin on your system.
```bash
# Install Docker Engine
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

> Note: Networking (If you are using VirtualBox)
>
> Make sure your Parrot OS VM network adapter is set to "Bridged Adapter" or "NAT with Port Forwarding", so you can access ports from your host (Windows) if needed.


**2. Add your user to docker group**

By default, Docker needs ```sudo```. Adding your user to the docker group lets you run Docker without sudo.

```bash
sudo usermod -aG docker $USER
echo '[!] You need to log out and log back in for the group changes to take effect.'
```

**3. Test Docker Installation**
```bash
docker run hello-world
```
If this runs without error, Docker works.


**4. Create project dockerfile**

Create a new directory for your project.

```bash
Copy code
mkdir ~/docker_apache_ssh
cd ~/docker_apache_ssh
```
Create a file named Dockerfile.

```bash
nano Dockerfil
```
Paste this content:
```bash
# Use the latest Ubuntu 22.04 LTS as base
FROM ubuntu:22.04

# Update package repo and install Apache and SSH
RUN apt-get update && \
    apt-get install -y apache2 openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Create user "docker-user" and set password
RUN useradd -m docker-user && \
    echo "docker-user:password" | chpasswd

# Give permissions
RUN chown -R docker-user:docker-user /var/www/html && \
    # chown -R docker-user:docker-user /var/run/apache2 && \
    # chown -R docker-user:docker-user /var/log/apache2 && \
    # chown -R docker-user:docker-user /var/lock/apache2 && \
    usermod -aG sudo docker-user && \
    echo "docker-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Expose SSH and HTTP ports
EXPOSE 22 80

# Start services
CMD service ssh start && /usr/sbin/apache2ctl -D FOREGROUND
```

```ctrl+c``` and ```ctrl+v```? No, Right?\
Let's understand :)
What we aredoing with this dockerfile. And what dockerfile will do?

A ```Dockerfile``` defines steps to create your custom image — like installing Apache and SSH, creating users, setting permissions, and exposing ports. This file makes your container reproducible.

In dockerfile,\
It starts your image from the official Ubuntu 22.04 Long Term Support base image, ensuring a stable, widely-supported OS environment. 

```apt-get update```: Updates the list of available packages.

```apt-get install -y apache2 openssh-server```: Installs Apache web server and OpenSSH server (for HTTP and SSH access) in isolated container.

```rm -rf /var/lib/apt/lists/*```: Cleans up cached package information to reduce final image size.

It declare that the container will listen on port 22 (SSH) and port 80 (HTTP), so they can be mapped to the host.

It will run commands when the container starts.

**5. Build docker image**

Now turn your dockerfile into ans image. And you can tun it.

```bash
docker build -t fs_docker .
```

Finally Run your docker container, check and access.

If there is no error or unwanted till now, then our container is successfully ready.


### Usage

A container is an instance of your image. You run it and map ports so you can access SSH and HTTP services.

```bash
docker run -p 8022:22 -p 8080:80 -d fs_docker
```

check running container
```bash
docker ps
```
This command will print table which contains all information about container.

Access SSH
```bash
ssh docker-user@localhost -p 8022
```
you can access your linux instance which is now isloated in docker container (successfully) from your host OS.
Password is which set in dockerfile.

Access Apache

In browser: http://localhost:8080


if you are using VM and want access from windows or actual host machine(for example windows), then http://vm-ip:8080 . Replace vm-ip with your VM's IP address.

### Customization

You can make another user and then add in docker group instead of ```$USER``` ($USER will add current user on your host system)


in dockerfile
```bash
RUN useradd -m docker-user && \
    echo "docker-user:password" | chpasswd
```

You can keep your password.

> Here, $USER is your host system user\
> docker-user = $USER which added in docker group
> And now user of container(linux instance) is docker-user.

### File structure

/Dockerfile : Base container 


