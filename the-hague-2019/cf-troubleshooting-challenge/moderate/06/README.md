# Moderate 06
Moderate tasks covers more complicated topics and complex issues,
or demands some deeper  CloudFoundry  knowledge, like routing or
healthchecks.

### Application:
A static javascript web application showing html page.

### Task:
Deploy an app with a manifest.

Notes: This task requires you to have minimum  nodejs  knowlege, 
and to make changes in  application configuration files. Code can be inspected,
but it should work without modifications.  

### ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
- an app can be accessed using an app's route

### Tags
tag_cf_push, tag_manifest, tag_buildpacks, tag_nodejs
