RSpec.describe "Stringified attributes" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Person
          include Artisanal::Model(writable: true)

          attribute :name, Dry::Types::Any
          attribute :email, Dry::Types::Any
          attribute :age, proc(&:to_i)
        end
      end
    end
  }

  let(:data) {{
    'name' => 'John Smith',
    email: 'john@example.com',
    'age' => '37',
    'bank_account_balance' => 10000
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "coerces the strings into symbols when initializing", :aggregate_failures do
    expect(person.name).to eq data['name']
    expect(person.email).to eq data[:email]
    expect(person.age).to eq data['age'].to_i
  end

  it "coerces the strings into symbols when mass-assigning", :aggregate_failures do
    person.assign_attributes('name' => 'Bob Stevens', email: 'bob@example.com')

    expect(person.name).to eq 'Bob Stevens'
    expect(person.email).to eq 'bob@example.com'
    expect(person.age).to eq data['age'].to_i
  end

  it "only interns the attributes included on the model" do
    expect(Symbol.all_symbols.map(&:to_s)).to_not include 'bank_account_balance'
  end
end
