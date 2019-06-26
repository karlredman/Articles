#!/usr/bin/env sh

# reference:  [[SOLVED] Can i use plugins/git to clone another repo? - General Discussion - Drone](https://discourse.drone.io/t/solved-can-i-use-plugins-git-to-clone-another-repo/1553/6?u=karlredman)
# reference: [Secret in Drone 1.0.0-rc.1 · Issue #130 · appleboy/drone-ssh](https://github.com/appleboy/drone-ssh/issues/130)

# Configures ssh key based on information from secrets

# only execute the script when github token exists.
[ -z "$SSH_KEY" ] && echo "missing ssh key" && exit 3

# write the ssh key.
mkdir /root/.ssh
echo -n "$SSH_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

# add github.com to our known hosts.
touch /root/.ssh/known_hosts
chmod 600 /root/.ssh/known_hosts
ssh-keyscan -H $SSH_HOST > /etc/ssh/ssh_known_hosts 2> /dev/null

if [ $# -gt 0 ]; then
    # get submodules checkout
    git submodule update --init --recursive
else:
    # git commit gh-pages
    git config --global user.email "$${USER_EMAIL}"
    git config --global user.name "$${USER_NAME}"
    MSG=$(git log --pretty=oneline --abrev-commit -1)
    cd site
    git add -A
    git commit -am "drone build from master: ${MSG}"
    git push origin HEAD:gh-pages
fi
