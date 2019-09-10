# Moderate 03
Moderate tasks covers more complicated topics and complex issues,
or demands some deeper  CloudFoundry  knowledge, like routing or
healthchecks.

### Application:
A static golang web application showing html page. 

### Task:
Deploy an app with a manifest.

### ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
- an app can be accessed using an app's route

### Tags
tag_manifest, tag_environment_variables, tag_cf_push
