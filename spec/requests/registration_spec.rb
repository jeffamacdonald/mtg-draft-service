require 'rails_helper'

RSpec.describe 'POST /register', type: :request do
  let(:url) { '/users/register' }
  let(:email) {'user@example.com'}
  let(:username) {'testuser'}
  let(:phone) {'9876543210'}
  let(:password) {'password'}
  let(:params) do
    {
      user: {
        email: email,
        username: username,
        phone: phone,
        password: password,
        password_confirmation: password
      }
    }
  end

  subject { post url, params: params }

  context 'when user is unauthenticated' do
    it 'returns 200' do
      subject
      expect(response.status).to eq 200
    end

    it 'returns a new user with correct values' do
      subject
      response_body = JSON.parse(response.body)
      expect(response_body["email"]).to eq email
      expect(response_body["username"]).to eq username
      expect(response_body["phone"]).to eq phone
    end
  end

  context 'when user already exists' do
    let!(:user) { create :user, email: params[:user][:email] }

    it 'returns bad request status' do
      subject
      expect(response.status).to eq 400
    end

    it 'returns validation errors' do
      subject
      expect(JSON.parse(response.body)['error']).to eq('User already exists')
    end
  end
end