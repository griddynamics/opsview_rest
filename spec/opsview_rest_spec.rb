require 'rubygems'
require 'rspec'
require 'rspec/mocks'
require 'rest-client'
require '../lib/opsview_rest'
require '../lib/opsview_rest/entity'
require '../lib/opsview_rest/host'
require '../lib/opsview_rest/action_mixin'
require 'net/http'


describe OpsviewRest do

  #URL = "http://10.35.13.37"
  #USERNAME = "admin"
  #PASSWORD = "initial"
  #
  #FIND_PROPERTY_NAME = "id"
  #FIND_PROPERTY_VALUE = "1"
  #
  #OPTIONS = {
  #    :name => "test",
  #    :ip      => "192.168.1.1",
  #    :type    => :host
  #}
  #
  #ID_RESPONSE = {
  #    :id => 1,
  #    :name => 'test'
  #}
  #
  #RESPONSE = "{'id' : 1}"

  before do
    #@rest = mock(RestClient::Resource)

    #response = Net::HTTPResponse.new("HTTP1.1", 200, RESPONSE)

    #@rest.stub(:post).and_return(response)
    #@rest.stub(:put).and_return(RESPONSE)
    #@rest.stub(:delete).and_return(RESPONSE)
    #@rest.stub(:get).and_return([ID_RESPONSE])
    #@rest.stub(:headers).and_return({})
    #@rest.should_receive(:headers).and_return({})
    #@rest.stub(:[]).and_return(@rest)

    #@opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    #@host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
  end

  it "should be able to login" do

  end

  it "should be able to logout" do

  end

  it "should be able to reload" do

  end
end