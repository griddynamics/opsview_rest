require 'opsview_rest/entity'

class OpsviewRest
  class ServiceGroup < Entity

    TYPE = "servicegroup"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end