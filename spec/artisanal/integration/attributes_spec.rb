RSpec.describe "Basic model attribute definitions" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Person
          include Artisanal::Model

          attribute :name, Dry::Types::Any
          attribute :email, Dry::Types['string']
          attribute :age, ->(value) { value.to_i }
          attribute :money, Dry::Types['coercible.integer']
        end
      end
    end
  }

  let(:data) {{
    email: 'john@example.com',
    name: 'John Smith',
    age: '37',
    money: '10000'
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "creates a basic object with attributes", :aggregate_failures do
    expect(person.name).to eq data[:name]
    expect(person.email).to eq data[:email]
    expect(person.age).to eq data[:age].to_i
    expect(person.money).to eq data[:money].to_i
  end
end
