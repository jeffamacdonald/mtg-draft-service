require 'rails_helper'

RSpec.describe 'Setup Requests' do
	describe 'POST /create', type: :request do
		let(:url) { '/api/v1/drafts/create' }
		let(:name) { "Test Draft" }
		let(:cube) { create :cube }
		let(:rounds) { 40 }
		let(:timer_minutes) { 120 }
		let(:user1) { create :user }
		let(:user2) { create :user }
		let(:user_ids) { [user1.id,user2.id] }
		let(:params) do
			{
				name: name,
				cube_id: cube.id,
				rounds: rounds,
				timer_minutes: timer_minutes,
				user_ids: user_ids
			}
		end

		subject { post url, params: params }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let(:decoded_token) do
				{:user_id => user1.id}
			end

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			context 'when all params are present' do
				it 'returns 201' do
					subject
					expect(response.status).to eq 201
				end

				it 'draft is created' do
					subject
					expect(Draft.all.count).to eq 1
					expect(Draft.first.users).to eq [user1, user2]
					expect(Draft.first.active_status).to eq true
				end
			end

			context 'when user id does not exist' do
				let(:user_ids) { [user1.id,user2.id,100] }
				let(:expected_error) { { "error": "Invalid Draft Participants" } }

				it 'returns 400' do
					subject
					expect(response.status).to eq 400
				end

				it 'returns error message' do
					subject
					expect(response.body).to eq expected_error.to_json
				end
			end
		end
	end
end