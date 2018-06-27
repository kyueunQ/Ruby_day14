# Day 13



## 오늘 새롭게 사용한 gem

### bcrypt

참고자료: https://gist.github.com/thebucknerlife/10090014

`gem 'bcrypt', '~> 3.1.7`



1. AuthenticateController 작성
2. ApplicationController에서 유저와 관련된 메소드 작성
3. CafesController에서 카페와 관련된 메소드 작성
4. 각 조건에 맞춰서 로직 수정



```
<%= form_for(@user) do |f| %>

<% end %>
```

- 빈껍데기면 create와 routes 맞춰주
- 같은 이름으로 명시를 해두어서 굳이 적어주지 않아도 됨



find_by와 where의 차이점



<h1>카페 개설하기</h1>
<%= form_for(@cafe) do |f| %>



cafe와 관련된 것들이 담김



### 로그인 상태로 카페 개설하기



*cafes_controller*

```ruby
    # 카페를 실제로 개설하는 로직
    def create
        @cafe = Daum.new(daum_params)
        @cafe.master_name = current_user.user_name
        if @cafe.save
            redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
        else
            redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
        end
           
    end
```

- `rake routes`를 통해 보면 `cafe GET  /cafes/:id(.:format)  cafes#show` 이렇게 uri와 action이 연결된 것을 확인할 수 있음
- `/cafes/:id`에서 `:id => @cafe` 가 매개변수로, @cafe.id 값이 자동으로 들어감





### 한명

```
class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :contents
      t.integer :user_id
      t.integer :daum_id

      t.timestamps
    end
  end
end
```

- user_id, daum_id



*models/post.rb*

```
class Post < ApplicationRecord
    has_many :comments
    belongs_to :user
    belongs_to :daum
end
```

*models/user.rb*

```

```





*models/daum.rb*















> template missing error : 연결은 성공적이나, view파일 없을 때 발생함