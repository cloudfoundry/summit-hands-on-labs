# Cloud Foundry Troubleshooting Challenge
## Lab instructions

Welcome to Cloud Foundry troubleshooting challenge!
During this lab, you will try to resolve deployment issues and make applications running.

### How to start the Lab:

- Go to `troubleshooting-challenge` dir, and run preparation script:

	```
	$ cd troubleshooting-challenge
	
	$ ./prepare.sh 
	Preparing Lab environment... Done

	```


- Make sure you logged in, assigned Org is `troubleshooting-challenge` and Space is equal to your username:

	```
	$ cf target
	api endpoint:   https://api.phillyhol.starkandwayne.com
	api version:    2.125.0
	user:           training_hol_XX
	org:            troubleshooting-challenge
	space:          training_hol_XX

	```
		

	
- You will see 3 directories for **Easy**, **Moderate** and **Tricky** levels of tasks accordingly. We suggest you to start from **Easy** level, then move forward to more difficult tasks.
- To run a task, just `cd` into it’s directory, then try to push application. If it does not work - try to find out why.

	```
	$ cd easy/01
	
	$ cf push
	```

Good luck!
