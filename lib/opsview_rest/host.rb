require 'opsview_rest/entity'

class OpsviewRest
  class Host < Entity

    TYPE = "host"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end
