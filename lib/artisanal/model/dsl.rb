module Artisanal::Model
  require_relative 'initializer'
  require_relative 'model'

  module DSL
    def self.extended(base)
      base.prepend Initializer
      base.include InstanceMethods
    end

    def inherited(subclass)
      subclass.include Artisanal::Model(artisanal_model.config.options)
    end

    def artisanal_model
      @artisanal_model ||= Model.new(self)
    end

    def schema
      artisanal_model.schema
    end

    def attribute(*args)
      artisanal_model.attribute(*args)
    end

    module InstanceMethods
      def artisanal_model
        self.class.artisanal_model
      end

      def attributes(*args)
        artisanal_model.attributes(self, *args)
      end

      def to_h(*args)
        artisanal_model.to_h(self, *args)
      end
    end
  end
end

