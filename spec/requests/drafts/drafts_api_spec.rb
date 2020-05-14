require 'rails_helper'

RSpec.describe 'Drafts API Requests' do
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
				it 'draft is created' do
					subject
					expect(response.status).to eq 201
					expect(Draft.all.count).to eq 1
					expect(Draft.first.users).to eq [user1, user2]
					expect(Draft.first.active_status).to eq true
				end
			end

			context 'when user id does not exist' do
				let(:user_ids) { [user1.id,user2.id,100] }
				let(:expected_error) { { "error": "Invalid Draft Participants" } }

				it 'returns error message' do
					subject
					expect(response.status).to eq 400
					expect(response.body).to eq expected_error.to_json
				end
			end
		end
	end

	describe 'POST /:draft_id', type: :request do
		let(:url) { "/api/v1/drafts/#{draft_id}" }
		let(:draft) { create :draft }
		let(:draft_id) { draft.id }

		subject { get url }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let(:user) { create :user }
			let(:decoded_token) do
				{:user_id => user.id}
			end

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns expected response body' do
				subject
				expect(response.status).to eq 200
				expect(response.body).to eq draft.to_json
			end

			context 'when draft does not exist' do
				let(:draft_id) { 100 }

				it 'returns 404' do
					subject
					expect(response.status).to eq 404
				end
			end
		end
	end
end