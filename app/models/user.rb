class User < ApplicationRecord
    has_many :memberships
    has_many :daums, through: :memberships
end
