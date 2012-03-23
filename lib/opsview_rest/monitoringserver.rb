require 'opsview_rest/entity'

class OpsviewRest
  class MonitoringServer < Entity

    TYPE = "monitoringserver"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end


