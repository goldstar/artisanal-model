# artisanal-model

Artisanal::Model is a light-weight attribute modeling DSL that wraps [dry-initializer](https://dry-rb.org/gems/dry-initializer/), providing extra configuration and a slightly cleaner DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artisanal-model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artisanal-model
    
## Configuration

Artisanal::Model configuration is done on a per-model basis. There is no global configuration (at this time):

```ruby
class Model
  include Artisanal::Model(writable: true)
end
```

The configuration will be carried down to subclasses automatically. However, and subclass can override any settings with the `configure` method:

```ruby
class Person < Model
  artisanal_model.configure { |config| config.writable = false }
  # ... or
  artisanal_model.config.writable = false
end
```

#### `defaults(hash)`

The `defaults` setting allows you to provide default values to the `attribute` dsl method. For example, if you would like all attributes to be optional and private:

```ruby
class Model
  include Artisanal::Model(defaults: { optional: true, reader: :private })
end
```

See the [dry-initializer](https://dry-rb.org/gems/dry-initializer/) documentation for a list of most of the options that can be passed to the `attribute` method.

#### `writable(boolean, default: false)`

Setting `writable` to true will enable the mass-assignment `#assign_attributes` method as well as add `writer: true` to the `defaults` configuration option.

You can also manually add `writer: true` to `defaults` without setting `writable` to true. This would give you attribute writers but skip creating the mass-assignment method.

#### `undefined(boolean, default: false)`

Setting `undefined` to true will configure dry-initializer to differentiate between `nil` values and undefineds. It will also automatically filter out undefined values when serializing your model to a hash.

See dry-initializer [Skip Undefined](https://dry-rb.org/gems/dry-initializer/skip-undefined/) documentation for more information.

#### `symbolize(boolean, default: false)`

Setting `symbolize` to true will make artisanal-model intern the keys of any attributes passed in during initialization and mass-assignment. Only attributes belonging to the model will be symbolized; all
other keys will be left as strings.

See the [integration test](blob/master/spec/artisanal/integration/stringified_arguments_spec.rb) for more details.
See the [benchmarks](#benchmarks) for the performance impact of "indifferent access".

## Examples

For the following examples, consider the following `Model` class with some default  configuration.

```ruby
class Model
  include Artisanal::Model(
    defaults: { optional: true, type: Dry::Types::Any }
  )
end
```

You can define attributes on your models using Artisanal::Model's `attribute` dsl method:

```ruby
class Person < Model
  attribute :first_name
  attribute :last_name
  attribute :email
end

Person.new(first_name: 'John', last_name: 'Smith', email: 'john@example.com').tap do |person|
  person.first_name #=> 'John'
  person.email #=> 'john@example.com'
end
```

Also, the keys passed into the initializer do not need to be symbolized ahead of time. Artisanal::Model will take care of that for you before passing them into dry-initializer:

```ruby
Person.new('first_name' => 'John').tap do |person|
  person.first_name #=> 'John'
end
```

### dry-initializer

For the most part, the parameters available to the `attribute` method are the same ones available to dry-initializer's [option method](https://dry-rb.org/gems/dry-initializer/params-and-options/). These allow you to do things like coerce values, rename incoming fields, set defaults, define required fields, and set method access control.

```ruby
class Person < Model
  attribute :first_name, default: -> { 'Bob' }
  attribute :last_name, optional: false
  attribute :email, from: :email_address
  attribute :phone, reader: :private
  attribute :age, ->(value, person) { value.to_i }
end

attrs = {
  last_name: 'Smith',
  email_address: 'john@example.com',
  phone: '555.123.4567',
  age: '37'
}

Person.new(attrs).tap do |person|
  person.first_name #=> 'Bob'
  person.email #=> 'john@example.com'
  person.phone #=> NoMethodError: private method `phone' called for...
  person.age #=> 37
end

Person.new(first_name: 'Steve')
#=> KeyError: Person: option 'last_name' is required
```

### aliased fields

The dry-initializer gem already lets you use the `:as` option to give your field a new name. To make this a little more straightforward, artisanal-model adds a `:from` option that is the inverse of `:as`:

```ruby
class Person < Model
  attribute :email_address, as: :email
  # is the same as  ...
  attribute :email, from: :email_address
end

Person.new(email_address: 'john@example.com').email #=> 'john@example.com'
```

### coercions

In addition to the functionality dry-initializer provides, Artisanal::Model also adds some niceties that make the dsl a little less verbose. For example, coercions in dry-initializer are required to be a callable type (e.g. a proc or a [dry-type](https://dry-rb.org/gems/dry-types/)).

However, Artisanal::Model will allow you to specify a class or an array and will wrap the type coercion with a proc in the background:

```ruby
class Address < Model
  attribute :street
  attribute :city
  attribute :state
  attribute :zip
end

class Tag < Model
  attribute :name
end

class Person < Model  
  attribute :name
  attribute :address, Address
  attribute :tags, Array[Tag]
  attribute :emails, Set[Dry::Types['string']]
end

attrs = {
  name: 'John Smith',
  address: {
    street: '123 Main St.',
    city: 'Portland',
    state: 'OR',
    zip: '97213'
  },
  tags: [
    { name: 'Ruby' },
    { name: 'Developer' }
  ],
  email: ['john@example.com', 'jsmith@example.com']
}

Person.new(attrs).tap do |person|
  person.name #=> 'John Smith'
  
  person.address.street #=> '123 Main St.'
  person.address.zip #=> '97213'
  
  person.tags.count #=> 2
  person.tags.first.name #=> 'Ruby'
end
```

### writers

Artisanal::Model can also add writer methods that aren't provided from dry-initializer:

```ruby
# Model.include Artisanal::Model(writable: true, ...)

class Person < Model
  attribute :name
  attribute :email, writer: false 
  attribute :phone, writer: :protected # the same as adding `protected :phone`
  attribute :age,   writer: :private   # the same as adding `private :age`
end

attrs = {
  name: 'John',
  email: 'john@example.com',
  phone: '555.123.4567',
  age: '37'
}

Person.new(attrs).tap do |person|
  person.name = 'Bob'
  person.name #=> 'Bob'

  person.email = 'bob@example.com'  # => NoMethodError: undefined method `email' called for ...
  person.phone = '555.987.6543'     # => NoMethodError: protected method `phone' called for ...
  person.age = '21'                 # => NoMethodError: private method `age' called for ...
end
```

Notice that any other value except for `false`, `:protected` and `:private` provides a public writer.

With `writable` enabled, models will also have a `assign_attributes` method to do attribute mass-assignment:

```ruby
class Person < Model
  attribute :name
  attribute :email
  attribute :age
end
  
Person.new(name: 'John Smith', email: 'john@example.com', age: '37').tap do |person|
  person.name #=> 'John Smith'
  
  person.assign_attributes(name: 'Bob Johnson', email: 'bob@example.com')

  person.name #=> 'Bob Johnson'
  person.email #=> 'bob@example.com'
  person.age #=> '37'
end
```

### serialization

Artisanal::Models can also be converted back into hashes for storage or representation purposes. By default, the result will only include public attributes, but `to_h` will also let you request private attributes as well:

```ruby
class Person < Model
  attribute :name
  attribute :email
  attribute :phone, reader: :private
  attribute :age, reader: :protected
end

Person.new(name: 'John Smith', phone: '555.123.4567', age: '37').tap do |person|
  person.to_h                               #=> { name: 'John Smith', email: nil }
  person.to_h(scope: :private)              #=> { phone: '555.123.4567' }
  person.to_h(scope: [:public, :protected]) #=> { name: 'John Smith', email: nil, age: '37' }
  person.to_h(scope: :all)                  #=> { name: 'John Smith', email: nil, phone: '555.123.4567', age: '37' }
end
```

### undefined attributes

Dry-initializer [differentiates](https://dry-rb.org/gems/dry-initializer/skip-undefined/) between a `nil` value passed in for an attribute and nothing passed in at all. 

This can be turned off through Artisanal::Model for performance reasons if you don't care about the differences between `nil` and undefined. However, if turned on, serializing to a hash will also exclude undefined values by default:

```ruby
# Model.include Artisanal::Model(undefined: true, ...)

class Person < Model
  attribute :name
  attribute :email
  attribute :phone
end

Person.new(name: 'John Smith', phone: nil).tap do |person|
  person.to_h                          #=> { name: 'John Smith', phone: nil }
  person.to_h(include_undefined: true) #=> { name: 'John Smith', email: nil, phone: nil }
end
```

## Benchmarks

Comparing artisanal-model with plain ruby, dry-initializer, hashie, and virtus:

```
Calculating -------------------------------------
          plain Ruby      2.493M (± 2.8%) i/s -     37.407M in  15.016557s
     dry-initializer    402.247k (± 2.7%) i/s -      6.051M in  15.054567s
     artisanal-model    322.343k (± 3.2%) i/s -      4.843M in  15.040670s
artisanal-model (WITH WRITERS)
                        329.785k (± 2.6%) i/s -      4.965M in  15.066329s
artisanal-model (WITH INDIFFERENT ACCESS)
                        284.767k (± 2.2%) i/s -      4.292M in  15.078616s
              hashie     37.250k (± 1.8%) i/s -    559.827k in  15.034072s
              virtus    136.092k (± 2.0%) i/s -      2.049M in  15.059855s

Comparison:
          plain Ruby:  2492919.5 i/s
     dry-initializer:   402247.4 i/s - 6.20x  slower
artisanal-model (WITH WRITERS):   329785.0 i/s - 7.56x  slower
     artisanal-model:   322342.7 i/s - 7.73x  slower
artisanal-model (WITH INDIFFERENT ACCESS):   284766.8 i/s - 8.75x  slower
              virtus:   136092.4 i/s - 18.32x  slower
              hashie:    37250.4 i/s - 66.92x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goldstar/artisanal-model.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
