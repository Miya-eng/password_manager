#!/bin/bash
#パスワードマネージャーを作成する
echo "パスワードマネージャーへようこそ！"
echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
read choice

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
