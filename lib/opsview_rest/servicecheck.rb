require 'opsview_rest/entity'

class OpsviewRest
  class ServiceCheck < Entity

    TYPE = "servicecheck"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end