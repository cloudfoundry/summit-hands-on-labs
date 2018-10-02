# Number of students in the class
N = 10
# Org for hosting student spaces
org = azalesov
# Space to host app for route challenge

# Before running this script configure cf CLI
# and target CF API as OrgManager

prepare:
	@echo "Create environment for troubleshooting challenge lab"
	for s in {1..$N}; \
	do \
		echo "Creating user account for user $$s.."; \
		cf create-user student-$$s a1tor0s; \
		echo "Creating a space for user $$s.."; \
		cf create-space student-$$s -o $org; \
		echo "Grant permissions to user $$s.."; \
		cf set-space-role student-$$s $org student-$$s SpaceDeveloper; \
	done
	@echo "Push application"
	cd student/app
	cf target -o $org -s $space
	cf push

clean:
	@echo "Delete environment for troubleshooting challenge lab"
	for s in {1..$N}; \
	do \
		echo "Delete user account for user $$s.."; \
		cf delete-user student-$$s -f; \
		echo "Delete a space for user $$s.."; \
		cf delete-space student-$$s -o $org; \
	done
	@echo "Delete application"
	cf target -o $org -s $space
	cf delete bazel -f