# Example API Tester

[![Build Status](https://travis-ci.org/araneforseti/example_api-tester.svg?branch=master)](https://travis-ci.org/araneforseti/example_api-tester)

Example usage of api-tester (https://github.com/araneforseti/api-tester) using Janky-API (https://github.com/araneforseti/janky-api) as a base. 
 
Check the travis build for example output of api-tester using the builtin reporter

Check out api_specs/contract_spec.rb for usage

To run, use:

./scripts/scripts/docker/start_docker.sh

To run tests created with api-tester:

bundle exec rake api
