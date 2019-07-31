require 'forwardable'

module Artisanal::Model
  require_relative 'attribute'

  class Model
    extend Forwardable

    attr_reader :klass
    attr_accessor :config

    delegate [:dry_initializer] => :klass
    delegate [:definitions, :null] => :dry_initializer

    alias_method :schema, :definitions

    def initialize(klass)
      @klass = klass
    end

    def attribute(name, type=nil, **opts)
      klass.include Attribute.new(name, type, **config.defaults.merge(opts))
    end

    def attributes(instance, scope: :public, include_undefined: false)
      schema.values.each_with_object({}) do |item, attrs|
        next unless attribute_in_scope?(instance, item.target, scope)
        next unless include_undefined || attribute_defined?(instance, item.target)

        attrs[item.target] = instance.send(item.target)
      end
    end

    def config
      @config ||= Config.new
    end

    def symbolize(attributes={})
      attributes = attributes.to_h

      return attributes unless config.symbolize?

      attributes.dup.tap do |attrs|
        (attribute_names & attrs.keys).each do |key|
          attrs[key.intern] = attrs.delete(key)
        end
      end
    end

    def to_h(instance, *args)
      attributes(instance, *args).each_with_object({}) do |(key, value), result|
        if value.is_a? Enumerable
          result[key] = value.map { |v| v.respond_to?(:to_h) ? v.to_h(*args) : v }
        elsif !value.nil? && value.respond_to?(:to_h)
          result[key] = value.to_h(*args)
        else
          result[key] = value
        end
      end
    end

    protected

    def attribute_defined?(instance, name)
      instance.instance_variable_get("@#{name}") != Dry::Initializer::UNDEFINED
    end

    def attribute_in_scope?(instance, name, scope)
      scope = Array(scope)

      (instance.respond_to?(name, true) && scope.include?(:all)) ||
        (scope.include?(:public) && instance.public_methods.include?(name)) ||
        (scope.include?(:protected) && instance.protected_methods.include?(name)) ||
        (scope.include?(:private) && instance.private_methods.include?(name))
    end

    def attribute_names
      @attribute_names ||= schema.keys.map(&:to_s)
    end

    def method_missing(method, *args)
      if dry_initializer.respond_to?(method)
        dry_initializer.send(method, *args)
      else
        super
      end
    end
  end
end
