require 'opsview_rest/action_mixin'

class OpsviewRest
  class Entity

    include OpsviewRest::ActionMixin

    attr_accessor :options, :opsview

    def initialize(type, opsview, options = {})
      if type.nil? or type.empty?
        raise "Entity type should be specified."
      else
        options[:type] = type
      end
      @options = options
      @opsview = opsview
    end
  end
end
