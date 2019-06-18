RSpec.describe "Model attribute writers" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Address
          include Artisanal::Model
        end

        class Person
          include Artisanal::Model

          attribute :name, Dry::Types::Any
          attribute :email, Dry::Types::Any, writer: true
          attribute :address, Address, writer: true
          attribute :age, Dry::Types::Any, writer: :protected
          attribute :money, Dry::Types::Any, writer: :private
        end
      end
    end
  }

  let(:data) {{
    name: 'John Smith',
    email: 'john@example.com',
    age: '37',
    money: '10000'
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "does not create writers by default" do
    expect(person.respond_to? :name=).to eq false
  end

  it "creates a public writer when true", :aggregate_failures do
    expect(person.public_methods).to include :email=
    expect { person.email = 'bob@example.com' }.
      to change { person.email }.
      to('bob@example.com')
    expect { person.address = {} }.
      to change { person.address }.
      to be_a ns::Examples::Address
  end

  it "creates a protected writer when :protected" do
    expect(person.protected_methods).to include :age=
  end

  it "creates a private writer when :private" do
    expect(person.private_methods).to include :money=
  end
end
