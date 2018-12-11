Bundler.require(:benchmarks)

class PlainRubyTest
  attr_reader :foo, :bar

  def initialize(foo: "FOO", bar: "BAR")
    @foo = foo
    @bar = bar
    raise TypeError unless String === @foo
    raise TypeError unless String === @bar
  end
end

require "dry-initializer"
class DryTest
  extend Dry::Initializer[undefined: false]

  option :foo, proc(&:to_s), default: -> { "FOO" }
  option :bar, proc(&:to_s), default: -> { "BAR" }
  option :baz_old, proc(&:to_s), default: -> { "BAZ" }, as: :baz
end

require "artisanal-model"
class ArtisanalTest
  include Artisanal::Model

  attribute :foo, proc(&:to_s), default: -> { "FOO" }
  attribute :bar, proc(&:to_s), default: -> { "BAR" }
  attribute :baz, proc(&:to_s), default: -> { "BAR" }, from: :baz_old
end

require "artisanal-model"
class ArtisanalTestWithWriters
  include Artisanal::Model(writable: true)

  attribute :foo, proc(&:to_s), default: -> { "FOO" }
  attribute :bar, proc(&:to_s), default: -> { "BAR" }
  attribute :baz, proc(&:to_s), default: -> { "BAR" }, from: :baz_old
end

require "hashie"
class HashieTest < Hashie::Trash
  include Hashie::Extensions::Dash::Coercion
  include Hashie::Extensions::IndifferentAccess
  include Hashie::Extensions::MethodAccess

  property :foo, coerce: proc(&:to_s), default: "FOO"
  property :bar, coerce: proc(&:to_s), default: "BAR"
  property :baz, coerce: proc(&:to_s), default: "BAR", from: :baz_old
end

require "virtus"
class VirtusTest
  include Virtus.model

  attribute :foo, String, default: "FOO"
  attribute :bar, String, default: "BAR"
  attribute :baz_old, String, default: "BAR"

  alias_method :baz, :baz_old
end

puts "Benchmark for example models with virtus and hashie"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("plain Ruby") do
    PlainRubyTest.new
  end

  x.report("dry-initializer") do
    DryTest.new
  end

  x.report("artisanal-model") do
    ArtisanalTest.new
  end

  x.report("artisanal-model (WITH WRITERS)") do
    ArtisanalTestWithWriters.new
  end

  x.report("hashie") do
    HashieTest.new
  end

  x.report("virtus") do
    VirtusTest.new
  end

  x.compare!
end
