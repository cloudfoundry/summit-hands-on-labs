# Cloud Foundry Troubleshooting Challenge
## Lab instructions

Welcome to Cloud Foundry troubleshooting challenge!
During this lab, you will try to resolve deployment issues and make applications running.

### How to start the Lab:

- Make sure you have CF CLI installed. For that, type `cf` in Terminal window. If command is not found - go ahead and install it:

	```
	$ sudo zypper install cf-cli
	```

- Login to CF with provided credentials:

	```
	$ cf login -a api.cf.mydeploy.xyz
	```

- Make sure your assigned Org is `challenge` and Space is equal to your username:

	```
	$ cf target
	api endpoint:   https://api.cf.mydeploy.xyz
	api version:    2.125.0
	user:           dev01
	org:            challenge
	space:          dev01

	```
		
- Clone this repository, and run preparation script:

- You will see 5 directories for **Basic** **Easy**, **Moderate**, **Tricky** and **doc-app** tasks accordingly. We suggest you to start from **doc-app**. This task will help you to check environment, and have documentation for you labs, were you'll see tasks descriptions and some usefull information. 
- To run a task, just `cd` into it’s directory, then try to push application. Check the docs, some tasks expect you to use some specific way to solve the issues.

	```
	$ cd easy/01
	
	$ cf push
	```

Good luck!
