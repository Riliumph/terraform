# terraform

terraformでAWSにインフラを立ち上げる遊び場

## awsのアクセスキーについて

【IAM】-【ユーザー】からユーザー一覧を表示する。  
ユーザー一覧から任意のユーザーを選択する。  
【セキュリティ認証情報】タブから【アクセスキーを作成】を選択する。

> 企業の場合`AWS IAM Identify Center（旧SSO）`を使うべきである

## 権限を付与する

AWSにterraformの実行を許可するユーザーグループを作成する必要がある。  
`terraformers`を実行すること。
