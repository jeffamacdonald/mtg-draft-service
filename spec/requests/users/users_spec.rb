require 'rails_helper'

RSpec.describe 'Users Requests' do
	let!(:user) { create :user }
	let(:decoded_token) do
		{:user_id => user.id}
	end

	describe 'GET /', type: :request do
		let(:url) {'/api/v1/users'}

		subject { get url }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let!(:user1) { create :user }
			let!(:user2) { create :user }
			let(:expected_response) { [user.display_user,user1.display_user,user2.display_user] }

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns 200' do
				subject
				expect(response.status).to eq 200
			end

			it 'returns expected response body' do
				subject
				expect(response.body).to eq expected_response.to_json
			end
		end

		describe 'GET /current/cubes', type: :request do
			let(:url) {'/api/v1/users/current/cubes'}

			subject { get url }

			context 'when user is not signed in' do
				it 'returns 403' do
					subject
					expect(response.status).to eq 403
				end
			end

			context 'when user is signed in' do
				let!(:cube1) { create :cube, user_id: user.id }
				let!(:cube2) { create :cube, user_id: user.id }
				let(:expected_response) { [cube1,cube2] }

				before do
					allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
				end

				it 'returns 200' do
					subject
					expect(response.status).to eq 200
				end

				it 'returns expected response body' do
					subject
					expect(response.body).to eq expected_response.to_json
				end
			end
		end

		describe 'GET /current/drafts', type: :request do
			let(:url) {'/api/v1/users/current/drafts'}

			subject { get url }

			context 'when user is not signed in' do
				it 'returns 403' do
					subject
					expect(response.status).to eq 403
				end
			end

			context 'when user is signed in' do
				let!(:draft1) { create :draft }
				let!(:draft2) { create :draft }
				let!(:inactive_draft1) { create :draft, active_status: false }
				let!(:inactive_draft2) { create :draft, active_status: false }
				let!(:draft_participant1) { create :draft_participant, user_id: user.id, draft_id: draft1.id }
				let!(:draft_participant2) { create :draft_participant, user_id: user.id, draft_id: draft2.id }
				let!(:draft_participant3) { create :draft_participant, user_id: user.id, draft_id: inactive_draft1.id }
				let!(:draft_participant4) { create :draft_participant, user_id: user.id, draft_id: inactive_draft2.id }
				let(:expected_response) do
					{
						:active => [draft1,draft2],
						:inactive => [inactive_draft1,inactive_draft2]
					}
				end

				before do
					allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
				end

				it 'returns 200' do
					subject
					expect(response.status).to eq 200
				end

				it 'returns expected response body' do
					subject
					expect(response.body).to eq expected_response.to_json
				end
			end
		end
	end
end