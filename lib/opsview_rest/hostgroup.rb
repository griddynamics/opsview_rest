require 'opsview_rest/entity'

class OpsviewRest
  class HostGroup < Entity

    TYPE = "hostgroup"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end