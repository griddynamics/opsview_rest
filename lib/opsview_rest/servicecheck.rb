require 'opsview_rest/entity'

class OpsviewRest
  class ServiceCheck < Entity

    TYPE = "servicecheck"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end