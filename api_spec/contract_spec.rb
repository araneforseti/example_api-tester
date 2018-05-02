require_relative 'api_spec_helper.rb'
require 'rack/test'
require 'tester'
require 'tester/definition/methods/api_get'
require 'tester/definition/endpoint'
require 'tester/definition/fields/field'
require 'tester/api_tester'
require 'tester/modules/format'
require 'tester/modules/good_case'
require 'tester/modules/typo'
require 'tester/modules/unused_fields'

include Rack::Test::Methods

describe 'Contract' do
    it 'should follow the contract' do

        get_sheets = ApiGet.new "http://localhost:4567/api/v1/sheets"
        get_sheets.request = Request.new
        get_sheets.expected_response = Response.new(200).add_field(Field.new "sheets")

        endpoint = Endpoint.new "Sheets"
        endpoint.add_method get_sheets

        tester = ApiTester.new(endpoint).with_module(Format.new).with_module(GoodCase.new).with_module(Typo.new).with_module(UnusedFields.new)
        expect(tester.go).to be true
    end
end
