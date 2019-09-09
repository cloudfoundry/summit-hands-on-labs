# Cloud Foundry Troubleshooting Challenge
## Lab instructions

Welcome to Cloud Foundry troubleshooting challenge!
During this lab, you will try to resolve deployment issues and make applications running.

### How to work with this Lab:

- Login to the Google Cloud Console using the provided credentials and activate the Cloud Shell.

- Login to CF using the  provided credentials:

	```
	$ cf login -a api.hol.starkandwayne.com --skip-ssl-validation
	
	```

- Make sure your assigned Org is `training.hol.your_user_number` and Space is `training`:

	```
	$ cf target

	```
		
- Clone this repository and go to the  folder of this lab:

	```
	$ git clone https://github.com/cloudfoundry/summit-hands-on-labs.git
	$ cd summit-hands-on-labs/the-hague-2019/cf-troubleshooting-challenge/

	```
- Run a preparation script:

	```
	$ ./prepare.sh

	```

- There are 5 directories for **Basic**, **Easy**, **Moderate**, **Tricky** and **doc-app** tasks accordingly. We suggest you to start from **doc-app**. This task will help you check environment and have documentation for you labs, where you'll see tasks descriptions and some usefull information. 

- To run a task follow the instruction below:

	```
	Choose a level of tasks you would like to try, for example `basic`
 
	$ cd basic/

	Go to the first folder and read the task instruction
	
	$ cd basic/01
	$ teachme README.md
	
	Try to push an app

	$ cf push
	
	```


Good luck and enjoy!!!
