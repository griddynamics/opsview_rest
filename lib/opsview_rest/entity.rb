class OpsviewRest
  class Entity
    attr_accessor :properties

    def initialize(type, properties = {})
      if type.nil? or type.empty?
        raise "Entity type should be specified."
      else
        properties[:type] = type
      end
      @properties = properties
    end

    def to_json
      properties.to_json
    end
  end
end
