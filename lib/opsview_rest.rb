require 'rubygems'
require 'rest-client'
require 'json'

class OpsviewRest

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
    reload_status = get("reload")
    if reload_status["configuration_status"] == "pending"
      post("reload", {})
    end
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
      raise "Id for entity with type '#{type}' and name '#{name}' can't be found'"
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
    details_by_type_and_id(type, get_id_by_type_and_name(type, name))
  end

  # return an entity details by its type and id
  def details_by_type_and_id(type, id)
    delete(resource_path_for_entity_type(type) + "/#{id}")
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
    api_request { @rest[path_part].get(additional_headers, &block) }
  end

  # sends delete request
  def delete(path_part, additional_headers = {}, &block)
    api_request { @rest[path_part].delete(additional_headers, &block) }
  end

  # sends post request
  def post(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].post(payload, additional_headers, &block) }
  end

  # sends put request
  def put(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].put(payload, additional_headers, &block) }
  end

  # sends API request and parses response body
  def api_request(&block)
    response_body = begin
      response = block.call
      response.body
    rescue RestClient::Exception => e
      if e.http_code == 307
        get(e.response)
      end
      e.response
    end

    # is used for logout action that returns empty body
    if response_body.empty?
      response_body = "{}"
    end

    parse_response(JSON.parse(response_body))
  end

  # parses response body
  def parse_response(response)
    # We've got an error if there's "message" and "detail" fields
    # in the response
    if response["message"] and response["detail"]
      raise "Request failed: #{response["message"]}, detail: #{response["detail"]}"
      # If we have a list of objects, return the list:
    elsif response["list"]
      symbolize_keys response["list"]
    elsif response["object"]
      symbolize_keys response["object"]
    else
      symbolize_keys response
    end
  end

  def symbolize_keys arg
    case arg
      when Array
        arg.map { |elem| symbolize_keys elem }
      when Hash
        Hash[
            arg.map { |key, value|
              k = key.is_a?(String) ? key.to_sym : key
              v = symbolize_keys value
              [k,v]
            }]
      else
        arg
    end
  end
end
