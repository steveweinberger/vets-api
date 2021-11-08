- Only copy what's needed before bundle install
  - Not sure what can be done here as each module needs everything within itself to build the gem
- [ ] Document why all system packages are needed in Dockerfile (apt install)
  - [ ] Switch to apt? (Instead of apt-get)
  - [ ] Figure out what needs lib-curl
- [X] Clean up setting ENV vars for REDIS_URL
- Note: You need BUNDLE_ENTERPRISE__CONTRIBSYS__COM set for docker build to work.


## System Packages
git - Needed for bundle installing from git repositoriies
curl - Typheous? Rails wouldn't boot; something about libcurl
file - Needed for Shrine (file command-line tool not found)

## Running Docker Stuff

- To build the docker image, run `docker build --tag vets-api .`.
