#!/bin/bash -e

# Setup orgs and spaces
for name in "rock" "techno" "jazz" "blues" "hiphop" "country" "pop" "soul" "rnb" "afrobeat" "balkan" "house"
do
cf create-org $name
cf create-space -o $name dev
cf create-space -o $name prod

# Setup users and roles
cf create-user $name password

cf set-space-role $name $name dev SpaceDeveloper
cf set-space-role $name $name prod SpaceDeveloper

# Print all users
cf org-users $name -a
cf space-users $name dev
cf space-users $name prod
done
