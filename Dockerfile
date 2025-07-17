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