RSpec.describe "Submodels inheriting from other models" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Base
          include Artisanal::Model(defaults: { type: Dry::Types['coercible.string'] })

          attribute :age, ->(value) { value.to_i }
          attribute :money
        end

        class Person < Base
          attribute :name
          attribute :email
          attribute :money, Dry::Types['coercible.integer']
          attribute :cars
        end
      end
    end
  }

  let(:data) {{
    name: 'John Smith',
    email: 'john@example.com',
    age: '37',
    money: '10000',
    cars: 3
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "inherits the parent's configuration", :aggregate_failures do
    expect(person.name).to eq data[:name]
    expect(person.email).to eq data[:email]
    expect(person.cars).to eq data[:cars].to_s
  end

  it "inherits the parent's attributes" do
    expect(person.age).to eq data[:age].to_i
  end

  it "overwrites the parent's existing attributes" do
    expect(person.money).to eq data[:money].to_i
  end
end
