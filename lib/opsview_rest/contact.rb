require 'opsview_rest/entity'

class OpsviewRest
  class Contact < Entity

    TYPE = "contact"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end