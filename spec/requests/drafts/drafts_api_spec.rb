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
					expect(Draft.first.users).to include user1
					expect(Draft.first.users).to include user2
					expect(Draft.first.status).to eq 'PENDING'
				end
			end

			context 'when user id does not exist' do
				let(:user_ids) { [user1.id,user2.id,100] }
				let(:expected_error) { "Couldn't find all Users with 'id'" }

				it 'returns error message' do
					subject
					expect(response.status).to eq 400
					expect(response.body).to include expected_error
				end
			end
		end
	end

	describe 'GET /:draft_id', type: :request do
		let(:url) { "/api/v1/drafts/#{draft_id}" }
		let!(:draft) { create :draft }
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
			let!(:draft_participant) { create :draft_participant, draft_id: draft.id, draft_position: 1 }
			let(:expected_response) do
				draft.attributes.merge(:active_participant => draft_participant)
			end

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns expected response body' do
				subject
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end

			context 'when draft does not exist' do
				let(:draft_id) { 1000000000 }

				it 'returns 404' do
					subject
					expect(response.status).to eq 404
				end
			end
		end
	end

	describe 'PATCH /:draft_id/start' do
		let(:url) { "/api/v1/drafts/#{draft_id}/start" }
		let!(:draft) { create :draft, status: 'PENDING' }
		let!(:draft_participant_1) { create :draft_participant, draft_id: draft.id }
		let!(:draft_participant_2) { create :draft_participant, draft_id: draft.id }
		let!(:draft_participant_3) { create :draft_participant, draft_id: draft.id }
		let(:draft_id) { draft.id }

		subject { patch url }

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
				allow_any_instance_of(Array).to receive(:shuffle).and_return([draft_participant_2, draft_participant_3, draft_participant_1])
			end

			it 'sets draft to ACTIVE and instantiates draft positions' do
				subject
				expect(response.status).to eq 200
				expect(draft.reload.status).to eq 'ACTIVE'
				expect(draft_participant_1.reload.draft_position).to eq 3
				expect(draft_participant_2.reload.draft_position).to eq 1
				expect(draft_participant_3.reload.draft_position).to eq 2
			end

			context 'when draft does not exist' do
				let(:draft_id) { 1000000000 }

				it 'returns 404' do
					subject
					expect(response.status).to eq 404
				end
			end
		end
	end

	describe 'GET /status/:status', type: :request do
		let(:url) { "/api/v1/drafts/status/#{status}" }
		let!(:draft_1) { create :draft, status: 'ACTIVE' }
		let!(:draft_2) { create :draft, status: 'INACTIVE' }
		let!(:draft_3) { create :draft, status: 'PENDING' }

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

			context 'when status is not valid' do
				let(:status) { 'INVALID' }
				let(:expected_error) { { "error": "Invalid Status" } }

				it 'returns error message' do
					subject
					expect(response.status).to eq 400
					expect(response.body).to eq expected_error.to_json
				end
			end

			context 'when status is ACTIVE' do
				let(:status) { 'ACTIVE' }
				let(:expected_response) do
					[draft_1.attributes.merge(:active_participant => nil)]
				end

				it 'returns all pending drafts display hash' do
					subject
					expect(response.status).to eq 200
					expect(response.body).to eq expected_response.to_json
				end
			end

			context 'when status is ACTIVE' do
				let(:status) { 'INACTIVE' }
				let(:expected_response) do
					[draft_2.attributes.merge(:active_participant => nil)]
				end

				it 'returns all pending drafts display hash' do
					subject
					expect(response.status).to eq 200
					expect(response.body).to eq expected_response.to_json
				end
			end

			context 'when status is ACTIVE' do
				let(:status) { 'PENDING' }
				let(:expected_response) do
					[draft_3.attributes.merge(:active_participant => nil)]
				end

				it 'returns all pending drafts display hash' do
					subject
					expect(response.status).to eq 200
					expect(response.body).to eq expected_response.to_json
				end
			end
		end
	end
end