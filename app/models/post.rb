class Post < ApplicationRecord
    mount_uploader :image_path, ImageUploader
    
    has_many :comments
    belongs_to :user
    belongs_to :daum
end
