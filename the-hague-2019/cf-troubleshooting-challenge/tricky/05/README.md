# Tricky 05
Tricky tasks cover more complicated or complex issues, related to 
application code or understanding CF features and internals.

### Application:
Two python web applications, frontend and backend. Backend gathers some data
about public clouds availability and ruturns some data about backend intself 
instance, all in json format. Frontend gathers this data and show html page. 

### Task:
Deploy apps with a manifest. We expect backend to have no public route 
in this task. Here you need to modify manifest and configure CloudFoundry iself.

### ACCEPTANCE CRITERIAS:
- "cf apps" shows at leat one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
- app URL checked in browser and working

### Tags
tag_manifest tag_python tag_networking tag_routing
