require 'opsview_rest/entity'

class OpsviewRest
  class MonitoringServer < Entity

    TYPE = "monitoringserver"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end


