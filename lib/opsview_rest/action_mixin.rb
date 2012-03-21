class OpsviewRest
  module ActionMixin

    def create()
      self.opsview.post(self.resource_path, self)
    end

    def update()
      self.opsview.put(self.resource_path + "/#{get_id()}", self)
    end

    def delete()
      self.opsview.delete(self.resource_path + "/#{get_id()}")
    end

    def list()
      self.opsview.get(self.resource_path)
    end

    def details()
      self.opsview.get(self.resource_path + "/#{get_id()}")
    end

    def to_json
      self.options.to_json
    end

    def find(property_name, property_value)
      unless property_name && property_value
        raise "Property name and value should be specified."
      else
        self.opsview.get("config/#{self.options[:type]}?s.#{property_name}=#{property_value}", :rows => :all)
      end
    end

    def get_id()
      if self.options[:name].nil? or self.options[:name].empty?
        raise ("Entity name should be specified")
      else
        result = find("name", self.options[:name])
        if not result.empty?
          return result[0]["id"]
        else
          raise "Id for entity '#{options[:type]}' with name '#{options[:name]}' was not found."
        end
      end
    end

    def resource_path()
      "config/#{self.options[:type]}"
    end
  end
end
