# S3 Glacierというリソースは存在しない

S3は以下のような種類があるとされている。

- S3 Standard
- S3 Standard-IA
- S3 Intelligent-Tiering
- S3 One Zone-IA
- S3 Glacier Flexible Retrieval
- S3 Glacier Instant Retrieval
- S3 Glacier Deep Archive

しかし、リソースとしてはS3だけが存在する。  
Glacierのリソースを作って、そっちに移すような処理を書かなくても勝手にAWSの監視エージェントがS3のストレージクラスを変えてくれる。

## 期限

![期限](./s3.drawio.svg)

### [Deep Archiveの制約](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html)

Deep Archiveには90日以降にしか移行できないという制約がある。

```console
$ terraform apply
（省略）
│ Error: updating S3 Bucket (structured-log-bucket) Lifecycle Configuration
│ 
│   with aws_s3_bucket_lifecycle_configuration.log_lifecycle,
│   on storage.tf line 40, in resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle":
│   40: resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
│ 
│ operation error S3: PutBucketLifecycleConfiguration, https response error StatusCode: 400, RequestID: ***, HostID: ***,
| api error InvalidArgument: 'Days' in the 'Transition' action
│ for StorageClass 'DEEP_ARCHIVE' for filter '(prefix=)' must be 90 days more than 'filter '(prefix=)'' in the 'Transition' action for
│ StorageClass 'GLACIER'
```
