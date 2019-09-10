# Moderate 07
Moderate tasks covers more complicated topics and complex issues,
or demands some deeper  CloudFoundry  knowledge, like routing or
healthchecks.

### Application:
Two python web applications, frontend and backend. Backend gathers some data
about public clouds availability and ruturns some data about backend intself 
instance, all in json format. Frontend gathers this data and show html page. 

### Task:
Deploy apps with a manifest. We expect frontend to connect to backend and get
proper information. Here you need to modify manifest and configure CloudFoundry iself.

### ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
- app URL checked in browser and working

### Tags
tag_manifest tag_python tag_networking tag_routing
