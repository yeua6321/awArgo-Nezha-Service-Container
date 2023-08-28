
# reference: https://git-scm.com/docs/git-config
# https://stackoverflow.com/questions/60187612/how-to-set-git-compression-level
FROM ghcr.io/naiba/nezha-dashboard

# Only one port is exposed
# This line exposes port 80
EXPOSE 9090

WORKDIR /dashboard

# Copy entrypoint.sh script to the /dashboard directory
COPY entrypoint.sh /dashboard/

# Copy the sqlite.db file to the /dashboard/data directory
COPY sqlite.db /dashboard/data/

# Install necessary packages for the image
# Added missing packages iproute2, vim, git, cron, unzip, supervisor, and nginx
RUN apt-get update &&\
    apt-get -y install openssh-server wget iproute2 vim git cron unzip supervisor nginx &&\
    
    # Download and unzip the nezha-agentha application
    # Replaced backticks ` with $(command) syntax for the uname commands
    wget -O nezha-agent.zip https://github.com/naiba/nezha/releases/latest/download/nezha-agent_linux_$(uname -m | sed "s#x86_64#amd64#; s#aarch64#arm64#").zip &&\
    unzip nezha-agent.zip &&\

    # Download and install the cloudflared package
    wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(uname -m | sed "s#x86_64#amd64#; s#aarch64#arm64#").deb &&\
    dpkg -i cloudflared.deb &&\
    
    # Cleanup unnecessary files
    rm -f nezha-agent.zip cloudflared.deb &&\
    
    # Create a file named dbfile
    touch /dbfile &&\
    
    # Set executable permission to entrypoint.sh script
    chmod +x entrypoint.sh 

# Configure Git settings
# Added missing '&&\' before git config
RUN git config --global core.bigFileThreshold 1k && \
    git config --global core.compression 0 && \
    
    # Clean the apt package cache
    apt-get clean && \

    # Remove temporary files and apt lists
    rm -rf /var/lib/apt/lists/*

# Set the entrypoint of the container to entrypoint.sh script
ENTRYPOINT ["./entrypoint.sh"]
