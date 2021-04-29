module Participants
  class Base < Grape::API
    mount Participants::V1::ParticipantsAPI
  end
end
