module Artisanal::Model
  class Config
    attr_reader :options, :defaults, :writable, :undefined

    alias_method :writable?, :writable
    alias_method :undefined?, :undefined

    def initialize(options={})
      @options = options
      @defaults = { optional: true }.merge(options.fetch(:defaults, {}))
      @writable = options.fetch(:writable, false)
      @undefined = options.fetch(:undefined, false)
    end
  end
end
