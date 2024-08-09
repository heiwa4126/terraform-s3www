# terraform-s3www

Terraform で s3 バケットを www 公開するサンプル。
s3 にコンテンツも流し込む。

**目次**

- [更新 (2024-08)](#更新-2024-08)
- [参考](#参考)
- [deploy](#deploy)
- [メモ](#メモ)

## 更新 (2024-08)

[事前のお知らせ: 2023 年 4 月より、Amazon S3 で、すべての新しいバケットに対して自動的に S3 パブリックアクセスブロックが有効化、アクセスコントロールリストが無効化](https://aws.amazon.com/jp/about-aws/whats-new/2022/12/amazon-s3-automatically-enable-block-public-access-disable-access-control-lists-buckets-april-2023/)
に対応しました。

要は
「aws_s3_bucket_policy より前に aws_s3_bucket_public_access_block で
`block_public_policy = false` を設定する(S3 パブリックアクセスブロックがデフォルトで有効化だから)」
のように変更。

## 参考

- [チュートリアル: Amazon S3 での静的ウェブサイトの設定 \- Amazon Simple Storage Service](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html)
- [terraform-aws-s3-bucket/examples/complete at v3.3.0 · terraform-aws-modules/terraform-aws-s3-bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/v3.3.0/examples/complete)

## deploy

AWS アカウントは
環境変数で設定するか、
それとも default プロファイルをそのまま使うか
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
terraform init --upgrade
terraform apply
```

テストは

```bash
./curl-test.sh
```

または output の s3wwwurl の URL にブラウザでアクセス

## メモ

[Using Terraform for S3 Storage with MIME Type Association | State Farm Engineering](https://engineering.statefarm.com/blog/terraform-s3-upload-with-mime/) にしたがって
ディレクトリまるごと for_each と mime で s3 にあげるようにした。
`terraform state list` でどんな感じかわかると思う。
