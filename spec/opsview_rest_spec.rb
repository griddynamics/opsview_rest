require 'rubygems'
require 'rspec'
require 'rspec/mocks'
require 'rest-client'

require File.expand_path('../../lib/opsview_rest', __FILE__)
require File.expand_path('../../lib/opsview_rest/entity', __FILE__)
require File.expand_path('../../lib/opsview_rest/host', __FILE__)
require 'net/http'

#TODO: update old tests, create new tests for new functionality
describe OpsviewRest do

  URL = "http://10.35.13.52"
  USERNAME = "admin"
  PASSWORD = "initial"

  PROPERTIES = {
      :name => "Standy_Host",
      :ip      => "192.168.1.1",
      :type    => "host"
  }

  PROPERTIES_WITHOUT_TYPE = {
      :name => "Standy_Host",
      :ip      => "192.168.1.1",
  }

  RESPONSE_BODY = "{\"id\" : \"1\", \"name\" : \"test\", \"token\" : \"hello!\"}"
  RESPONSE_HASH = {:id => "1", :name => "test", :token => "hello!"}

  NEED_RELOAD_RESPONSE_HASH = {:configuration_status => "pending"}
  NEED_RELOAD_RESPONSE_BODY = "{\"configuration_status\" : \"pending\"}"

  NO_RELOAD_RESPONSE_HASH = {:configuration_status => "uptodate"}
  NO_RELOAD_RESPONSE_BODY = "{\"configuration_status\" : \"uptodate\"}"

  FIND_RESPONSE_BODY = "{\"list\" : {\"id\" : \"1\", \"name\" : \"test\", \"token\" : \"hello!\"}}"
  FIND_RESPONSE_HASH = [{:id => "1", :name => "test", :token => "hello!"}]

  EMPTY_RESPONSE_BODY = "{}"
  EMPTY_RESPONSE_HASH = {}

  before do
    @rest = mock(RestClient::Resource)

    response = create_response(RESPONSE_BODY, 200)

    headers = double("headers")
    headers.stub(:[]=).and_return([])

    @rest.stub(:post).and_return(response)
    @rest.stub(:put).and_return(response)
    @rest.stub(:delete).and_return(response)
    @rest.stub(:get).and_return(response)
    @rest.stub(:headers).and_return(headers)
    @rest.stub(:[]).and_return(@rest)

    @opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)
  end

  it "should be able to login" do
    @opsview.login.should eq RESPONSE_HASH
  end

  it "should be able to logout" do
    @opsview.logout.should eq RESPONSE_HASH
  end

  # TODO: Will be fixed and uncommented later
  #it "should be able to reload when configuration status is pending" do
  #  response2 = create_response(NEED_RELOAD_RESPONSE_BODY, 200)
  #
  #  @rest.stub(:get).and_return(response2)
  #  @rest.stub(:post).and_return(response)
  #
  #
  #  opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)
  #
  #  opsview.reload.should eq RESPONSE_HASH
  #end

  #it "should not reload when configuration status is uptodate" do
  #  @response2 = RestClient::Response.create(NO_RELOAD_RESPONSE_BODY, "", nil)
  #  @rest.stub(:get).and_return(@response2)
  #  @rest.stub(:post).and_return(@response)
  #
  #  opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)
  #
  #  opsview.reload.should eq nil
  #end

  it "should be able to create entity from properties" do
    @opsview.create_from_properties(PROPERTIES).should eq RESPONSE_HASH
  end

  it "should raise exception if properties do not contain type" do
    expect{@opsview.create_from_properties(PROPERTIES_WITHOUT_TYPE)}.to raise_error(RuntimeError)
  end

  it "should be able to create entity" do
    host = OpsviewRest::Host.new(PROPERTIES)
    @opsview.create(host).should eq RESPONSE_HASH
  end

  it "should be able to create entity if it doesn't exist'" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    host = OpsviewRest::Host.new(PROPERTIES)
    opsview.update(host).should eq RESPONSE_HASH
  end

  it "should be able to list entity" do
    @opsview.list("host").should eq RESPONSE_HASH
  end

  it "should be able to find entity" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.find(PROPERTIES).should eq EMPTY_RESPONSE_HASH
  end

  # Can be used for testing concurrent update and reload operations. Will be deleted later.
  #it "test reload" do
  #  options = {
  #      :name => "test",
  #      :ip => "192.168.1.1",
  #      :check_attempts => "2",
  #      :type => "host",
  #      :description => "hello world!"
  #  }
  #
  #  i = 0
  #
  #  while i < 10
  #    p i
  #    options[:description] = i
  #    conn = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD})
  #    host = OpsviewRest::Entity.new("host", options)
  #    conn.update(host)
  #
  #    conn.reload
  #    i += 1
  #    random = rand(10)
  #    p "sleeping #{random}"
  #    sleep random
  #  end
  #end

  def create_response(response_body, response_code)
    response = mock(RestClient::Response)
    response.stub(:body).and_return(response_body)
    response.stub(:code).and_return(response_code)
    response
  end
end