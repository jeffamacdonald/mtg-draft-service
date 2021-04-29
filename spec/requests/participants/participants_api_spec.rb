require 'rails_helper'

RSpec.describe 'GET /drafts/:draft_id/participants', type: :request do
  let(:url) { "/api/v1/drafts/#{draft_id}/participants" }
  let!(:draft) do
    create :draft
  end
  let!(:participant_1) do
    create :draft_participant, draft_id: draft.id
  end
  let!(:participant_2) do
    create :draft_participant, draft_id: draft.id
  end
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
    let(:user_id) { user.id }

    before do
      allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
    end

    context 'when draft does not exist' do
      let(:draft_id) { 1000000000 }

      it 'returns 404' do
        subject
        expect(response.status).to eq 404
      end
    end

    context 'when draft has participants' do
      it 'returns participants' do
        subject
        expect(response.status).to eq 200
        expect(response.body).to include participant_1.to_json
        expect(response.body).to include participant_2.to_json
      end
    end
  end
end
