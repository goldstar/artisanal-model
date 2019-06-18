module Artisanal::Model
  class Attribute < Module
    attr_reader :name, :type, :options

    def initialize(name, coercer=nil, **options)
      @name, @options = name, options
      @type = coercer || options[:type]

      # Convert :from option to :as
      if options.has_key? :from
        @name, options[:as] = options[:from], name
      end

      # Add default values for certain types
      unless options.has_key?(:default)
        options.merge!(default: type_default)
      end

      raise ArgumentError.new("type missing for attribute #{name}") if type.nil?
    end

    def included(base)
      # Create dry-initializer option
      base.option(name, **options.merge(type: type_builder))

      # Create writer method
      define_writer(base, name) if options[:writer]
    end

    protected

    def class_coercer(type)
      if type.respond_to? :artisanal_model
        ->(value, parent) { value.is_a?(type) ? value : type.new(value, parent) }
      else
        ->(value) { value.is_a?(type) ? value : type.new(value) }
      end
    end

    def define_writer(base, target)
      define_method("#{target}=") do |value|
        coercer = artisanal_model.schema[target].type
        arity = coercer.is_a?(Proc) ? coercer.arity : coercer.method(:call).arity
        args = arity.abs == 1 ? [value] : [value, self]

        coercer.call(*args).tap { |result| instance_variable_set("@#{target}", result) }
      end

      # Scope writer to protected or private
      if [:protected, :private].include? options[:writer]
        base.send(options[:writer], "#{target}=")
      end
    end

    def enumerable_coercer(type)
      coercer = type_builder(type.first)
      arity = coercer.is_a?(Proc) ? coercer.arity : coercer.method(:call).arity

      if arity.abs == 1
        ->(collection) { type.class.new(collection.map { |value| coercer.call(value) }) }
      else
        ->(collection, parent) { type.class.new(collection.map { |value| coercer.call(value, parent) }) }
      end
    end

    def type_builder(type=self.type)
      case type
      when Class
        class_coercer(type)
      when Enumerable
        enumerable_coercer(type)
      else
        type
      end
    end

    def type_default
      case type
      when Array
        -> { Array.new }
      when Set
        -> { Set.new }
      end
    end
  end
end
