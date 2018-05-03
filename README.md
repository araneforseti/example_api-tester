# Example API Tester

NOTE: The build is supposed to be failing so you can see api-tester's unmodified output. This is a purposefully failing project
[![Build Status](https://travis-ci.org/araneforseti/example_api-tester.svg?branch=master)](https://travis-ci.org/araneforseti/example_api-tester)

Example usage of api-tester (https://github.com/araneforseti/api-tester) using Janky-API (https://github.com/araneforseti/janky-api) as a base. 

Check out api_specs/contract_spec.rb for usage

To run, use:

./scripts/scripts/docker/start_docker.sh

To run tests created with api-tester:

bundle exec rake api
