FROM debian:latest
MAINTAINER "DJ Adams"
SHELL ["/bin/bash", "-c"]

# This is the user ID of my user on the Docker host - adjust to suit
ARG UID=1031

# This is a container user so I'm not working as root
ARG USERNAME=user

# The current latest version of various programs
ARG TMUXVER=3.2a
ARG YQVER=4.12.1
ARG NODEVER=lts
ARG GITUIVER=0.17
ARG BATVER=0.18.3
ARG GLOWVER=1.4.1
ARG SHFMTVER=3.3.1

RUN apt-get update \
  && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    vim \
    jq \
    ncat \
    entr \
    wget \
    curl \
    gnupg \
    pass \
    man \
    bash-completion \
    lsb-release \
    openssh-server \
    shellcheck \
    file \
    build-essential \
    sudo \
    fzf \
    uuid-runtime \
    cron \
    pandoc \
    newsboat \
    lynx \
    w3m \
  && curl -fsSL https://download.docker.com/linux/debian/gpg \
     | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y docker-ce-cli

# Install latest bat
RUN cd /tmp/ \
  && wget "https://github.com/sharkdp/bat/releases/download/v$BATVER/bat-musl_${BATVER}_amd64.deb" \
  && dpkg -i "./bat-musl_${BATVER}_amd64.deb"

# Install latest gh
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update \
  && apt-get install -y gh

# Install latest yq
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQVER}/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# Install latest tmux
RUN apt-get install -y \
  ncurses-dev libevent-dev \
  && cd /tmp/ \
  && wget https://github.com/tmux/tmux/releases/download/$TMUXVER/tmux-$TMUXVER.tar.gz \
  && tar xzf tmux-$TMUXVER.tar.gz \
  && cd tmux-$TMUXVER \
  && ./configure && make && make install

# Install specific Node.js
RUN curl -fsSL "https://deb.nodesource.com/setup_$NODEVER.x" | bash - \
  && apt-get install -y nodejs

# Install global npm modules
RUN npm install -g \
  @sap/cds-dk \
  @sap/generator-fiori \
  @sapui5/generator-sapui5-templates \
  @ui5/cli \
  fx \
  docsify-cli \
  bash-language-server \
  eslint \
  http-server \
  httpie \
  jwt-cli \
  lorem-ipsum \
  prettier \
  lodash \
  ramda \
  url-decode-encode-cli \
  yarn \
  yo

# Install cf CLI (v7)
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
  && echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && apt-get update \
  && apt-get install -y cf7-cli

# Install latest kubectl
RUN curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/bin/kubectl

RUN adduser \
  --uid $UID \
  --quiet \
  --disabled-password \
  --shell /bin/bash \
  --home /home/$USERNAME \
  --gecos "Dev User" \
  $USERNAME


# Install fff and then ensure that bin/ and share/ are user-owned
RUN cd /tmp \
  && git clone https://github.com/dylanaraps/fff \
  && cd fff \
  && PREFIX=/home/$USERNAME make install \
  && chown -R $USERNAME:$USERNAME /home/$USERNAME/bin /home/$USERNAME/share \
  && rm -rf /tmp/fff

# Install gitui
RUN cd /tmp \
  && wget "https://github.com/extrawurst/gitui/releases/download/v$GITUIVER/gitui-linux-musl.tar.gz" \
  && tar -x -z -C /usr/bin/ -f "./gitui-linux-musl.tar.gz"

# Install glow
RUN cd /tmp \
  && wget "https://github.com/charmbracelet/glow/releases/download/v${GLOWVER}/glow_${GLOWVER}_linux_amd64.deb" \
  && dpkg -i "./glow_${GLOWVER}_linux_amd64.deb"

# Install shfmt
RUN curl -L -o /usr/bin/shfmt "https://github.com/mvdan/sh/releases/download/v${SHFMTVER}/shfmt_v${SHFMTVER}_linux_amd64" \
  && chmod +x /usr/bin/shfmt

# Install steampipe
RUN /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Change ownership of /tmp
RUN chown $USERNAME:$USERNAME /tmp/

USER $USERNAME
WORKDIR /home/$USERNAME
ENV TERM xterm-256color

# Set up dotfiles
RUN git clone https://github.com/qmacro/dotfiles.git .dotfiles \
  && cd .dotfiles \
  && ./dotsetup \
  && git remote set-url origin git@github.com:qmacro/dotfiles.git

# Install vim plugins
RUN vim +'PlugInstall --sync' +qa > /dev/null 2>&1

# Install btp CLI
RUN cd /tmp/ \
  && curl \
  --remote-name \
  --location \
  --url "https://raw.githubusercontent.com/SAP-samples/sap-tech-bytes/2021-09-01-btp-cli/getbtpcli" \
  && chmod +x getbtpcli \
  && echo -ne '\n' | ./getbtpcli

# Set focus reminder
RUN echo "What are you focusing on?" | tee $HOME/.status > $HOME/.focus

# Off we go - based on tmux, the terminal multiplexer
CMD ["tmux", "-u", "new", "-s", "main"]
