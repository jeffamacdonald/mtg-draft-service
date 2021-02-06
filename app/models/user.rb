class User < ApplicationRecord
  has_secure_password
	has_many :cubes
	has_many :draft_participants
	has_many :drafts, :through => :draft_participants
  validates :username, uniqueness: { case_sensitive: false }, presence: true, allow_blank: false, format: { with: /\A[a-zA-Z0-9_]+\z/ }
  validates :phone, format: { with: /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\z/ }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def display_user
  	{:id => id, :email => email, :username => username, :phone => phone}
  end

  def display_drafts
  	{
      :pending => drafts.select(&:pending?),
  		:active => drafts.select(&:active?),
  		:inactive => drafts.select(&:inactive?)
  	}
  end
end
