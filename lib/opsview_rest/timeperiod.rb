require 'opsview_rest/entity'

class OpsviewRest
  class Timeperiod < Entity

    TYPE = "timeperiod"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end