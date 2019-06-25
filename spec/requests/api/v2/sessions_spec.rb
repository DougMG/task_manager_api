require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  before { host! 'api.taskmanager.test' }
  let!(:user) { create(:user) }
  let!(:user_data) { user.create_new_auth_token }

  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanager.v2',
      'Content-Type' => Mime[:json].to_s,
      'access-token' => user_data['access-token'],
      'uid' => user_data['uid'],
      'client' => user_data['client']
    }
  end

  describe 'POST /auth/sign_in' do
    before do
      post '/auth/sign_in', params: credentials.to_json, headers: headers
    end

    context 'when the credentials are correct' do
      let(:credentials) { { email: user.email, password: '123456' } }

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end

      it 'returns the authetication data in the headers' do
        expect(response.headers).to have_key('access-token')
        expect(response.headers).to have_key('uid')
        expect(response.headers).to have_key('client')
      end
    end

    context 'when the credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'invalid_password' } }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns json data for the errors ' do
        expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'DELETE /auth/sign_out' do
    let(:auth_token) { user.auth_token }

    before do
      delete '/auth/sign_out', params: {}, headers: headers
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'changes the user auth token' do
      user.reload
      # expect( user.valid_token?(user_data['token'], user_data['client']) ).to eq(false)
      expect(user).not_to be_valid_token(user_data['token'], user_data['client'])
    end
  end

end
