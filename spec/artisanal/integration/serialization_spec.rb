RSpec.describe "Serialization" do
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
          attribute :email_address, Dry::Types::Any, as: :email
          attribute :age, proc(&:to_i), reader: :protected
          attribute :money, proc(&:to_i), reader: :private
          attribute :address, Address
          attribute :tags, Array[Tag]
          attribute :emails, Set[Dry::Types['strict.string']]
        end
      end
    end
  }

  let(:data) {{
    name: 'John Smith',
    email_address: 'john@example.com',
    age: '37',
    money: '10000',
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

  let(:public_attrs) {{
    name: 'John Smith',
    email: 'john@example.com',
    address: {
      street: '123 Main St.',
      city: 'Portland',
      state: 'OR',
      zip: '97212'
    },
    tags: [
      { name: "open-source" },
      { name: "ruby" },
      { name: "developer" }
    ],
    emails: ['john@example.com', 'jsmith@example.com']
  }}

  let(:protected_attrs) {{
    age: 37
  }}

  let(:private_attrs) {{
    money: 10000
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "serializes all public attributes" do
    expect(person.to_h).to eq(public_attrs)
  end

  context "when protected attributes are requested" do
    it "adds protected attributes to the serialization" do
      expect(person.to_h(scope: :protected)).to eq(protected_attrs)
    end
  end

  context "when only private attributes are requested" do
    it "adds private attributes to the serialization" do
      expect(person.to_h(scope: :private)).to eq(private_attrs)
    end
  end

  context "when protected & private private are requested" do
    it "serializes protected & private attributes" do
      expect(person.to_h(scope: [:protected, :private])).to eq protected_attrs.merge(private_attrs)
    end
  end

  context "when all methods are requested" do
    it "serializes all attributes" do
      expect(person.to_h(scope: :all)).
        to eq public_attrs.merge(protected_attrs).merge(private_attrs)
    end
  end
end
