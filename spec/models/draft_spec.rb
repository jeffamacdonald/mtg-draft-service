require 'rails_helper'

RSpec.describe Draft do
	describe '#create_participants' do
		let(:user1) { create :user }
		let(:user2) { create :user }
		let(:user_ids) { [user1.id, user2.id] }
		let(:draft) { create :draft }

		subject { draft.create_participants(user_ids) }

		context 'when all users exist' do
			it 'participants are created for each user' do
				subject
				participants = DraftParticipant.all
				expect(participants.count).to eq 2
				expect(participants.find { |p| p[:draft_id] == draft.id }).to be_present
				expect(participants.find { |p| p[:user_id] == user1.id }).to be_present
				expect(participants.find { |p| p[:display_name] == user1.username }).to be_present
				expect(participants.find { |p| p[:draft_position] == 1 }).to be_present
				expect(participants.find { |p| p[:draft_position] == 2 }).to be_present
			end
		end

		context 'when a user does not exist' do
			let(:user_ids) { [user1.id, user2.id, 100] }

			it 'raises RecordNotFound exception' do
				expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
	end
end