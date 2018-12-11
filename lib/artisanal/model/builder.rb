require 'dry-initializer'

module Artisanal::Model
  require_relative 'dsl'

  class Builder < Module
    attr_reader :config

    def initialize(options={})
      @config = Config.new(options)
    end

    def included(base)
      base.extend Dry::Initializer[undefined: config.undefined?]
      base.extend Artisanal::Model::DSL

      # Make attributes mutable
      define_writers if config.writable?

      # Store artisanal model config
      base.artisanal_model.config = config
    end

    protected

    def define_writers
      # Add writers to all attributes
      config.defaults[:writer] = true unless config.defaults.has_key? :writer

      # Define mass-assignment method
      define_method(:assign_attributes) do |attrs|
        attrs = artisanal_model.symbolize(attrs)

        (attrs.keys & artisanal_model.schema.keys).each do |key|
          public_send("#{key}=", attrs[key]) if respond_to? "#{key}="
        end
      end
    end
  end
end
