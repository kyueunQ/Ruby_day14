# Day 14. 모델코딩 + 이미지 업로드 기능



### 모델코딩 (인스턴스 메서드 만들기)

- 모델코딩 (인스턴스 메서드 만들기)
- 모델코딩(user_name에 중복 불허 속성 두기)



```
daum = Daum.find(2)   --> class.method
daum.title.each do    --> instance method

def self.메소드명 --> class method
	로직안에서 self를 쓸 수 없음
end

def 메소드명
	로직 안에서 self를 쓸 수 있음
	이 self == 현재 자신 객체
end
```



*models/daum.rb*

```
    def is_member?(user) # 'user'라는 매개변수 넘겨주기
        self.users.include?(user)
    end
```

- Daum 클래스로 만들어긴 객체에 붙여서 사용한다면, 어느 controller에서든 사용 가능





### rails Validate

참고 자료: http://guides.rubyonrails.org/active_record_validations.html



*models/user.rb*

```ruby
class User < ApplicationRecord
    has_secure_password
    # user_name 컬럼의 unique 속성 부여, 테이블을 바꾸는 것은 아님
    validates :user_name, uniqueness: true 
   ....
end
```

- user_name은 unique해야한다는 속성을 검증해줌

  

> p @user.errors : model에서 디버깅할 때 사용함





## 2. 이미지 업로드하기

### CarrierWave 

:  way to upload files from Ruby applications 



`gem 'carrierwave'`   ← `Gemfile`에 추가

`$ rails g uploader Image` : ImagerUploader가 생성됨



*app/db/migrate/..._create_posts.rb*

```ruby
t.string :image_path
```

- 이미지 주소를 받아줄 변수 설정



*app/models/post.rb*

```ruby
mount_uploader :image_path, ImageUploader
# 만약 파일을 첨부하는 기능을 추가하고 싶아면, 새로운 Uploader을 만들어야 함
mount_uploader :file_path, FileUploader
```

- `image_path`라는 변수로` ImageUploader`로 연결함

  

*app/uploaders/image_uploader.rb*

```ruby
class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
    # 사진 사이즈를 조절하는 기능
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
    # aws와의 연결을 위해 사용
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
    # 아래와 같은 경로로 파일이 저장됨
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Create different versions of your uploaded files:
    # Adding versions 부분
  version :thumb_fit do
    process resize_to_fit: [250, 250]
  end

  version :thumb_fill do
    process resize_to_fill: [250, 250]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
    # 아래에 기재된 파일 형식만이 저장될 수 있음
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
    # 파일 이름이 자동으로 아래와 같이 저장됨
  def filename
    "something.jpg" if original_filename
  end
end

```

- 위와 같이 필요한 부분들의 주석을 풀어 사용함



#### Adding versions 

: to add different versions of the same file

`gem 'mini_magick' `    ← `Gemfile`에 추가

`$ sudo apt-get update`  

`$ sudo apt-get install -y imagemagick`   

(MacOS : `$ brew install imagemagick` , Centos : `$ yum install imagemagick` )



*app/uploaders/image_uploader.rb* 의 일부 

```ruby
  version :thumb_fit do
    process resize_to_fit: [250, 250]
  end

  version :thumb_fill do
    process resize_to_fill: [250, 250]
  end
```

- resize_to_fit와 resize_to_fill의 차이점
  - **resize_to_fit**:  be scaled to be no larger than 250 by 250 pixels + ratio will be kept + 가운데를 중심으로, 그외에 사이즈에 벗어나는 부분은 모두 삭제하여 보여줌
  - **resize_to_fill**: be scaled to exactly 250 by 250 pixels



#### AWS

- 내 보안 작업 증명 --> 사용자 추가( *'프로그래밍 방식' 체크*) --> 그룹 추가(*Amazons3Fullaccess' 선택*) 
- 생성된 그룹을 클릭,  *''그룹에 사용자 추가"* --> 앞서 만든 사용자를 추가함

- `S3` 에서 버킷만들기 --> 기본값으로 진행, 3단계 권한 설정에서 ''이 버킷에 퍼블릭 읽기 액세스 권한을 부여함' 클릭  -->  aws S3 저장소 만들기 완료 



#### Figaro

: `ENV` 와 a single YAML file을 통해, 환경변수 설정을 용이하게 함

`gem "figaro"`  ← `Gemfile`에 추가

`$ bundle exec figaro install`  아래와 같은 결과 발생

```ruby
kyueun:~/daum_cafe (master) $ bundle exec figaro install
      create  config/application.yml
	# commit을 해도 해당 파일들은 git에 올라가지 않음
      append  .gitignore
```

- `$ vi .gitignore`을 통해 commit이 안되는 항목들을 볼 수 있음



*config/application.yml*

```ruby
# 개발 환경에서만 사용함을 뜻함
development:
	# key : value 값
    KEY_ID: #값 입력
    SECRET_KEY: # 값 입력
```



#### Fog

: aws S3와 연결시켜 주기 위해 사용

`gem "fog-aws"`  ← `Gemfile`에 추가



*config/initalizers/fog.rb*  파일 생성 : *initalizers* → 처음 서버를 동작시킬 때만 한 번씩 실행됨

```ruby
puts ENV["AWS_ACCESS_KEY_ID"]
CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'                        
  config.fog_credentials = {
    provider:              'AWS',                       
    aws_access_key_id:     ENV["KEY_ID"],    
    aws_secret_access_key: ENV["SECRET_KEY"], 
    region:                'ap-northeast-2',                 
   # host:                  's3.example.com',            
    endpoint:              'https://s3.ap-northeast-2.amazonaws.com' 
  }
  config.fog_directory  = ENV["BUCKET_NAME"]         
end
```

- `ENV["KEY_ID"]`, `ENV["SECRET_KEY"]`, `ENV["BUCKET_NAME"]` 위에서 설정한 key 값의 value를 가져옴
- https://docs.aws.amazon.com/ko_kr/general/latest/gr/rande.html  / 'Endpoint' 참조해서 region과 endpoint 채워 넣기





> Error
>
> - parameter 값 제대로 넘기기
>   - session[:current_cafe]  = @cafe.id  => session 값으로 



> 참고자료
>
> - https://github.com/carrierwaveuploader/carrierwave
> - https://docs.aws.amazon.com/ko_kr/general/latest/gr/rande.html 
> - http://guides.rubyonrails.org/active_record_validations.html

