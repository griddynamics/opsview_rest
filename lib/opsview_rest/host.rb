require 'opsview_rest/entity'

class OpsviewRest
  class Host < Entity

    TYPE = "host"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end
