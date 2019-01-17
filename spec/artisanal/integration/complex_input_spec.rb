RSpec.describe "Basic model attribute definitions" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Person
          include Artisanal::Model(writable: true)

          attribute :name, Dry::Types::Any
          attribute :email, Dry::Types['string']
          attribute :age, ->(value) { value.to_i }
          attribute :money, Dry::Types['coercible.integer']
        end

        class Input
          def to_h
            {
              name: 'John Smith',
              email: 'john@example.com',
              age: '37',
              money: '10000'
            }
          end
        end
      end
    end
  }
  
  let(:input) { ns::Examples::Input.new }
  let(:person) { ns::Examples::Person.new(input) }

  it "converts the input to a hash", :aggregate_failures do
    expect(person.name).to eq input.to_h[:name]
    expect(person.email).to eq input.to_h[:email]
    expect(person.age).to eq input.to_h[:age].to_i
    expect(person.money).to eq input.to_h[:money].to_i
  end

  context "when re-assigning attributes" do
    let(:person) { ns::Examples::Person.new }

    it "converts the input to a hash", :aggregate_failures do
      expect { person.assign_attributes(input) }.
        to change { person.name }.from(nil).to(input.to_h[:name]).
        and change { person.email }.from(nil).to(input.to_h[:email]).
        and change { person.age }.from(nil).to(input.to_h[:age].to_i).
        and change { person.money }.from(nil).to(input.to_h[:money].to_i)
    end
  end
end
