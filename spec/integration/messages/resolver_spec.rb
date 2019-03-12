# frozen_string_literal: true

RSpec.describe Dry::Validation::Messages::Resolver, '#message' do
  shared_context 'resolving' do
    subject(:resolver) do
      contract_class.new(locale: locale).message_resolver
    end

    let(:contract_class) do
      Class.new(Dry::Validation::Contract)
    end

    before do
      contract_class.config.messages_file = SPEC_ROOT
        .join("fixtures/messages/errors.#{locale}.yml").realpath

      I18n.available_locales << :pl
      I18n.backend.load_translations
      I18n.reload!
    end

    context ':en' do
      let(:locale) { :en }

      it 'returns message text for base rule' do
        expect(resolver.message(:not_weekend, path: [nil]).to_s)
          .to eql('this only works on weekends')
      end

      it 'returns message text for flat rule' do
        expect(resolver.message(:taken, path: [:email], tokens: { email: 'jane@doe.org' }).to_s)
          .to eql('looks like jane@doe.org is taken')
      end

      it 'returns message text for nested rule when it is defined under root' do
        expect(resolver.message(:invalid, path: %i[address city]).to_s)
          .to eql('is not a valid city name')
      end

      it 'returns message text for nested rule' do
        expect(resolver.message(:invalid, path: %i[address street]).to_s)
          .to eql("doesn't look good")
      end

      it 'raises error when template was not found' do
        expect { resolver.message(:not_here, path: [:email]) }
          .to raise_error(Dry::Validation::MissingMessageError, <<~STR)
            Message template for :not_here under "email" was not found
          STR
      end
    end

    context ':pl' do
      let(:locale) { :pl }

      it 'returns message text for base rule' do
        expect(resolver.message(:not_weekend, path: [nil]).to_s)
          .to eql('to działa tylko w weekendy')
      end

      it 'returns message text for flat rule' do
        expect(resolver.message(:taken, path: [:email], tokens: { email: 'jane@doe.org' }).to_s)
          .to eql('wygląda, że jane@doe.org jest zajęty')
      end

      it 'returns message text for nested rule when it is defined under root' do
        expect(resolver.message(:invalid, path: %i[address city]).to_s)
          .to eql('nie jest poprawną nazwą miasta')
      end

      it 'returns message text for nested rule' do
        expect(resolver.message(:invalid, path: %i[address street]).to_s)
          .to eql('nie wygląda dobrze')
      end
    end
  end

  context 'using :yaml' do
    before do
      contract_class.config.messages = :yaml
    end

    include_context 'resolving'
  end

  context 'using :i18n' do
    before do
      contract_class.config.messages = :i18n
    end

    include_context 'resolving'
  end
end
