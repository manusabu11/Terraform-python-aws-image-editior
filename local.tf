locals {
  arnbucketa       = var.bucket_list[0]
  arnbuketb        = var.bucket_list[1]
  lmbdacontent     = <<-EOT
    import json
    import boto3
    import urllib.parse
    import urllib.parse
    import io
    from PIL import Image
    s3 = boto3.resource('s3')
    s3_client = boto3.client('s3')
    def lambda_handler(event, context):
       srcb="${var.bucket_list[0]}"
       dscb="${var.bucket_list[1]}"

       current_object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
       bucket = s3.Bucket(srcb)
       image = bucket.Object(current_object_key)
       img_data = image.get().get('Body').read()
       image = Image.open(io.BytesIO(img_data))
       data = list(image.getdata())
       image_without_exif = Image.new(image.mode, image.size)
       image_without_exif.putdata(data)
       new_image_data = io.BytesIO()
       image_without_exif.save(new_image_data,'JPEG')
       new_image_data.seek(0)
       s3_client.put_object(Bucket=dscb, Key=current_object_key, Body=new_image_data)
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
