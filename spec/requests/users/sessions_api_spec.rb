require 'rails_helper'

RSpec.describe 'Sessions API Requests' do
  describe 'POST /login', type: :request do
    let(:user) { create :user }
    let(:url) { '/api/v1/users/login' }
    let(:params) do
      {
        email: user.email,
        password: user.password
      }
    end

    subject { post url, params: params }

    context 'when params are correct' do
      it 'returns JWT in authorization header' do
        subject
        expect(response.status).to eq 200
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'when params are incorrect' do
      let(:params) do
        {
          email: user.email,
          password: "not_the_password"
        }
      end
      it 'returns 401' do
        subject
        expect(response.status).to eq 401
      end
    end
  end

  describe 'POST /logout' do
    let(:url) { "/api/v1/users/logout" }
    let(:user) { create :user }
    let(:jti) { SecureRandom.uuid }
    let(:decoded_token) do
      {:user_id => user.id,:jti => jti}
    end

    subject { post url }

    context 'when user is not signed in' do
      it 'returns 403' do
        subject
        expect(response.status).to eq 403
      end
    end

    context 'when user is signed in' do
      before do
        allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
      end

      it 'adds an entry to jwt blacklist' do
        subject
        expect(response.status).to eq 204
        expect(JwtBlacklist.find_by(jti: jti)).to be_present
      end

      it 'user cannot call auth endpoints' do
        subject
        get '/api/v1/cubes'
        expect(response.status).to eq 403
      end
    end
  end
end