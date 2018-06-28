class User < ApplicationRecord
    has_secure_password
    # user_name 컬럼의 unique 속성 부여, 테이블을 바꾸는 것은 아님
    validates :user_name, uniqueness: true
    
    has_many :memberships
    has_many :daums, through: :memberships
    has_many :posts
end
