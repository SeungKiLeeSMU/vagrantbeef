#!/usr/bin/bash

#install nvm
curl -o- \
    https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | \
    bash

# load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#setup nvm to use the LTS version
nvm install --lts

npm install -g @angular/cli

npm install -g pm2
