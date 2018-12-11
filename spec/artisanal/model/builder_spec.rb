RSpec.describe Artisanal::Model::Builder do
  let(:options) {{}}

  subject(:builder) { described_class.new(options) }

  describe "#config" do
    subject(:config) { builder.config }

    it { is_expected.to be_a Artisanal::Model::Config }

    its(:defaults) { is_expected.to eq(optional: true) }
    its(:writable?) { is_expected.to eq false }
    its(:undefined?) { is_expected.to eq false }

    context "when configuration options are present" do
      let(:options) {{
        defaults: { type: Dry::Types::Any },
        writable: true
      }}

      it "overwrites the default options", :aggregate_failures do
        expect(config.defaults[:optional]).to eq true
        expect(config.defaults[:type]).to eq Dry::Types::Any
        expect(config.writable?).to eq true
        expect(config.undefined?).to eq false
      end
    end
  end

  describe "#included" do
    let(:options) {{ defaults: { optional: false }}}
    let(:model) {
      Class.new.tap do |klass|
        klass.include Artisanal::Model::Builder.new(options)
      end
    }

    it "extends the Model::DSL" do
      expect(model.singleton_class.included_modules).to include Artisanal::Model::DSL
    end

    it "extends the Dry::Initializer DSL" do
      expect(model.respond_to?(:dry_initializer)).to eq true
    end

    it "copies the configuration to the model instance" do
      expect(model.artisanal_model.config.defaults[:optional]).to eq false
    end

    it "does not include a mass-assignment method" do
      expect(model.new.respond_to? :assign_attributes).to eq false
    end

    context "when the model is 'writable'" do
      let(:options) {{ writable: true }}

      it "defaults all attributes to 'writer: true'" do
        expect(model.artisanal_model.config.defaults).to include writer: true
      end

      it "creates a mass-assignment method" do
        expect(model.new.respond_to? :assign_attributes).to eq true
      end

      context "and attribute writers are already configured" do
        let(:options) {{ writable: true, defaults: { writer: :protected } }}

        it "keeps the specified configuration" do
          expect(model.artisanal_model.config.defaults).to include writer: :protected
        end
      end
    end
  end

  describe "#assign_attributes" do
    let(:model) {
      Class.new do
        include Artisanal::Model::Builder.new(writable: true)

        attribute :name, Dry::Types::Any
        attribute :email, Dry::Types::Any
        attribute :age, Dry::Types::Any
      end
    }
    let(:example) { model.new(name: 'John Smith', email: 'john@example.com', age: 50) }

    it "does a mass-assignment for provided attributes" do
      expect { example.assign_attributes(name: 'Bob Stevens', email: 'bob@example.com') }.
        to change { example.name }.from('John Smith').to('Bob Stevens').
        and change { example.email }.from('john@example.com').to('bob@example.com')
    end

    it "does not affect undefined attributes" do
      expect { example.assign_attributes(name: 'Bob Stevens', email: 'bob@example.com') }.
        to_not change { example.age }
    end
  end
end
