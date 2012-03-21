require 'rubygems'
require 'rest-client'
require 'json'

class OpsviewRest

  attr_accessor :url, :username, :password, :rest

  def initialize(url, options = {}, rest = nil)
    options = {
      :username => "api",
      :password => "changeme",
      :connect  => true
    }.update options

    @url      = url
    @username = options[:username]
    @password = options[:password]

    if rest.nil?
      @rest = RestClient::Resource.new("#{@url}/rest/", :headers => { :content_type => 'application/json' })
    else
      @rest = rest
    end

    login if options[:connect]
  end

  def login
    response = post('login', { 'username' => @username, 'password' => @password })
    @rest.headers[:x_opsview_token]    = response['token']
    @rest.headers[:x_opsview_username] = @username
    response
  end

  def logout
    delete('login')
  end

  def reload
    get("reload")
  end

  def create(options = {})
    if options[:type].nil? and options[:type].empty?
      raise "Type is empty"
    end

    require 'opsview_rest/entity'
    entity = OpsviewRest::Entity.new(options[:type], self, options)
    entity.create
  end

  def get(path_part, additional_headers = {}, &block)
    api_request { @rest[path_part].get(additional_headers, &block) }
  end

  def delete(path_part, additional_headers = {}, &block)
    api_request { @rest[path_part].delete(additional_headers, &block) }
  end

  def post(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].post(payload.to_json, additional_headers, &block) }
  end

  def put(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].put(payload.to_json, additional_headers, &block) }
  end

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

    parse_response(JSON.parse(response_body))
  end

  def parse_response(response)
    # We've got an error if there's "message" and "detail" fields
    # in the response
    if response["message"] and response["detail"]
      raise "Request failed: #{response["message"]}, detail: #{response["detail"]}"
    # If we have a token, return that:
    elsif response["token"]
      response
    # If we have a list of objects, return the list:
    elsif response["list"]
      response["list"]
    else
      response["object"]
    end
  end
end
