require 'opsview_rest/entity'

class OpsviewRest
  class NotificationMethod < Entity

    TYPE = "notificationmethod"

    def initialize(properties)
      super(TYPE, properties)
    end
  end
end