require_relative 'api_spec_helper.rb'
require 'rack/test'
require 'api-tester'
require 'api-tester/test_helper'
require 'api-tester/definition/endpoint'
require 'api-tester/config'
require 'api-tester/definition/contract'
require 'api-tester/definition/request'
require 'api-tester/definition/response'
require 'api-tester/definition/fields/field'
require 'api-tester/definition/fields/object_field'
require 'api-tester/definition/fields/array_field'
require 'api-tester/definition/fields/number_field'
require 'api-tester/modules/format'
require 'api-tester/modules/good_case'
require 'api-tester/modules/typo'
require 'api-tester/modules/unused_fields'
require 'api-tester/modules/extra_verbs'

include Rack::Test::Methods

describe 'Contract' do
  let(:base_url) { "http://localhost:4567/api/v1" }

  it 'match contract' do
    contract = ApiTester::Contract.new "Janky API"

    sheets_endpoint = ApiTester::Endpoint.new "Sheets", "#{base_url}/sheets"
    post_request = ApiTester::Request.new.add_field(ApiTester::Field.new name: "id")
        .add_field(ApiTester::Field.new name: "name")
        .add_field(ApiTester::NumberField.new name: "strength")
        .add_field(ApiTester::NumberField.new name: "dexterity")
        .add_field(ApiTester::NumberField.new name: "constitution")
        .add_field(ApiTester::NumberField.new name: "will")
        .add_field(ApiTester::NumberField.new name: "intelligence")
        .add_field(ApiTester::NumberField.new name: "charisma")
    expected_response = ApiTester::Response.new(200)
        .add_field(ApiTester::Field.new name: "name")
        .add_field(ApiTester::NumberField.new name: "strength")
        .add_field(ApiTester::NumberField.new name: "dexterity")
        .add_field(ApiTester::NumberField.new name: "constitution")
        .add_field(ApiTester::NumberField.new name: "will")
        .add_field(ApiTester::NumberField.new name: "intelligence")
        .add_field(ApiTester::NumberField.new name: "charisma")
    sheets_endpoint.add_method :get, expected_response
    sheets_endpoint.add_method :post, expected_response, post_request
    sheets_endpoint.test_helper = SheetCreator.new base_url
    contract.add_endpoint sheets_endpoint

    sheet_endpoint = ApiTester::Endpoint.new "Sheets", "#{base_url}/sheets/{testSheet}"
    sheet_endpoint.add_path_param "testSheet"
    sheet_endpoint.test_helper = SheetCreator.new base_url
    sheet_field = ApiTester::ObjectField.new(name: "sheet").with_field(ApiTester::Field.new name: "id", default_value: "testSheet")
        .with_field(ApiTester::Field.new name: "name")
        .with_field(ApiTester::NumberField.new name: "strength")
        .with_field(ApiTester::NumberField.new name: "dexterity")
        .with_field(ApiTester::NumberField.new name: "constitution")
        .with_field(ApiTester::NumberField.new name: "will")
        .with_field(ApiTester::NumberField.new name: "intelligence")
        .with_field(ApiTester::NumberField.new name: "charisma")
        .with_field(ApiTester::ArrayField.new name: "skills")
    expected_response = ApiTester::Response.new(200).add_field(sheet_field)
    sheet_endpoint.add_method ApiTester::SupportedVerbs::GET, expected_response
    sheet_endpoint.add_method ApiTester::SupportedVerbs::POST, expected_response, post_request

    config = ApiTester::Config.new
      .with_module(ApiTester::Format)
      .with_module(ApiTester::ExtraVerbs)
      .with_module(ApiTester::GoodCase)
      .with_module(ApiTester::Typo)
      .with_module(ApiTester::UnusedFields)
    expect(ApiTester.go(contract, config)).to be false
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
