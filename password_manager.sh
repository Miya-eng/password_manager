#!/bin/bash
#パスワードマネージャーを作成する
echo "パスワードマネージャーへようこそ！"
echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
read choice

#Add Passwordを実装
function add_password() {
        echo "サービス名を入力してください:"
        read service
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
        #JSONファイルの初期化
        file="user_information.json"
        if [[ ! -f "$file" ]]; then
                echo "[]" > "$file"
        fi
        #JSONファイルにデータを格納
        data=$(jq ". += [$info]" "$file")
        echo "$data" > "$file"
        #JSONファイルを整形
        #jq '.' "$file"
}

#Get Passwordを実装
function get_password() {
        echo "サービス名を入力してください:"
        read user_service
        #サービス名の値が一致するデータの情報を取得
        json_file="user_information.json"
        user_name=$(cat "$json_file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .name')
        user_password=$(cat "$json_file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .password')
        echo "サービス名: $user_service"
        echo "ユーザー名: $user_name"
        echo "パスワード: $user_password"
}

#入力処理
if [[ $choice == "Add Password" ]]; then
        add_password
elif [[ $choice == "Get Password" ]]; then
        get_password
elif [[ $choice == "Exit" ]]; then
        echo "Thank you!"
else
        echo "入力に誤りがあります。再度選択肢から入力してください。"
fi
