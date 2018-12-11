RSpec.describe "A writable model" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Person
          include Artisanal::Model(writable: true)

          attribute :name, Dry::Types::Any
          attribute :email, Dry::Types::Any
          attribute :age, Dry::Types['coercible.integer']
          attribute :money, Dry::Types['coercible.integer'], writer: false
        end
      end
    end
  }

  let(:original) {{
    name: 'John Smith',
    email: 'john@example.com',
    age: '37',
    money: '10000'
  }}

  let(:person) { ns::Examples::Person.new(original) }

  it "creates writers for each attribute" do
    expect { person.name = 'Bob Stevens' }.
      to change { person.name }.
      from(original[:name]).
      to('Bob Stevens')
  end

  it "uses the attribute type to coerce the value" do
    expect { person.age = '50' }.
      to change { person.age }.
      from(original[:age].to_i).
      to(50)
  end

  it "skips writers if the attribute is configured manually" do
    expect(person.respond_to? :money=).to eq false
  end

  it "creates a mass-assignment method" do
    expect(person.respond_to? :assign_attributes).to eq true
  end

  describe "#assign_attributes" do
    let(:updated) {{
      name: 'Bob Stevens',
      age: '50',
      money: '15000'
    }}

    before { person.assign_attributes(updated) }

    it "assigns the value for all attributes passed in", :aggregate_failures do
      expect(person.name).to eq updated[:name]
      expect(person.age).to eq updated[:age].to_i
    end

    it "skips any attributes not included in the data" do
      expect(person.email).to eq original[:email]
    end

    it "skips any attributes without public writers" do
      expect(person.money).to eq original[:money].to_i
    end
  end
end
