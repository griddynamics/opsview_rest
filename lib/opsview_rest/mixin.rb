class OpsviewRest
  module Mixin

    def resource_path(full=false)
      if (full == true || full == :full)
        "/rest/config/#{self.class.name.split('::').last.downcase}"
      else
        "config/#{self.class.name.split('::').last.downcase}"
      end
    end

    def list
      self.opsview.get(resource_path)
    end

    def save(replace=false)
      if replace == true || replace == :replace
        self.opsview.put(self.resource_path, self)
      else
        self.opsview.post(self.resource_path, self)
      end
    end

    def to_json
      self.options.to_json
    end

  end
end
