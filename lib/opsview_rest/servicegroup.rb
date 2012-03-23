require 'opsview_rest/entity'

class OpsviewRest
  class ServiceGroup < Entity

    TYPE = "servicegroup"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end