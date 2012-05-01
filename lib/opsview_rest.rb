require 'rubygems'
require 'rest-client'
require 'json'
require 'opsview_helper'

#TODO: !WARNING! Only basic manual testing of a new functionality has been done.
#TODO: Rspecs for all functionality should be written.

class OpsviewRest

  RELOAD_TIMEOUT_IN_SEC = 30 # after this time reload operation will be failed with timeout exception
  RELOAD_INTERVAL_IN_SEC = 10 # interval between reloads

  attr_accessor :url, :username, :password, :rest

  def initialize(url, options = {}, rest = nil)
    options = {
      :username => "api",
      :password => "password",
      :connect  => true
    }.update options

    @url      = url
    @username = options[:username]
    @password = options[:password]

    if rest.nil?
      @rest = RestClient::Resource.new("#{@url}/rest/", :headers => {})
    else
      @rest = rest
    end

    login if options[:connect]
  end

  # login action with saving a username and a token into a header for future requests
  def login
    @rest.headers[:content_type] = "application/json"

    response = post("login", { :username => @username, :password => @password })
    @rest.headers[:x_opsview_token]    = response[:token]
    @rest.headers[:x_opsview_username] = @username

    response
  end

  # logout action
  def logout
    # set another Content-Type due to problems with delete request with Content-Type "application/json"
    @rest.headers[:content_type] = "text/x-data-dumper"
    delete("login")
  end

  # returns a reload status
  def reload_status
    get("reload")
  end

  # reloads opsview only when at least one configuration change requires a reload
  def reload
    start_time = Time.now.to_i

    begin
      status = reload_status

      if status[:server_status] == "0" # opsview is not in reloading status
        if status[:configuration_status] == "pending" # reload is required
          result = post("reload", {})
          if result.has_key?(:configuration_status) # reload has been finished, there is no concurrent reloads
            if result[:server_status] == "0" # server status is running with no warnings after reload
              return result
            elsif result[:server_status] != "1"
              raise "Reload has been done with server status code #{result[:server_status]}"
            end
          end
        else
          return status
        end
      end

      sleep RELOAD_INTERVAL_IN_SEC

    end while Time.now.to_i - start_time <= RELOAD_TIMEOUT_IN_SEC

    raise "Reload has been failed by timeout (#{RELOAD_TIMEOUT_IN_SEC} seconds)"
  end

  # creates an entity based on its properties
  def create_from_properties(properties = {})
    check_property_value(properties, :type)

    require 'opsview_rest/entity'
    entity = OpsviewRest::Entity.new(properties[:type], properties)
    create(entity)
  end

  # creates an entity using a post request
  def create(entity)
    post(resource_path_for_entity(entity), entity.to_json)
  end

  # if an entity with such name and type exists - updates the entity using a put request
  # if an entity doesn't exist - creates a new entity using a post request
  def update(entity)
    entity_id = get_id(entity);
    if entity_id.nil?
      create(entity)
    else
      put(resource_path_for_entity(entity) + "/#{entity_id}", entity.to_json)
    end
  end

  # removes a specified entity using its type and name
  def remove(entity)
    remove_by_type_and_name(entity.properties[:type], entity.properties[:name])
  end

  # removes an entity with a specified type and name
  def remove_by_type_and_name(type, name)
    entity_id = get_id_by_type_and_name(type, name)
    if entity_id.nil?
      raise "Id for entity with type '#{type}' and name '#{name}' can't be found"
    else
      remove_by_type_and_id(type, entity_id)
    end
  end

  # removes an entity with a specified type and id
  def remove_by_type_and_id(type, id)
    delete(resource_path_for_entity_type(type) + "/#{id}")
  end

  # lists entities of a specified type
  def list(type)
    get(resource_path_for_entity_type(type))
  end

  # returns an entity details using its type and name
  def details(entity)
    details_by_type_and_name(entity.properties[:type], entity.properties[:name])
  end

  # returns an entity details by its type and name
  def details_by_type_and_name(type, name)
    entity_id = get_id_by_type_and_name(type, name)
    if entity_id.nil?
      raise "Id for entity with type '#{type}' and name '#{name}' can't be found"
    else
      details_by_type_and_id(type, entity_id)
    end
  end

  # return an entity details by its type and id
  def details_by_type_and_id(type, id)
    get(resource_path_for_entity_type(type) + "/#{id}")
  end

  # searches entities that have specified properties
  def find(properties)
    if properties.nil? or properties.empty?
      raise "Properties should be specified"
    end

    check_property_value(properties, :type)

    url = "config/#{properties[:type]}?"

    properties.each do |property_name, property_value|
      url << "s.#{property_name}=#{property_value}&"
    end

    get(URI.escape(url), :rows => :all)
  end

  # returns an entity id
  def get_id(entity)
    check_property_value(entity.properties, :type)
    check_property_value(entity.properties, :name)

    get_id_by_type_and_name(entity.properties[:type], entity.properties[:name])
  end

  # return an entity id based on its type and name
  def get_id_by_type_and_name(type, name)
    check_property(type)
    check_property(name)

    result = find({:type => type, :name => name})
    if result.empty?
      nil
    else
      result[0][:id]
    end
  end

  # returns resource path for a specified entity
  def resource_path_for_entity(entity)
    check_property_value(entity.properties, :type)
    resource_path_for_entity_type(entity.properties[:type])
  end

  # returns resource path for a specified entity
  def resource_path_for_entity_type(type)
    check_property(type)
    "config/#{type}"
  end

  private

  # checks that property is not nil and empty
  def check_property(property)
    if property.nil? or property.empty?
      raise "Entity property '#{property_name}' should be specified"
    end
  end

  # checks that property by specified symbol key is not nil and empty
  def check_property_value(properties, property_name)
    if properties[property_name].nil? or properties[property_name].empty?
      raise "Entity property with symbol key '#{property_name}' should be specified"
    end
  end

  # sends get request
  def get(path_part, additional_headers = {}, &block)
    begin
      api_request { @rest[path_part].get(additional_headers, &block) }
    rescue RestClient::Exception => e
      if e.http_code == 401
        login
        api_request { @rest[path_part].get(additional_headers, &block) }
      end
    end
  end

  # sends delete request
  def delete(path_part, additional_headers = {}, &block)
    begin
      api_request { @rest[path_part].delete(additional_headers, &block) }
    rescue RestClient::Exception => e
      if e.http_code == 401
        login
        api_request { @rest[path_part].delete(additional_headers, &block) }
      end
    end
  end

  # sends post request
  def post(path_part, payload, additional_headers = {}, &block)
    begin
      api_request { @rest[path_part].post(payload, additional_headers, &block) }
    rescue RestClient::Exception => e
      if e.http_code == 401
        login
        api_request { @rest[path_part].post(payload, additional_headers, &block) }
      end
    end
  end

  # sends put request
  def put(path_part, payload, additional_headers = {}, &block)
    begin
      api_request { @rest[path_part].put(payload, additional_headers, &block) }
    rescue RestClient::Exception => e
      if e.http_code == 401
        login
        api_request { @rest[path_part].put(payload, additional_headers, &block) }
      end
    end
  end

  # sends API request and parses response body
  def api_request(&block)
    response = begin
      block.call([])
    rescue RestClient::Exception => e
      if e.http_code == 401 # raise exception in case of token expiration
        raise e
      else
        e.response
      end
    end

    parse_and_format_response response
  end

  # parses and format response body, handles errors
  def parse_and_format_response(response)
    response_body = response.body

    # is used for logout action that returns empty body
    if response_body.empty?
      response_body = "{}"
    end

    body_hash = OpsviewHelper.symbolize_keys(JSON.parse(response_body))

    if response.code == 200 || response.code == 409 # 409 - reload already in progress
      if body_hash.has_key? :list
        body_hash[:list]
      elsif body_hash.has_key? :object
        body_hash[:object]
      else
        body_hash
      end
    else
      error_message = "Request failed (code = #{response.code}):"

      if body_hash.has_key? :message
        error_message << " #{body_hash[:message]}"
        if body_hash.has_key? :detail
          error_message << ", details: #{body_hash[:detail]}"
        end
      elsif body_hash.has_key? :messages
        body_hash[:messages].each { |message| error_message << " details: #{message[:detail]}" }
      else
        error_message << " unknown reason"
      end

      raise error_message
    end
  end
end
