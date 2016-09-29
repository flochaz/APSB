module "stack" {
  source = "github.com/segmentio/stack"
  environment = "dev"
  key_name = "apsb"
  name = "apsb"
  region = "us-east-1"
  availability_zones = "us-east-1b"
  ecs_instance_type = "t2.micro"
  ecs_min_size = "1"
  ecs_max_size = "1"
  ecs_desired_capacity = "1"
  ecs_root_volume_size = "8"
  ecs_docker_volume_size = "8"
  ecs_instance_ebs_optimized = "false"
  internal_subnets = "10.30.0.0/19"
  external_subnets = "10.30.32.0/20"
}

module "wordpress" {
  source             = "github.com/segmentio/stack//web-service"
  image              = "minusetcortex/apsb"
  version            = "devel"
  port               = 80
  container_port     = 80
  ssl_certificate_id = "TBD"
  environment      = "${module.stack.environment}"
  cluster          = "${module.stack.cluster}"
  iam_role         = "${module.stack.iam_role}"
  security_groups  = "${module.stack.external_elb}"
  subnet_ids       = "${module.stack.external_subnets}"
  log_bucket       = "${module.stack.log_bucket_id}"
  internal_zone_id = "${module.stack.zone_id}"
  external_zone_id = "${module.domain.zone_id}"

  env_vars = <<EOF
[
  { "name": "DB_HOST", "value": "TBD" },
  { "name": "DB_PASS", "value": "TBD" },
  { "name": "DB_USER", "value": "TBD"},
  { "name": "ADMIN_EMAIL", "value": "florianchazal@gmail.com" },
  {"name": "DB_NAME", "value": "wordpress" },
  {"name": "PLUGINS", "value": "akismet,contact-form-7,login-form-recaptcha,ml-slider,paypal-donations,really-simple-captcha,tac,tinymce-advanced,feed-them-social" },
  { "name": "THEMES", "value": "pinboard" }
]
EOF
}

module "domain" {
  source = "github.com/segmentio/stack//dns"
  name   = "assoc-psb.org"
}