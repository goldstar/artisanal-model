module Artisanal
  require_relative "model/builder"
  require_relative 'model/config'
  require_relative "model/version"

  def self.Model(**opts)
    Model::Builder.new(**opts)
  end

  module Model
    def self.included(base)
      base.include Artisanal::Model()
    end
  end
end
