Questions for Chris
- Ask about chromebook setup, how will they be presented to attendees at the start of the lab?
- Will the summit-hands-on-lab repo be pre-checkout?
- Will we know the user names of the Chromebooks ahead of time?
- We are going need a CF that has enough memory (3072MB minumum)

CF Setup requirements:
- Create users
- Create orgs , same as the user name
- 1 org per user
- dev space and prod space in each org
- attendee user login has spacedeveloper role in each space in their org

The plan:
- Each attendee has SpaceDeveloper role in 2 spaces, dev and prod
- Deploy the broker to the dev space.
- The can register a space scoped broker in dev space and see the services it offers
- Target the prod space
- See there are no services in the markeplace
- They register the service broker in prod and see an error, service broker with that name is taken
- They register the service broker using a different name in prod, and see the services it offers.
- Create a service instance in prod, by specifying a broker name
