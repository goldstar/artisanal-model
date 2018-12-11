module Artisanal::Model
  module Initializer
    def initialize(attributes={})
      super(artisanal_model.symbolize(attributes))
    end
  end
end
