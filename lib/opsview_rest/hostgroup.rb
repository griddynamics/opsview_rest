require 'opsview_rest/entity'

class OpsviewRest
  class HostGroup < Entity

    TYPE = "hostgroup"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end