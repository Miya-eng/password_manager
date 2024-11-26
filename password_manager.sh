#!/bin/bash
#パスワードマネージャーを作成する
echo "パスワードマネージャーへようこそ！"
echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
read choice

#Add Passwordを実装
function add_password() {
	#データ格納用JSONファイルの初期化
        file="user_information.json"
        if [[ ! -f "$file" ]]; then
                echo "[]" > "$file"
        fi
        echo "サービス名を入力してください:"
        read service
	#サービス名の重複確認
        check_service=$(cat user_information.json | jq --arg check "$service" -r '.[] | select(.service == $check) | .service')
        if [[ -n "$check_service" ]]; then
                echo "すでにそのサービス名は存在します。" >&2
                return 1
        fi
        echo "ユーザー名を入力してください:"
        read name
        echo "パスワードを入力してください:"
        read password

        #JSONデータを変数に格納
        info=$(cat << EOF
{
"service":"$service",
"name":"$name",
"password":"$password"
}
EOF
)
        #JSONファイルにデータを格納
        data=$(jq ". += [$info]" "$file")
        echo "$data" > "$file"
}

#Get Passwordを実装
function get_password() {
        echo "サービス名を入力してください:"
        read user_service
        #サービス名の値が一致するデータの情報を取得
        json_file="user_information.json"
        user_name=$(cat "$json_file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .name')
        user_password=$(cat "$json_file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .password')
        if [[ -n "$user_name" && -n "$user_password" ]]; then		
		echo "サービス名: $user_service"
        	echo "ユーザー名: $user_name"
        	echo "パスワード: $user_password"
	else
		echo -e "\nそのサービスは登録されていません。" >&2
	fi
}

#入力処理
if [[ $choice == "Add Password" ]]; then
        add_password
	echo -e "\nパスワードの追加は成功しました。"
elif [[ $choice == "Get Password" ]]; then
        get_password
elif [[ $choice == "Exit" ]]; then
        echo "Thank you!"
else
        echo -e "\n入力が間違えています。Add Password/Get Password/Exit から入力してください。" >&2
fi
