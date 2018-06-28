class CafesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    # 전체 카페 목록 보여주기
    # -> 로그인 하지 않았을 때: 전체 카페 목록
    # -> 로그인 했을 때 : 유저가 가입한 카페 목록
    def index
        @cafes = Daum.all
    end
    
    # 카페 내용물을 보여주는 show 페이지 / 카페의 게시물 리스트 보여주기
    def show
        @cafe = Daum.find(params[:id])
        # session[:current_cafe] = @cafe.id
    end
    
    # 카페를 개설하는 페이지
    def new
        @cafe = Daum.new
    end
    
    # 카페를 실제로 개설하는 로직
    def create
        @cafe = Daum.new(daum_params)
        @cafe.master_name = current_user.user_name
        
        if @cafe.save
            Membership.create(daum_id: @cafe.id, user_id: current_user.id)
            redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
        else
            p @cafe.erros
            redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
        end
           
    end
    
    def join_cafe
        # 사용자가 가입하려는 카페
        cafe = Daum.find(params[:cafe_id])
        # 이 카페에 현
        if cafe.is_member?(current_user)
            # 가입 실패
            redirect_to :back, flash: {danger: "카페가입에 실패했습니다. 이미 가입한 기록이 있습니다."}
        else
            # 가입 성공
            Membership.create(daum_id: params[:cafe_id], user_id: current_user.id)
            redirect_to :back, flash: {success: "카페 가입에 성공했습니다."}
        end
            # 중복 가입의 문제 발생
            # 1. 가입 버튼을 안보이게 한다. (사용자 화면 조정) - model 코딩
            # 2. 중복 가입 체크 후 진행 (서버에서 조정) - Model validation
            # 현재 이 카페에 가입한 유저중에 현재 로그인한 유저
    end
    
    
    
    
    # 카페 정보를 수정하는 페이지
    def edit
    end
    
    # 카페 정보를 실제로 수정하는 로직
    # 로그인된 아이디가 master_name과 동일하지 비교함
    # -> 같은지 확인했다면, 수정가능
    # -> 다르다면 불가능함
    def update
        if Daum.find_by(master_name).eql?
            
        else
            redirect_to :back, flash: {danger: '카페지기가 아닙니다.'}
        end
    end
    

    
    private
    def daum_params
        # daum이라는 key를 필요로하며, title과 description이란 값만 받겠다.
        params.require(:daum).permit(:title, :description)
        # {"daum"=> {"title"=>"1", "description"=>"1"}}
    end 
    
end
