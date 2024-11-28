#!/bin/bash
#パスワードマネージャーを作成する
echo "パスワードマネージャーへようこそ！"
echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
read choice

file="user_information.json"
encrypted_file="user_information.json.gpg"
#暗号化・複合するためのパスフレーズファイル
passphrase="passphrase.txt"
#Add Passwordを実装
function add_password() {
	#データ格納用JSONファイルの初期化
        if [[ ! -f "$encyrypted_file" ]]; then
                echo "[]" > "$file"
		gpg --symmetric --batch --passphrase "$passphrase" --output "$encrypted_file" "$file" 2> /dev/null
		rm -f "$file"
        fi
        echo "サービス名を入力してください:"
        read service
	#サービス名の重複確認
	#データを取得できるように複合
	gpg --decrypt --batch --yes --passphrase "$passphrase" --output "$file" "$encrypted_file" 
        check_service=$(cat "$file" | jq --arg check "$service" -r '.[] | select(.service == $check) | .service')
        if [[ -n "$check_service" ]]; then
                echo "すでにそのサービス名は存在します。" >&2
		rm -f "$file"
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
	#JSONファイルを再度暗号化
	gpg --symmetric --batch --yes --passphrase "$passphrase" --output "$encrypted_file" "$file"
	rm -f "$file"
	echo -e "\nパスワードの追加は成功しました。"
}

#Get Passwordを実装
function get_password() {
	if [[ -f "$encrypted_file" ]]; then
		echo "サービス名を入力してください:"
        	read user_service
        	#サービス名の値が一致するデータの情報を取得
		#JSONファイルを複合
		gpg --decrypt --batch --yes --passphrase "$passphrase" --output "$file" "$encrypted_file"
        	user_name=$(cat "$file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .name')
        	user_password=$(cat "$file" | jq --arg service_name "$user_service" -r '.[] | select(.service == $service_name) | .password')
        	if [[ -n "$user_name" && -n "$user_password" ]]; then		
			echo "サービス名: $user_service"
        		echo "ユーザー名: $user_name"
        		echo "パスワード: $user_password"
		else
			echo -e "\nそのサービスは登録されていません。" >&2
		fi
		#複合したJSONファイルの削除
		rm -f "$file"
	else
		echo "Add Passwordの入力からお願いします。"
	fi
}

#入力処理
if [[ $choice == "Add Password" ]]; then
        add_password
elif [[ $choice == "Get Password" ]]; then
        get_password
elif [[ $choice == "Exit" ]]; then
        echo "Thank you!"
else
        echo -e "\n入力が間違えています。Add Password/Get Password/Exit から入力してください。" >&2
fi
