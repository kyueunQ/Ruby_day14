## Day 11. scaffold , form_for, 댓글, faker



### Scaffold 이해하기 + bootstrap 적용

`$ rails _5.0.6_ new daum_cafe` :  `daum_cafe`라는 프로젝트 생성하기

`$ rails g scaffold post title:string contents:text ` 



*app/controller/posts_controller.rb*

```ruby
class PostsController < ApplicationController
    
<!-- (중략) -->
        
  # GET /posts/new
  def new
    @post = Post.new
  end

<!-- (중략) -->

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
      if @post.save
        redirect_to @post, flash: {success: 'Post was successfully created.'}
      else
         render :new 
      end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
      if @post.update(post_params)
        redirect_to @post, flash: {success: 'Post was successfully updated.'}
      else
        render :edit
      end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    redirect_to posts_url, flash: {success: 'Post was successfully destroyed.'}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :contents)
    end
end
```

- ` params.require(:post).permit(:title, :contents)` : SQL injection을 방지하기 위함 => form_for를 사용하는 이유
  - `{title: params[post][title], contents: params[post][contents]}` 와 같은 의미
- `post`라는 host에서의 title, contents의 변수만을 허용함



 2. bootstrap 적용에 앞서 설정하기

    *app/assets/javascript/application.js*

``` js
아래 내용 추가하기
//= require popper
//= require bootstrap
```

*app/assets/stylesheets/application.scss*

```css
@import 'bootstrap';
```





### form_for

: SQL injection 방지를 위해 사용함

- DB에 설정한 변수 외에는 사용 불가함

- **Binding a Form to an Object** 역할

  : Form과 Object를 연결시켜주는 역할을하는 `form_for`

- `"post" -> {"title"=>"test1", "contents"=>test1"} -> "commit" => "Create Post"`  

  - `form_for`를 실행했을 때 console을 통해 위와 같이 확인할 수 있음

  - "post" 라는 호스트에서의 db에 있는 'title', 'contents'라는 컬럼에 값을 넣어 Post를 생성함을 의미함





### 댓글 + 1:n 관계 구성

- 댓글을 생성할 때
- 삭제할 때

1. db 재구성을 통해 1:n관계 구축

   

   *app/models/post.rb*

   ```ruby
   class Post < ApplicationRecord
       has_many :comments
   end
   ```

   *app/models/comment.rb*

   ```ruby
   class Comment < ApplicationRecord
       belongs_to :post
   end
   ```

   - `$ rake db:migrate`



2. controller 생성

   *app/controller/comments_controller.rb*

   ```ruby
   class CommentsController < ApplicationController
     def create
       comment = Comment.new
       comment.content = params[:content]
       comment.post_id = params[:id]
       comment.save
       
       redirect_to :back
     end
   
     def destroy
       comment = Comment.find(params[:id])
       comment.destroy
       
       redirect_to :back
     end
   end
   ```



3. views 수정하기

   *views/comments/_form.html.erb*

```ruby
<%= form_tag("/posts/#{post.id}/comments/create") do %>
    <%= text_field_tag(:content, nil, class: "form-control", placeholder: "덧글 입력") %>
    <%= submit_tag("댓글작성", class: "btn btn-info") %>
<% end %>
```

- `<%= text_field_tag(:content, nil, class: "form-control", placeholder: "덧글 입력") %> `

  : `nil`이 필요한 이유는?

  

  *views/posts/show.html.erb*

```erb
<!-- 댓글 입력 폼 조립 -->
<%= render 'comments/form', post: @post %>

<!-- 댓글 리스트-->
<table class="table">
  <thead>
    <tr>
      <th scope="col">ID</th>
      <th scope="col">내용</th>
      <th scope="col"></th>
    </tr>
  </thead>
  <tbody>
    <% @post.comments.each do |comment| %>
    <tr>
      <th scope="row"><%= comment.id %></th>
      <td><%= comment.content %></td>
      <td><%=link_to "삭제", "/comments/#{comment.id}", method: "delete" %></td>
    </tr>
    <% end %>
  </tbody>
</table>
```





### gem faker

참고 : https://github.com/stympy/faker

: seed 파일을 통해 데이터를 랜덤으로 생성함

`rake db:seed`

`rake db:reset ` : drop + migrate + seed를 한꺼번에 실행





### n : n

(참고: http://guides.rubyonrails.org/association_basics.html)

- 1명의  user는 여러 개의 cafe에 가입할 수 있으며, 1개의  cafe도 여러 명의 user을 받을 수 있음

  `$ rails g model user` `rails g model daum`

- 가운데 매개 db인 `membership`을 생성함

  `$ rails g model membership`



> * 원하는 상황 
>
> 1번 유저는 1, 2, 3번 카페에 가입했다.
>
> 2번 유저는 2, 3번 카페에 가입
>
> 3번 유저는 1, 3번 카페에 가입
>
> 
>
> 1번 카페에는 1, 3번 유저가 가입
>
> 2번 카페에는 1, 2번 유저가 가입
>
> 3번 카페에는 1, 3번 유저가 가입



```command
2.3.4 :023 > u1 = User.first
  User Load (0.2ms)  SELECT  "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
 => #<User id: 1, user_name: "ho", created_at: "2018-06-26 06:30:32", updated_at: "2018-06-26 06:30:32"> 
2.3.4 :024 > u1.daums
  Daum Load (0.2ms)  SELECT "daums".* FROM "daums" INNER JOIN "memberships" ON "daums"."id" = "memberships"."daum_id" WHERE "memberships"."user_id" = ?  [["user_id", 1]]
 => #<ActiveRecord::Associations::CollectionProxy [#<Daum id: 1, title: "haha", created_at: "2018-06-26 06:27:51", updated_at: "2018-06-26 06:27:51">, #<Daum id: 2, title: "haha2", created_at: "2018-06-26 06:28:12", updated_at: "2018-06-26 06:28:12">, #<Daum id: 3, title: "haha3", created_at: "2018-06-26 06:28:19", updated_at: "2018-06-26 06:28:19">]> 
2.3.4 :025 > u3 = User.last
  User Load (0.7ms)  SELECT  "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<User id: 3, user_name: "ho3", created_at: "2018-06-26 06:30:39", updated_at: "2018-06-26 06:30:39"> 
2.3.4 :026 > u3.daums
  Daum Load (0.2ms)  SELECT "daums".* FROM "daums" INNER JOIN "memberships" ON "daums"."id" = "memberships"."daum_id" WHERE "memberships"."user_id" = ?  [["user_id", 3]]
 => #<ActiveRecord::Associations::CollectionProxy [#<Daum id: 1, title: "haha", created_at: "2018-06-26 06:27:51", updated_at: "2018-06-26 06:27:51">, #<Daum id: 3, title: "haha3", created_at: "2018-06-26 06:28:19", updated_at: "2018-06-26 06:28:19">]>
```





> - Tip
>
> `gem "rails_db", "1.6"` : ../rails/db 접속을 통해 현재 만들어진 db와 그 안의 데이터를 확인할 수 있음
>
> (참고: https://github.com/igorkasyanchuk/rails_db)