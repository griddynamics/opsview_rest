require 'rubygems'
require 'rspec'
require 'rspec/mocks'
require 'rest-client'

require File.expand_path('../../lib/opsview_rest', __FILE__)
require File.expand_path('../../lib/opsview_rest/entity', __FILE__)
require File.expand_path('../../lib/opsview_rest/host', __FILE__)
require 'net/http'

describe "OpsView functionality" do

  URL = "http://10.35.13.52"
  USERNAME = "admin"
  PASSWORD = "initial"

  PROPERTIES = {
      :name => "Standy_Host",
      :ip => "192.168.1.1",
      :type => "host"
  }

  PROPERTIES_WITHOUT_TYPE = {
      :name => "Standy_Host",
      :ip => "192.168.1.1",
  }

  PROPERTIES_WITHOUT_NAME = {
      :type => "host",
      :ip => "192.168.1.1",
  }

  RESPONSE_BODY = "{\"id\" : \"1\", \"name\" : \"test\", \"token\" : \"hello!\"}"
  RESPONSE_HASH = {:id => "1", :name => "test", :token => "hello!"}

  NEED_RELOAD_RESPONSE_HASH = {:configuration_status => "pending"}
  NEED_RELOAD_RESPONSE_BODY = "{\"configuration_status\" : \"pending\"}"

  NO_RELOAD_RESPONSE_HASH = {:configuration_status => "uptodate"}
  NO_RELOAD_RESPONSE_BODY = "{\"configuration_status\" : \"uptodate\"}"

  FIND_RESPONSE_BODY = "{\"list\" : [{\"id\" : \"1\", \"name\" : \"test\", \"token\" : \"hello!\"}]}"
  FIND_RESPONSE_HASH = [{:id => "1", :name => "test", :token => "hello!"}]

  EMPTY_RESPONSE_BODY = "{}"
  EMPTY_RESPONSE_HASH = {}

  RELOAD_COMPLETED_NO_ERR_HASH = {:configuration_status => "uptodate", :server_status => "0"}
  RELOAD_COMPLETED_NO_ERR_BODY = "{\"configuration_status\" : \"uptodate\", \"server_status\" : \"0\"}"

  RELOAD_COMPLETED_WITH_ERR_BODY = "{\"configuration_status\" : \"uptodate\", \"server_status\" : \"3\"}"

  RELOAD_COMPLETED_WITH_1_HASH = {:configuration_status => "uptodate", :server_status => "1"}
  RELOAD_COMPLETED_WITH_1_BODY = "{\"configuration_status\" : \"uptodate\", \"server_status\" : \"1\"}"

  RELOAD_IN_PROGRESS_STATUS_BODY = "{\"server_status\" : \"1\"}"

  RELOAD_IN_PROGRESS_RELOAD_BODY = "{\"status\" : \"1\"}"

  default_host = OpsviewRest::Host.new(PROPERTIES)

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

  it "should be able to get reload status" do
    @opsview.reload_status.should eq RESPONSE_HASH
  end

  it "should be able to reload when configuration status is pending" do
    @rest.stub(:get).and_return(create_response(NEED_RELOAD_RESPONSE_BODY, 200))
    @rest.stub(:post).and_return(create_response(RELOAD_COMPLETED_NO_ERR_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.reload.should eq RELOAD_COMPLETED_NO_ERR_HASH
  end

  it "should not raise exception after reload when server status == 1" do
    @rest.stub(:get).and_return(create_response(NEED_RELOAD_RESPONSE_BODY, 200))
    @rest.stub(:post).and_return(create_response(RELOAD_COMPLETED_WITH_1_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.reload.should eq RELOAD_COMPLETED_WITH_1_HASH
  end

  it "should raise exception after reload when server status != 0 or != 1" do
    @rest.stub(:get).and_return(create_response(NEED_RELOAD_RESPONSE_BODY, 200))
    @rest.stub(:post).and_return(create_response(RELOAD_COMPLETED_WITH_ERR_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect { opsview.reload }.to raise_error(RuntimeError, "Reload has been done with server status code 3")
  end

  it "should raise exception by timeout when reload can't be started" do
    @rest.stub(:get).and_return(create_response(RELOAD_IN_PROGRESS_STATUS_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.reload
    }.to raise_error(RuntimeError, "Reload has been failed by timeout (#{OpsviewRest::RELOAD_TIMEOUT_IN_SEC} seconds)")
  end

  it "should raise exception by timeout when reload can't be finished" do
    @rest.stub(:get).and_return(create_response(NEED_RELOAD_RESPONSE_BODY, 200))
    @rest.stub(:post).and_return(create_response(RELOAD_IN_PROGRESS_RELOAD_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.reload
    }.to raise_error(RuntimeError, "Reload has been failed by timeout (#{OpsviewRest::RELOAD_TIMEOUT_IN_SEC} seconds)")
  end

  it "should not reload when configuration status is uptodate" do
    @rest.stub(:get).and_return(create_response(NO_RELOAD_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.reload.should eq NO_RELOAD_RESPONSE_HASH
  end

  it "should be able to create entity from properties" do
    @opsview.create_from_properties(PROPERTIES).should eq RESPONSE_HASH
  end

  it "should raise exception if properties do not contain type (method: create_from_properties)" do
    expect {
      @opsview.create_from_properties(PROPERTIES_WITHOUT_TYPE)
    }.to raise_error(RuntimeError, "Entity property with symbol key 'type' should be specified")
  end

  it "should be able to create entity" do
    @opsview.create(default_host).should eq RESPONSE_HASH
  end

  it "should be able to create entity if it doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.update(default_host).should eq RESPONSE_HASH
  end

  it "should be able to update entity if it exists" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))
    @rest.stub(:put).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.update(default_host).should eq EMPTY_RESPONSE_HASH
  end

  it "should be able to remove existing entity" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))
    @rest.stub(:delete).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.remove(default_host).should eq EMPTY_RESPONSE_HASH
  end

  it "should raise exception when entity for remove doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.remove(default_host)
    }.to raise_error(RuntimeError,
                     "Id for entity with type '#{PROPERTIES[:type]}' and name '#{PROPERTIES[:name]}' can't be found")
  end

  it "should be able to remove existing entity by type and name" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))
    @rest.stub(:delete).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.remove_by_type_and_name(PROPERTIES[:type], PROPERTIES[:name]).should eq EMPTY_RESPONSE_HASH
  end

  it "should raise exception when entity with specified type and name doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.remove_by_type_and_name(PROPERTIES[:type], PROPERTIES[:name])
    }.to raise_error(RuntimeError,
                     "Id for entity with type '#{PROPERTIES[:type]}' and name '#{PROPERTIES[:name]}' can't be found")
  end

  it "should be able to remove entity by type and id" do
    @opsview.remove_by_type_and_id("host", "1").should eq RESPONSE_HASH
  end

  it "should be able to get entity details" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.details(default_host).should eq FIND_RESPONSE_HASH
  end

  it "should raise exception when entity for getting details doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.details(default_host)
    }.to raise_error(RuntimeError,
                     "Id for entity with type '#{PROPERTIES[:type]}' and name '#{PROPERTIES[:name]}' can't be found")
  end

  it "should be able to get entity details by type and name" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.details_by_type_and_name(PROPERTIES[:type], PROPERTIES[:name]).should eq FIND_RESPONSE_HASH
  end

  it "should raise exception when entity details with specified type and name doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    expect {
      opsview.details_by_type_and_name(PROPERTIES[:type], PROPERTIES[:name])
    }.to raise_error(RuntimeError,
                     "Id for entity with type '#{PROPERTIES[:type]}' and name '#{PROPERTIES[:name]}' can't be found")
  end

  it "should be able to get entity details by type and id" do
    @opsview.details_by_type_and_id("host", "1").should eq RESPONSE_HASH
  end

  it "should be able to list entity" do
    @opsview.list("host").should eq RESPONSE_HASH
  end

  it "should be able to find entity" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.find(PROPERTIES).should eq FIND_RESPONSE_HASH
  end

  it "should raise exception when properties for find method are nil" do
    expect {
      @opsview.find(nil)
    }.to raise_error(RuntimeError, "Properties should be specified")
  end

  it "should raise exception when properties for find method are empty" do
    expect {
      @opsview.find({})
    }.to raise_error(RuntimeError, "Properties should be specified")
  end

  it "should raise exception if properties do not contain name (method: get_id)" do
    expect {
      @opsview.get_id(OpsviewRest::Host.new(PROPERTIES_WITHOUT_NAME))
    }.to raise_error(RuntimeError, "Entity property with symbol key 'name' should be specified")
  end

  it "should be able to return entity id" do
    @rest.stub(:get).and_return(create_response(FIND_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.get_id(default_host).should eq "1"
  end

  it "should return nil when entity with such id doesn't exist" do
    @rest.stub(:get).and_return(create_response(EMPTY_RESPONSE_BODY, 200))

    opsview = OpsviewRest.new(URL, {:username => USERNAME, :password => PASSWORD}, @rest)

    opsview.get_id(default_host).should eq nil
  end

  it "should return resource path for entity" do
    @opsview.resource_path_for_entity(default_host).should eq "config/" + default_host.properties[:type]
  end

  it "should return resource path for entity type" do
    @opsview.resource_path_for_entity_type("type").should eq "config/type"
  end

  it "should be able to relogin after token expiration"

  it "should be able to handle exceptions"

  it "should be able to parse and format response"

  def create_response(response_body, response_code)
    response = mock(RestClient::Response)
    response.stub(:body).and_return(response_body)
    response.stub(:code).and_return(response_code)
    response
  end
end