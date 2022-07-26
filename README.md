# terraform-s3www

Terraformでs3バケットをwww公開するサンプル。
s3にコンテンツも流し込む。

# 参考

- [チュートリアル: Amazon S3 での静的ウェブサイトの設定 \- Amazon Simple Storage Service](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html)
- [terraform-aws-s3-bucket/examples/complete at v3.3.0 · terraform-aws-modules/terraform-aws-s3-bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/v3.3.0/examples/complete)


# deploy

AWSアカウントは
環境変数で設定するか、
それともdefaultプロファイルをそのまま使うか
してください。

[provider "aws" の profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#profile)
などを書いてもいいです。

```bash
cp terraform.tfvars- terraform.tfvars
vim terraform.tfvars  # お好みに合わせて修正
cp main_override.tf- main_override.tf
vim main_override.tf  # backend情報などをお好みに合わせて修正
```

で

```bash
terraform init
terraform apply
```

テストは
```bash
./curl-test.sh
```
またはoutputのs3wwwurlのURLにブラウザでアクセス


# メモ

[Using Terraform for S3 Storage with MIME Type Association | State Farm Engineering](https://engineering.statefarm.com/blog/terraform-s3-upload-with-mime/) にしたがって
ディレクトリまるごとfor_eachとmimeでs3にあげるようにした。
`terraform state list` でどんな感じかわかると思う。
