RSpec.describe "Model with complex attribute coercion" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Address
          include Artisanal::Model

          attribute :street, Dry::Types::Any
          attribute :city, Dry::Types::Any
          attribute :state, Dry::Types::Any
          attribute :zip, Dry::Types::Any
        end

        class Tag
          include Artisanal::Model

          attribute :name, Dry::Types::Any
        end

        class Person
          include Artisanal::Model

          attribute :name, Dry::Types::Any
          attribute :address, Address
          attribute :tags, Array[Tag]
          attribute :emails, Set[Dry::Types['strict.string']]
        end
      end
    end
  }

  let(:data) {{
    name: 'John Smith',
    address: {
      street: '123 Main St.',
      city: 'Portland',
      state: 'OR',
      zip: '97212'
    },
    tags: Set.new([
      { name: "open-source" },
      { name: "ruby" },
      { name: "developer" }
    ]),
    emails: ['john@example.com', 'jsmith@example.com']
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "coerces classes with a new instance of the class", :aggregate_failures do
    expect(person.address).to be_a(ns::Examples::Address)
    expect(person.address.street).to eq data.dig(:address, :street)
  end

  it "coerces each element of an array with the first element of the type", :aggregate_failures do
    expect(person.tags).to be_a Array
    expect(person.tags).to all be_a ns::Examples::Tag
    expect(person.tags.first.name).to eq 'open-source'
  end

  it "coerces each element of a set with the first element of the type", :aggregate_failures do
    expect(person.emails).to be_a Set
    expect(person.emails).to all be_a String
    expect(person.emails.first).to eq 'john@example.com'
  end
end
