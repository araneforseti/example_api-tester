require_relative 'api_spec_helper.rb'
require 'rack/test'
require 'tester'
require 'tester/definition/endpoint'
require 'tester/definition/api_contract'
require 'tester/definition/request'
require 'tester/definition/response'
require 'tester/definition/fields/field'
require 'tester/definition/fields/object_field'
require 'tester/definition/fields/array_field'
require 'tester/definition/fields/number_field'
require 'tester/api_tester'
require 'tester/modules/format'
require 'tester/modules/good_case'
require 'tester/modules/typo'
require 'tester/modules/unused_fields'

include Rack::Test::Methods

describe 'Contract' do
  let(:base_url) { "http://localhost:4567/api/v1" }

  it 'match contract' do
    contract = ApiContract.new "Janky API"

    sheets_endpoint = Endpoint.new "Sheets", "#{base_url}/sheets"
    post_request = Request.new.add_field(Field.new "id")
        .add_field(Field.new "name")
        .add_field(NumberField.new "strength")
        .add_field(NumberField.new "dexterity")
        .add_field(NumberField.new "constitution")
        .add_field(NumberField.new "will")
        .add_field(NumberField.new "intelligence")
        .add_field(NumberField.new "charisma")
    expected_response = Response.new(200)
        .add_field(Field.new "name")
        .add_field(NumberField.new "strength")
        .add_field(NumberField.new "dexterity")
        .add_field(NumberField.new "constitution")
        .add_field(NumberField.new "will")
        .add_field(NumberField.new "intelligence")
        .add_field(NumberField.new "charisma")
    sheets_endpoint.add_method :get, expected_response
    sheets_endpoint.add_method :post, expected_response, post_request
    sheets_endpoint.test_helper = SheetCreator.new base_url
    contract.add_endpoint sheets_endpoint

    sheet_endpoint = Endpoint.new "Sheets", "#{base_url}/sheets/{testSheet}"
    sheet_endpoint.add_path_param "testSheet"
    sheet_endpoint.test_helper = SheetCreator.new base_url
    sheet_field = ObjectField.new("sheet").with_field(Field.new "id", "testSheet")
        .with_field(Field.new "name")
        .with_field(NumberField.new "strength")
        .with_field(NumberField.new "dexterity")
        .with_field(NumberField.new "constitution")
        .with_field(NumberField.new "will")
        .with_field(NumberField.new "intelligence")
        .with_field(NumberField.new "charisma")
        .with_field(ArrayField.new "skills")
    expected_response = Response.new(200).add_field(sheet_field)
    sheet_endpoint.add_method SupportedVerbs::GET, expected_response
    sheet_endpoint.add_method SupportedVerbs::POST, expected_response, post_request

    tester = ApiTester.new(contract).with_module(Format.new).with_module(GoodCase.new).with_module(Typo.new).with_module(UnusedFields.new)
    expect(tester.go).to be false
  end
end

class SheetCreator < ApiTester::TestHelper
  attr_accessor :url
  attr_accessor :sheet_info

  def initialize url
    self.url = url
    self.sheet_info = {}
  end

  def before
    good_post = {
      "name" => "testSheet",
      "strength" => 10,
      "dexterity" => 10,
      "constitution" => 10,
      "will" => 10,
      "intelligence" => 10,
      "charisma" => 10
    }
    response = RestClient.post "#{self.url}/sheets", good_post.to_json
    sheet_info["testSheet"] = JSON.parse(response.body)["name"]
  end

  def retrieve_param key
    sheet_info[key]
  end

  def after
    @redis = Redis.new
    keys = @redis.keys('*')
    keys.each{ |key| @redis.del(key) }
  end
end
