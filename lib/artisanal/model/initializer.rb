module Artisanal::Model
  module Initializer
    def initialize(attributes={}, parent=nil)
      super(artisanal_model.symbolize(attributes))
    end
  end
end
