require 'opsview_rest/entity'

class OpsviewRest
  class Keyword < Entity

    TYPE = "keyword"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end