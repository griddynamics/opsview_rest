require 'opsview_rest/entity'

class OpsviewRest
  class Contact < Entity

    TYPE = "contact"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end