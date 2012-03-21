require 'opsview_rest/entity'

class OpsviewRest
  class Attribute < Entity

    TYPE = "attribute"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end
