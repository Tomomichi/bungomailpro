# == Schema Information
#
# Table name: users
#
#  id                           :bigint(8)        not null, primary key
#  email                        :string           not null
#  token                        :string           not null
#  crypted_password             :string
#  salt                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  magic_login_email_sent_at    :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :subscriptions, dependent: :delete_all
  has_many :courses, through: :subscriptions
  has_many :deliveries, through: :subscriptions
  has_many :own_courses, class_name: 'Course', foreign_key: :owner_id, dependent: :nullify

  attribute :token, :string, default: SecureRandom.hex(10)
end
