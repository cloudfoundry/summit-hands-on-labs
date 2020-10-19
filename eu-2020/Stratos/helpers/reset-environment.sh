#!/usr/bin/env bash

RED="\033[91m"
RESET="\033[0m"

# The following will reset your Google Cloud Shell by REMOVING YOUR HOME DIRECTORY
# It follows the link below, with a fix
# - https://cloud.google.com/shell/docs/resetting-cloud-shell
#sudo rm -rf $HOME
#mkdir $HOME
#sudo chown $USER:users $HOME
# Restart the shell environment by closing the current window and clicking on the session link again

cd ~/
rm -rf cloudshell_open/*
rm -rf .kube
rm -rf .config/helm

echo -e "$RED You must now close this tab and access the shell again via the original link ${RESET}"
