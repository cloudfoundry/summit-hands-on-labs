#!/bin/bash -e
# Script to clean up resources from the Multi-Service Registration Lab

# Target prod space in each org
for name in "rock" "techno" "jazz" "blues" "hiphop" "country" "pop" "soul" "rnb" "afrobeat" "balkan" "house"
do

cf target -o $name -s prod


# Delete each service instance in the prod space
    for service in $(cf services | grep -v name | grep -v Getting | grep -v -e "^$" | awk '{print $1}')
    do
        cf delete-service -f "$service"
    done

# Delete each org
cf delete-org -f $name
done

# TODO Delete users?

# Delete the overview-broker from the marketplace
cf delete-service-broker overview-broker -f
