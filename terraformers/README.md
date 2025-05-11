# terraformers

AWSのアカウントにterraformを実行する権限グループを作成する。  
PowerUserAccessは便利だが、stg・prd環境で付与するのは危険である。  
そのため、そのプロジェクトで使用する権限をまとめたグループを作成する。  
Admin権限を持つユーザーが、任意のIAMユーザーをこのグループに所属させる。

> terraformerという名前にしているが、プロジェクトであれば以下のような役職名を採用しても良い。
>
> - developer...開発担当
> - releaser ...リリース担当
> - operator ...運用担当者

## terraformの実行方法

### terraformの初期化

ここでは以下の操作が行われる。

- `provider`のダウンロードが行われる。  
  `.terraform`ディレクトリに`provider aws`などで指定したクラウドサービスとの接続モジュールがダウンロードされる。
- バックエンドの初期化  
  `tfstate`という状態ファイルをどこに置くのかを定義したバックエンドを初期化

このコマンドに成功した場合、`terraform plan`や`terraform apply`などのコマンドが実行可能になる。

#### S3に構成管理ファイルを配置する場合

S3の設定を投入する。

```console
$ export TF_BACKEND_BUCKET = <your-bucket-name>
$ envsubst < backend.template > backend.hcl
```

```console
$ terraform init -backend-config=backend.hcl
Terraform has been successfully initialized!
```

#### ローカルストレージに構成管理ファイルを配置する場合

S3へアップロードする設定を削除する。

```console
$ :> backend.tf
```

```console
$ terraform init
Terraform has been successfully initialized!
```

### terraformのdry run

tfstateファイルを参照して、リソースの生成・変更・削除の結果予想を行う。

```console
$ terraform plan
（省略）
Plan: 3 to add, 0 to change, 0 to destroy.
```

3つのリソースが生み出されることが分かる。

### リソースの生成

tfstateファイルを参照して、リソースの生成・変更・削除を実行する。

```console
$ terraform apply
（省略）
Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
aws_iam_group.terraformers: Creating...
aws_iam_policy.terraformer_policy: Creating...
aws_iam_group.terraformers: Creation complete after 1s [id=terraformers]
aws_iam_policy.terraformer_policy: Creation complete after 1s [id=arn:aws:iam::795921005424:policy/TerraformerPolicy]
aws_iam_group_policy_attachment.terraformers_attach_policy: Creating...
aws_iam_group_policy_attachment.terraformers_attach_policy: Creation complete after 1s [id=terraformers-20250511134933594200000001]
```

CI/CDなどで自動化したい場合

```console
$ terraform apply -auto-approve
（省略）
```

### リソースの削除

```console
$ terraform destroy
（省略）
Plan: 0 to add, 0 to change, 3 to destroy.

aws_iam_group_policy_attachment.terraformers_attach_policy: Destroying... 

Destroy complete! Resources: 3 destroyed.
```

## terraformの状態ファイル

### backendを設定しない場合

backendを設定しない場合、ローカルに構成管理ファイルが配置される。

```bash
terraformers/
├ .terraform/ # terraform initで生成されるプロバイダ設定
| └ .terraform/
|   └ providers/
|     └ registry.terraform.io/
|       └ hashicorp/
|         └ aws/
|           └ 5.97.0/
|             └ linux_amd64
|               ├ terraform-provider-aws_v5.97.0_x5*
|               └ LICENSE.txt
├ .terraform.lock.hcl # プロバイダのロックファイル
├ terraform.tfstate   # 今のAWSリソースの状態管理ファイル
├ （省略）
└ README.md
```

### backendを設定する場合

backendとしてS3を設定するとS3へアップロードされる。  
チームで共有する場合は、こちらの手段を取る必要がある。
