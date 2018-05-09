require_relative 'api_spec_helper.rb'
require 'rack/test'
require 'tester'
require 'tester/definition/methods/api_get'
require 'tester/definition/methods/api_post'
require 'tester/definition/endpoint'
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

    context 'Sheets' do
        it 'match contract' do
            get_sheets = ApiGet.new
            get_sheets.request = Request.new
            get_sheets.expected_response = Response.new(200).add_field(ObjectField.new("sheets")
                .with_field(Field.new "id")
                .with_field(Field.new "name")
                .with_field(NumberField.new "strength")
                .with_field(NumberField.new "dexterity")
                .with_field(NumberField.new "constitution")
                .with_field(NumberField.new "will")
                .with_field(NumberField.new "intelligence")
                .with_field(NumberField.new "charisma"))
    
            post_sheets = ApiPost.new
            post_sheets.request = Request.new.add_field(Field.new "id")
                .add_field(Field.new "name")
                .add_field(NumberField.new "strength")
                .add_field(NumberField.new "dexterity")
                .add_field(NumberField.new "constitution")
                .add_field(NumberField.new "will")
                .add_field(NumberField.new "intelligence")
                .add_field(NumberField.new "charisma")
            post_sheets.expected_response = Response.new(200)
                .add_field(Field.new "name")
                .add_field(NumberField.new "strength")
                .add_field(NumberField.new "dexterity")
                .add_field(NumberField.new "constitution")
                .add_field(NumberField.new "will")
                .add_field(NumberField.new "intelligence")
                .add_field(NumberField.new "charisma")

            endpoint = Endpoint.new "Sheets", "#{base_url}/sheets"
            endpoint.add_method get_sheets
            endpoint.add_method post_sheets
            endpoint.test_helper = SheetCreator.new base_url

            tester = ApiTester.new(endpoint).with_module(Format.new).with_module(GoodCase.new).with_module(Typo.new).with_module(UnusedFields.new)
            # Janky-API is built to fail
            expect(tester.go).to be false
        end
    end

    context 'Sheet' do
        it 'follows contract' do
            get_sheets = ApiGet.new 
            get_sheets.request = Request.new
            sheet_field = ObjectField.new("sheet").with_field(Field.new "id", "testSheet")
                .with_field(Field.new "name")
                .with_field(NumberField.new "strength")
                .with_field(NumberField.new "dexterity")
                .with_field(NumberField.new "constitution")
                .with_field(NumberField.new "will")
                .with_field(NumberField.new "intelligence")
                .with_field(NumberField.new "charisma")
                .with_field(ArrayField.new "skills")
            get_sheets.expected_response = Response.new(200).add_field(sheet_field)

            endpoint = Endpoint.new "Sheets", "#{base_url}/sheets/testSheet"
            endpoint.add_method get_sheets
            endpoint.test_helper = SheetCreator.new base_url

            tester = ApiTester.new(endpoint).with_module(Format.new).with_module(GoodCase.new).with_module(Typo.new).with_module(UnusedFields.new)
            # Janky-API is built to fail
            expect(tester.go).to be false
        end
    end
end

class SheetCreator < ApiTester::TestHelper
  attr_accessor :url

  def initialize url
    self.url = url
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
  end

  def after
    @redis = Redis.new
    keys = @redis.keys('*')
    keys.each{ |key| @redis.del(key) }
  end
end
