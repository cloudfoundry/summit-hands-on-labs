echo "Logging you in to Sap Cloud Platform..."
account=$(gcloud config get-value account)
space=${account: 7:2 }
pass="${account: 0:7 }CFNAS19!"  
echo "pas: $pass space: $space acc: $account"
cf login -a https://api.cf.us10.hana.ondemand.com/ -u d.imdonchev@gmail.com -o mta -p ${pass} -s handson
cf create-space -o mta "${space}"
cf t -o mta -s "${space}"

echo "login was successful!"
