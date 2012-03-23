require 'opsview_rest/entity'

class OpsviewRest
  class Role < Entity

    TYPE = "role"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end