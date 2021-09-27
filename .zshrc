export CATALINA_HOME=$HOME/development/tomcat/9.0.46
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
export RABBITMQ_HOME=/usr/local/Cellar/rabbitmq/3.8.9_1
export GOROOT=$HOME/go_1.16.2
export PATH=$PATH:$JAVA_HOME/bin:$RABBITMQ_HOME/sbin:$GOROOT/bin:$HOME/go/bin

alias doppelganger=~/development/platform-services/doppelgangercli/build/install/doppelganger/bin/doppelganger
alias gittyup="zsh ~/development/scripts/gittyup.sh ~/development"
alias gocom="cd ~/development/common-git"
alias godev="cd ~/development"
alias goplat="cd ~/development/platform-services"
alias ll="ls -la"
alias tstart="$CATALINA_HOME/bin/startup.sh"
alias tstop="$CATALINA_HOME/bin/shutdown.sh"
alias rstart="rabbitmq-server"
alias rstop="rabbitmqctl shutdown"
alias r1start="RABBITMQ_NODE_PORT=5672 RABBITMQ_SERVER_START_ARGS=\"-rabbitmq_management listener [{port,15672}]\" RABBITMQ_NODENAME=rabbit1 rabbitmq-server"
alias r1stop="rabbitmqctl -n rabbit1 shutdown --no-wait"
alias r2start="RABBITMQ_NODE_PORT=5673 RABBITMQ_SERVER_START_ARGS=\"-rabbitmq_management listener [{port,15673}]\" RABBITMQ_NODENAME=rabbit2 rabbitmq-server"
alias r2stop="rabbitmqctl -n rabbit2 shutdown --no-wait"
alias r3start="RABBITMQ_NODE_PORT=5674 RABBITMQ_SERVER_START_ARGS=\"-rabbitmq_management listener [{port,15674}]\" RABBITMQ_NODENAME=rabbit3 rabbitmq-server"
alias r3stop="rabbitmqctl -n rabbit3 shutdown --no-wait"
alias rctl="rabbitmqctl"
alias scsqs="jps | grep \"CSQService\" | cut -d \" \" -f 1 | xargs -I{} kill {}"
alias gettag="~/development/scripts/gettag.sh ~/development/2021/th2021"
alias tag="git fetch ; git tag --sort=committerdate | tail -1"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
