require 'rails_helper'

RSpec.describe User do
	describe '#display_user' do
		let(:email) { "user@example.com" }
		let(:phone) { "5555555555" }
		let(:username) { "something_clever" }
		let(:user) { create :user, email: email, phone: phone, username: username }
		let(:expected_response) do
			{:id => user.id, :email => email, :phone => phone, :username => username}
		end

		subject { user.display_user }

		it 'returns hash with expected user fields' do
			expect(subject).to eq expected_response
		end
	end

	describe '#display_drafts' do
		let(:user) { create :user }
		let!(:pending_draft1) { create :draft, status: 'PENDING' }
		let!(:pending_draft2) { create :draft, status: 'PENDING' }
		let!(:draft1) { create :draft, status: 'ACTIVE' }
		let!(:draft2) { create :draft, status: 'ACTIVE' }
		let!(:inactive_draft1) { create :draft, status: 'INACTIVE' }
		let!(:inactive_draft2) { create :draft, status: 'INACTIVE' }
		let!(:draft_participant1) { create :draft_participant, user_id: user.id, draft_id: pending_draft1.id }
		let!(:draft_participant2) { create :draft_participant, user_id: user.id, draft_id: pending_draft2.id }
		let!(:draft_participant3) { create :draft_participant, user_id: user.id, draft_id: draft1.id }
		let!(:draft_participant4) { create :draft_participant, user_id: user.id, draft_id: draft2.id }
		let!(:draft_participant5) { create :draft_participant, user_id: user.id, draft_id: inactive_draft1.id }
		let!(:draft_participant6) { create :draft_participant, user_id: user.id, draft_id: inactive_draft2.id }
		let(:expected_response) do
			{
				:pending => [pending_draft1, pending_draft2],
				:active => [draft1,draft2],
				:inactive => [inactive_draft1,inactive_draft2]
			}
		end

		subject { user.display_drafts }

		it 'returns hash with expected draft data' do
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