require 'rubygems'
require 'rspec'
require 'rspec/mocks'
require 'rest-client'
require '../lib/opsview_rest'
require '../lib/opsview_rest/entity'
require '../lib/opsview_rest/host'
require 'net/http'
require 'uri'

# TODO: Rspecs will be added in next commit
describe OpsviewRest do

  URL = "http://10.35.13.37"
  USERNAME = "admin"
  PASSWORD = "initial"

  FIND_PROPERTY_NAME = "id"
  FIND_PROPERTY_VALUE = "1"

  OPTIONS = {
      :name => "Standy_Host",
      :ip      => "192.168.1.1",
      :type    => "host"
  }

  ID_RESPONSE = {
      :id => 1,
      :name => 'test'
  }

  RESPONSE_BODY = "{\"id\" : \"1\", \"name\" : \"test\", \"token\" : \"hello!\"}"

  before do
    #rest = mock(RestClient::Resource)
    #
    #response = RestClient::Response.create(RESPONSE_BODY, "", nil)
    #
    #headers = double("headers")
    #headers.stub(:[]=).and_return([])
    #
    #rest.stub(:post).and_return(response)
    #rest.stub(:put).and_return(response)
    #rest.stub(:delete).and_return(response)
    #rest.stub(:get).and_return(response)
    #rest.stub(:headers).and_return(headers)
    #rest.stub(:[]).and_return(rest)
    #
    #@opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, rest)
  end

  it "should be able to login" do
    #@opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD})

    #options = {
    #    :name => "standy_test20",
    #    :ip      => "192.16.8.1.202",
    #    :check_attempts => "2",
    #    :type => "host",
    #    :description => "hello world!"
    #}
    #p @opsview.create_from_properties(options)
    #
    #@host = OpsviewRest::Host.new(options)
    #@opsview.update(@host)
    #@opsview.find(options)[0]
    #host2 = OpsviewRest::Host.new(@opsview.find(options)[0])
    #host2.properties[:check_attempts]
    #host2
    #@opsview.remove(host2)
    #
    #@opsview.logout
  end

  #it "should be able to login" do
  #
  #end
end