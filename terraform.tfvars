aws_region          = "us-east-1"
project_name        = "cheese-factory"
environment         = "dev"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
my_ip               = "0.0.0.0/0"
instance_type       = "t2.micro"
docker_images       = ["errm/cheese:wensleydale","errm/cheese:cheddar","errm/cheese:stilton"]
