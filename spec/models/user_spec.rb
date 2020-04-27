require 'rails_helper'

RSpec.describe User do
	describe '#display_user' do
		let(:email) { "user@example.com" }
		let(:phone) { "5555555555" }
		let(:username) { "something_clever" }
		let(:user) { create :user, email: email, phone: phone, username: username }
		let(:expected_response) do
			{:email => email, :phone => phone, :username => username}
		end

		subject { user.display_user }

		it 'returns hash with expected user fields' do
			expect(subject).to eq expected_response
		end
	end

	describe 'validations' do
		let(:email) { "user@example.com" }
		let(:phone) { "5555555555" }
		let(:username) { "something_clever" }

		subject { User.create!(email: email, phone: phone, username: username) }

		context 'when email is invalid' do
			let(:email) { "example.com" }

			it 'raises exception' do
				expect{subject}.to raise_error(ActiveRecord::RecordInvalid)
			end
		end

		context 'when phone is invalid' do
			let(:phone) { "12345678" }

			it 'raises exception' do
				expect{subject}.to raise_error(ActiveRecord::RecordInvalid)
			end
		end

		context 'when username is not unique' do
			let!(:user) { create :user, username: username }

			it 'raises exception' do
				expect{subject}.to raise_error(ActiveRecord::RecordInvalid)
			end
		end
	end
end