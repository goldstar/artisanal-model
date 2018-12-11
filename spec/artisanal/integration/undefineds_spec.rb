RSpec.describe "Undefined attributes" do
  let(:data) {{
    name: 'John Smith',
    age: nil
  }}

  let(:person) { ns::Examples::Person.new(data) }

  context "when not differentiating between nils and undefineds" do
    let(:ns) {
      Module.new.tap do |mod|
        module mod::Examples
          class Person
            include Artisanal::Model

            attribute :name, Dry::Types::Any
            attribute :email, Dry::Types::Any
            attribute :age, Dry::Types::Any
          end
        end
      end
    }

    it "includes all attributes when serializing" do
      expect(person.to_h).to eq({
        name: 'John Smith',
        age: nil,
        email: nil
      })
    end
  end

  context "when differentiating between nils and undefineds" do
    let(:ns) {
      Module.new.tap do |mod|
        module mod::Examples
          class Person
            include Artisanal::Model(undefined: true)

            attribute :name, Dry::Types::Any
            attribute :email, Dry::Types::Any
            attribute :age, Dry::Types::Any
          end
        end
      end
    }

    it "includes only defined attributes when serializing" do
      expect(person.to_h).to eq({
        name: 'John Smith',
        age: nil
      })
    end

    context "and undefined: true is passed in" do
      it "includes all attributes when serializing" do
        expect(person.to_h(include_undefined: true)).to eq({
          name: 'John Smith',
          age: nil,
          email: nil
        })
      end
    end
  end
end
