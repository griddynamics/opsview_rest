require 'opsview_rest/entity'

class OpsviewRest
  class Attribute < Entity

    TYPE = "attribute"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end
