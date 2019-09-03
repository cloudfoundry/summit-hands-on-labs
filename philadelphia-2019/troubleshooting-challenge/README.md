# Cloud Foundry Troubleshooting Challenge
## Lab instructions

Welcome to Cloud Foundry troubleshooting challenge!
During this lab, you will try to resolve deployment issues and make applications running.

### How to start the Lab:

- Make sure you're in **summit-hands-on-labs/philadelphia-2019/troubleshooting-challenge** dir, and run preparation script:

	```
	$ ./prepare.sh 
	Preparing Lab environment... Done
	
	Authenticating...
	OK
	
	...
		
	API endpoint:   https://api.phillyhol.starkandwayne.com (API version: 2.133.0)
	User:           training.hol.XX@cloudfoundry.org
	Org:            troubleshooting-challenge
	Space:          training.hol.XX@cloudfoundry.org
	```


- Make sure you logged in, assigned Org is `troubleshooting-challenge` and Space is equal to your username.
	
- You will see 3 directories for **easy**, **moderate** and **tricky** levels of tasks accordingly. We suggest you to start from **easy** level, then move forward to more difficult tasks.

- To run a task, just `cd` into it’s directory, then try to push application. If it does not work - try to find out why.

	```
	$ cd easy/01
	
	$ cf push
	```
- After pushing every application - please open it in the browser to make sure it works.

Good luck!
