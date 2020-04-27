require 'rails_helper'

RSpec.describe JsonWebToken do
	let(:payload) do
		{:user_id => 123}
	end

	describe '.encode' do

		subject { described_class.encode(payload) }

		it 'returns a jwt with expected payload' do
			decoded_output = JWT.decode(subject, Rails.application.secrets.secret_key_base)[0]
			expect(decoded_output).to have_key("user_id")
			expect(decoded_output).to have_key("exp")
		end
	end

	describe '.decode' do
		let(:jwt) {JWT.encode(payload, Rails.application.secrets.secret_key_base)}

		subject { described_class.decode(jwt) }

		it 'decodes jwt with expected payload' do
			expect(subject).to eq payload.with_indifferent_access
		end
	end
end