module Artisanal::Model
  class Config
    attr_reader :options, :defaults, :writable, :undefined, :symbolize

    alias_method :writable?, :writable
    alias_method :undefined?, :undefined
    alias_method :symbolize?, :symbolize

    def initialize(options={})
      @options = options
      @defaults = { optional: true }.merge(options.fetch(:defaults, {}))
      @writable = options.fetch(:writable, false)
      @undefined = options.fetch(:undefined, false)
      @symbolize = options.fetch(:symbolize, false)
    end
  end
end
