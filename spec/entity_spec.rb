require 'rubygems'
require 'rspec'
require 'rspec/mocks'
require '../lib/opsview_rest'
require '../lib/opsview_rest/entity'
require '../lib/opsview_rest/action_mixin'

describe OpsviewRest::Entity do

  URL = "http://localhost"
  USERNAME = "test"
  PASSWORD = "test"

  FIND_PROPERTY_NAME = "id"
  FIND_PROPERTY_VALUE = "1"

  OPTIONS = {
      :name => "test",
      :ip      => "192.168.1.1",
      :type    => "host"
  }

  ID_RESPONSE = {
      :id => 1,
      :name => 'test'
  }

  RESPONSE = "TEST"

  before do
    @opsview = mock(OpsviewRest)

    @opsview.stub(:post).and_return(RESPONSE)
    @opsview.stub(:put).and_return(RESPONSE)
    @opsview.stub(:delete).and_return(RESPONSE)
    @opsview.stub(:get).and_return([ID_RESPONSE])
  end

  it "should be able to create entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.create()
  end

  it "should be able to update entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.update()
  end

  it "should be able to details entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.details()
  end

  it "should be able to delete entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.delete()
  end

  it "should be able to list entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.list()
  end

  it "should be able to find entity" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    @host.find(FIND_PROPERTY_NAME, FIND_PROPERTY_VALUE)
  end

  # negative

  it "should be able to raise error when property name and value are nil" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    expect{@host.find(nil, nil)}.to raise_error(RuntimeError)
  end

  it "should be able to raise error when property value is nil" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    expect{@host.find("test", nil)}.to raise_error(RuntimeError)
  end

  it "should be able to raise error when property name is nil" do
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    expect{@host.find(nil, "test")}.to raise_error(RuntimeError)
  end

  it "should be able to raise error when entity name is nil" do
    OPTIONS[:name] = nil
    @host = OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)
    expect{@host.get_id()}.to raise_error(RuntimeError)
  end

  it "should be able to raise error when entity type is empty" do
    OPTIONS[:type] = ""
    expect{OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)}.to raise_error(RuntimeError)
  end

  it "should be able to raise error when entity type is nil" do
    OPTIONS[:type] = nil
    expect{OpsviewRest::Entity.new(OPTIONS[:type], @opsview, OPTIONS)}.to raise_error(RuntimeError)
  end
end