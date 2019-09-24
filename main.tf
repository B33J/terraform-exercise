provider "aws" {
  profile    = var.provider_profile
  region     = var.region
}

data "archive_file" "zip_js" {
  type        = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}

resource "aws_cloudfront_origin_access_identity" "r2g_oai" {
  comment = "r2g origin access identity"
}

resource "aws_s3_bucket" "r2g_exam_bucket" {
	depends_on	= ["aws_cloudfront_origin_access_identity.r2g_oai"]
	bucket	= var.bucket
		# 2nd bullet under "S3 Bucket" below
	acl		= "private"
		# 3rd bullet under "S3 Bucket" below
	policy = <<POLICY
{
	"Version": "2008-10-17",
	"Id": "r2gOAIpolicy",
	"Statement": [
		{
			"Sid": "1",
			"Effect": "Allow",
			"Principal": {"AWS": "${aws_cloudfront_origin_access_identity.r2g_oai.iam_arn}"},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${var.bucket}/*"
		}
	]
}
POLICY
/*
	tags = {
		Name        = "My bucket"
		Environment = "EXAM"
		Extra		= "Hello I am bucket plzd 2 meet u"
	}
*/
}

#	1st bullet under "S3 Bucket" below
#	THIS BELOW TO ACTUALLY UPLOAD THE ENTIRE StaticSite DIRECTORY TO S3.
resource "null_resource" "upload_to_s3" {
	depends_on	= ["aws_s3_bucket.r2g_exam_bucket"]
	provisioner "local-exec" {
	# 4th bullet under "S3 Bucket" below
		command = "aws s3 sync ${var.work_dir}\\. s3://${var.bucket} --metadata-directive REPLACE --cache-control max-age=300  --profile ${var.provider_profile}"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
	name = "iam_for_lambda"

	assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
	{
	"Action": "sts:AssumeRole",
	"Principal": {
		"Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
	},
	"Effect": "Allow",
	"Sid": "123"
	}
]
}
EOF
}

resource "aws_iam_policy_attachment" "test_attach" {
	depends_on	= ["aws_iam_role.iam_for_lambda"]
	name = "LambdaExecPolicy"
	roles = ["${aws_iam_role.iam_for_lambda.id}"]
	policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_redirect" {
	depends_on		= ["data.archive_file.zip_js"]
	filename		= "index.zip"
	function_name	= "lambda_redirect_to_index"
	role			= "${aws_iam_role.iam_for_lambda.arn}"
	handler			= "index.handler"
	runtime			= "nodejs10.x"
	publish			= true
}
data "aws_acm_certificate" "b33j_com_cert" {
	domain	= "www.b33j.com"
}

resource "aws_cloudfront_distribution" "r2g_exam_distribution" {
	depends_on	= ["aws_s3_bucket.r2g_exam_bucket", "aws_cloudfront_origin_access_identity.r2g_oai", "aws_lambda_function.lambda_redirect"]
	origin {
		domain_name	= "${aws_s3_bucket.r2g_exam_bucket.bucket_domain_name}"
		# 1st bullet under "Cloudfront"
		origin_id	= var.r2g-origin-id
		
		s3_origin_config {
			origin_access_identity = "${aws_cloudfront_origin_access_identity.r2g_oai.cloudfront_access_identity_path}"
		}
	}
	aliases	= ["${var.bucket}"]
	default_cache_behavior {
		allowed_methods	= ["GET", "HEAD"]
		cached_methods	= ["GET", "HEAD"]
		target_origin_id	= var.r2g-origin-id
	
		forwarded_values {
			query_string	= false
			cookies {
				forward	= "none"
			}
		}
	
		viewer_protocol_policy = "allow-all"
		min_ttl		= 0
		default_ttl	= 300
		max_ttl		= 86400
		
		lambda_function_association {
			event_type		= "viewer-request"
			lambda_arn		= "${aws_lambda_function.lambda_redirect.qualified_arn}"
			include_body	= false
		}
	}
	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}
	viewer_certificate {
		acm_certificate_arn = "${data.aws_acm_certificate.b33j_com_cert.arn}"
		ssl_support_method = "sni-only"
		minimum_protocol_version = "TLSv1.1_2016"
	}
	
	enabled	= true
	is_ipv6_enabled	= true
	comment	= "r2g terraform exam"
	default_root_object = "index.html"
	
	price_class	= "PriceClass_100"
}
data "aws_route53_zone" "main_domain" {
	name	= "${var.root_domain}"
}
resource "aws_route53_record" "r2g_domain_record" {
	depends_on	= ["aws_cloudfront_distribution.r2g_exam_distribution"]
	zone_id = "${data.aws_route53_zone.main_domain.zone_id}"
	name    = "r2g.${data.aws_route53_zone.main_domain.name}"
	type    = "A"
	
	alias {
		name	= "${aws_cloudfront_distribution.r2g_exam_distribution.domain_name}"
		zone_id	= "${aws_cloudfront_distribution.r2g_exam_distribution.hosted_zone_id}"
		evaluate_target_health	= false
	}
}




