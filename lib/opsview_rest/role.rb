require 'opsview_rest/entity'

class OpsviewRest
  class Role < Entity

    TYPE = "role"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end