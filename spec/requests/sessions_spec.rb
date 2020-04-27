require 'rails_helper'

RSpec.describe 'POST /login', type: :request do
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
  	it 'returns 200' do
  		subject
  		expect(response.status).to eq 200
  	end

  	it 'returns JWT in authorization header' do
  		subject
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