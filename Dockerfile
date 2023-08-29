# reference: https://git-scm.com/docs/git-config
# https://stackoverflow.com/questions/60187612/how-to-set-git-compression-level
FROM ghcr.io/naiba/nezha-dashboard

EXPOSE 80

WORKDIR /app/dashboard

COPY entrypoint.sh /app/dashboard/

COPY sqlite.db /app/dashboard/data/

RUN apt-get update &&\
    apt-get -y install openssh-server wget iproute2 vim git cron unzip supervisor systemctl nginx &&\
    wget -O nezha-agent.zip https://github.com/naiba/nezha/releases/latest/download/nezha-agent_linux_$(uname -m | sed "s#x86_64#amd64#; s#aarch64#arm64#").zip &&\
    unzip nezha-agent.zip &&\
    wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(uname -m | sed "s#x86_64#amd64#; s#aarch64#arm64#").deb &&\
    dpkg -i cloudflared.deb &&\
    rm -f nezha-agent.zip cloudflared.deb &&\
    touch /dbfile &&\
    chmod +x entrypoint.sh 

RUN git config --global core.bigFileThreshold 1k && \
    git config --global core.compression 0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


ENTRYPOINT ["./entrypoint.sh"]
