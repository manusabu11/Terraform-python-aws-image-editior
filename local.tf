locals {
  arnbucketa       = var.bucket_list[0]
  arnbuketb        = var.bucket_list[1]
  lmbdacontent     = <<-EOT
    import json
    import boto3
    import urllib.parse
    from PIL import Image
    s3 = boto3.resource('s3')
    s3_client = boto3.client('s3')
    def lambda_handler(event, context):
       srcb="${var.bucket_list[0]}"
       dscb="${var.bucket_list[1]}"
    
       current_object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
       exif_op="exif" + current_object_key
       copy_source = {
        'Bucket':  srcb,
        'Key': current_object_key
       }
       s3.meta.client.copy(copy_source, srcb, exif_op)
     
       copy_source1 = {
         'Bucket': srcb,
         'Key': exif_op
       }
       s3.meta.client.copy(copy_source1, dscb, current_object_key)
EOT
  bucketreadpolicy = <<-EOT
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
                   ],
            "Resource": "${aws_s3_bucket.bucket_list[local.arnbuketb].arn}"
        }
      ]
     }
EOT
  bucketredwrite   = <<-EOT
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
                 ],
            "Resource": "${aws_s3_bucket.bucket_list[local.arnbucketa].arn}"
          }
       ]
    }

EOT
  lamdarolepolicy  = <<-EOT
    {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Action": "sts:AssumeRole",
               "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
             
           }
         ]
     }
EOT
  lambdas3policy   = <<-EOT
    {
       "Version": "2012-10-17",
       "Statement": [
          {
             "Effect": "Allow",
             "Action": [
                  "s3:*",
                  "s3-object-lambda:*"
             ],
             "Resource": ["${aws_s3_bucket.bucket_list[local.arnbuketb].arn}/*","${aws_s3_bucket.bucket_list[local.arnbuketb].arn}","${aws_s3_bucket.bucket_list[local.arnbucketa].arn}/*","${aws_s3_bucket.bucket_list[local.arnbucketa].arn}"]
          }
        ]
     }
EOT 
}
