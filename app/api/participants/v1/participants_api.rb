module Participants
  module V1
    class ParticipantsAPI < Grape::API
      version 'v1'
      prefix :api
      format :json
      helpers AuthHelper

      before do
        set_authenticated_user
      end

      resources :drafts do
        desc 'get draft participants'
        params do
          requires :draft_id, type: Integer
        end
        get ':draft_id/participants' do
          begin
            Draft.find(params[:draft_id]).draft_participants
          rescue ActiveRecord::RecordNotFound => ex
            error!(ex.message, :not_found)
          end
        end
      end
    end
  end
end
