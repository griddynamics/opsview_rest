require 'opsview_rest/entity'

class OpsviewRest
  class HostCheckCommand < Entity

    TYPE = "hostcheckcommand"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end