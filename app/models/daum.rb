class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
    has_many :posts
    
    def is_member?(user) # 'user'라는 매개변수 넘겨주기
        self.users.include?(user)
    end
end
