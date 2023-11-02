require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "正常系" do
      let(:params) { attributes_for(:user) }
      # let(:params) do
      #   { user: attributes_for(:user) }
      # end
      it "新規登録でレコードが作成される" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["data"]["name"]).to eq params[:name]
        expect(res["data"]["email"]).to eq params[:email]
        expect(response).to have_http_status(:ok)
      end

      it "responseヘッダーにトークン情報が存在する" do
        subject
        expect(response.headers).to include("access-token")
        expect(response.headers).to include("authorization")
        expect(response.headers).to include("client")
        expect(response.headers).to include("expiry")
        expect(response.headers).to include("uid")
        expect(response.headers).to include("token-type")
      end
    end

    context "異常系:名前" do
      let(:params) { attributes_for(:user, name: nil) }
      before { create(:user, name: "foo") }

      it "名前が未設定" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("name")
        expect(res["errors"]["full_messages"]).to include("Nameを入力してください")
      end
    end

    context "異常系:メールアドレス" do
      let(:params) { attributes_for(:user, email: nil) }
      it "メールアドレスが未設定" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("email")
        expect(res["errors"]["full_messages"]).to include("Emailを入力してください")
      end
    end

    context "異常系:パスワード" do
      let(:params) { attributes_for(:user, password: nil) }
      it "パスワードが未設定" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("password")
        expect(res["errors"]["full_messages"]).to include("Passwordを入力してください")
      end
    end

    context "異常系:名前" do
      let(:params) { attributes_for(:user, name: "foo") }
      before { create(:user, name: "foo") }

      it "名前が同じ" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("name")
        expect(res["errors"]["full_messages"]).to include("Nameはすでに存在します")
      end
    end

    context "異常系:メールアドレス" do
      let(:params) { attributes_for(:user, email: "foo@mail.com") }
      before { create(:user, email: "foo@mail.com") }

      it "メールアドレスが同じ" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("email")
        expect(res["errors"]["full_messages"]).to include("Emailはすでに存在します")
      end
    end

    context "異常系:パスワード" do
      let(:params) { attributes_for(:user, password: "foo") }
      it "パスワードが6文字以下" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("password")
        expect(res["errors"]["full_messages"]).to include("Passwordは6文字以上で入力してください")
      end
    end
  end

  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    before { create(:user, email: "test123@mail.com", password: "test123") }

    context "正常系" do
      let(:params) { attributes_for(:user, email: "test123@mail.com", password: "test123") }
      it "ログインできる" do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.headers).to include("access-token")
        expect(response.headers).to include("authorization")
        expect(response.headers).to include("client")
        expect(response.headers).to include("expiry")
        expect(response.headers).to include("uid")
        expect(response.headers).to include("token-type")
      end
    end

    context "異常系:メールアドレスが存在しない" do
      let(:params) { attributes_for(:user, email: "test@mail.com", password: "test123") }
      it "ログインできない" do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(response.headers["access-token"]).to be_blank
        expect(response.headers["authorization"]).to be_blank
        expect(response.headers["client"]).to be_blank
        expect(response.headers["expiry"]).to be_blank
        expect(response.headers["uid"]).to be_blank
        expect(response.headers["token-type"]).to be_blank
      end
    end

    context "異常系：不正パスワード" do
      let(:params) { attributes_for(:user, email: "test123@mail.com", password: "test456") }
      it "ログインできない" do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(response.headers["access-token"]).to be_blank
        expect(response.headers["authorization"]).to be_blank
        expect(response.headers["client"]).to be_blank
        expect(response.headers["expiry"]).to be_blank
        expect(response.headers["uid"]).to be_blank
        expect(response.headers["token-type"]).to be_blank
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, params: headers) }

    context "正常系" do
      let(:user_id) { user.id }
      let(:user) { create(:user) }
      let(:headers) { user.create_new_auth_token }  # 認証トークンを作成
      it "ログアウト成功" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_truthy
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, params: headers) }

    context "異常系" do
      let(:user_id) { user.id }
      let(:user) { create(:user) }
      let(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }
      it "ヘッダー情報が誤っており、ログアウト失敗" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to include("ユーザーが見つからないか、ログインしていません。")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
