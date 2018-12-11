RSpec.describe "Model with default attribute options" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Account
          include Artisanal::Model(defaults: { type: Dry::Types['coercible.integer'] })

          attribute :amount
        end

        class Person
          include Artisanal::Model(defaults: { optional: true, type: Dry::Types['coercible.string'] })

          attribute :name
          attribute :email_address, as: :email
          attribute :age
          attribute :money, ->(value) { value.to_i }
        end
      end
    end
  }

  let(:person_data) {{
    email_address: 'john@example.com',
    age: 37,
    money: '10000'
  }}

  let(:account_data) {{ amount: '10000' }}

  let(:person) { ns::Examples::Person.new(person_data) }
  let(:account) { ns::Examples::Account.new(account_data)}

  it "uses the default options for all attributes", :aggregate_failures do
    expect(person.name).to eq nil                   # field is optional
    expect(person.age).to eq person_data[:age].to_s # field is coerced into a string
  end

  it "gives custom options priority over the defaults", :aggregate_failures do
    expect(person.email).to eq person_data[:email_address] # field is renamed
    expect(person.money).to eq 10000                       # field is coerced
  end

  it "does not affect other model's default configuration" do
    expect(account.amount).to eq account_data[:amount].to_i # field is coerced
  end
end
