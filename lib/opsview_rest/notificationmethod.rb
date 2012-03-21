require 'opsview_rest/entity'

class OpsviewRest
  class NotificationMethod < Entity

    TYPE = "notificationmethod"

    def initialize(opsview, options)
      super(TYPE, opsview, options)
    end
  end
end