require 'opsview_rest/entity'

class OpsviewRest
  class Keyword < Entity

    TYPE = "keyword"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end