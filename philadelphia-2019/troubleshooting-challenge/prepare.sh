#!/bin/bash
set +x
echo -n "Preparing Lab environment... "
for i in `find . -type d`; do
	pushd $i >/dev/null
	find . -maxdepth 1 -name *tgz | xargs -I % tar -xzf %
	popd >/dev/null
done
echo "Done"

ACC=`gcloud config get-value account`
cf login -a api.phillyhol.starkandwayne.com -u $ACC -p $ACC -o troubleshooting-challenge -s $ACC --skip-ssl-validation