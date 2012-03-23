require 'opsview_rest/entity'

class OpsviewRest
  class HostTemplate < Entity

    TYPE = "hosttemplate"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end