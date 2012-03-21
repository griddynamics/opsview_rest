require 'opsview_rest/entity'

class OpsviewRest
  class Timeperiod < Entity

    TYPE = "timeperiod"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end