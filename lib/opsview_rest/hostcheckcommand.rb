require 'opsview_rest/entity'

class OpsviewRest
  class HostCheckCommand < Entity

    TYPE = "hostcheckcommand"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end