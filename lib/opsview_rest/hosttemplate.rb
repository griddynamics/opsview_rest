require 'opsview_rest/entity'

class OpsviewRest
  class HostTemplate < Entity

    TYPE = "hosttemplate"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end