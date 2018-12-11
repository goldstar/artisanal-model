RSpec.describe "Renaming attributes using :from" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Person
          include Artisanal::Model

          attribute :email, Dry::Types['string'], from: :email_address
        end
      end
    end
  }

  let(:data) {{
    email_address: 'john@example.com'
  }}

  let(:person) { ns::Examples::Person.new(data) }

  it "renames the field using dry-initialier's :as option", :aggregate_failures do
    expect(person.class.schema.keys).to include :email_address
    expect(person.class.schema[:email_address].options).to include as: :email
    expect(person.email).to eq data[:email_address]
  end
end
