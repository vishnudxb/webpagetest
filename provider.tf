# Configure the AWS Provider
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "eu-west-1"
}

#Creating the VPC
resource "aws_vpc" "main" {
    cidr_block = "10.22.0.0/16"
    tags {
        Name = "webpagetest-vpc"
    }
}

#Creating Gateway and adding it to the VPC
resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.main.id}"
}

#Creating Subnets
resource "aws_subnet" "eu-west-1a" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.22.0.0/24"
    availability_zone = "eu-west-1a"

    tags {
        Name = "webpagetest-subnet-1a"
    }
}

resource "aws_subnet" "eu-west-1b" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.22.1.0/24"
    availability_zone = "eu-west-1b"

    tags {
        Name = "webpagetest-subnet-1b"
    }
}

#Creating Route table
resource "aws_route_table" "eu-west-a" {
	vpc_id = "${aws_vpc.main.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}
}


resource "aws_route_table_association" "eu-west-a" {
	subnet_id = "${aws_subnet.eu-west-1a.id}"
	route_table_id = "${aws_route_table.eu-west-a.id}"
}

resource "aws_route_table_association" "eu-west-b" {
	subnet_id = "${aws_subnet.eu-west-1b.id}"
	route_table_id = "${aws_route_table.eu-west-a.id}"
}


#Create security group
resource "aws_security_group" "webtestssh" {
  name = "webtestssh"
    description = "Allow all ssh traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webtesthttp" {
  name = "webtesthttp"
    description = "Allow all http traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create User data file with variables
resource "template_file" "userdata" {
    filename = "userdata.tpl"

    vars {
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
        archive_s3_key = "${var.access_key}"
        archive_s3_secret = "${var.secret_key}"
    }
}


# Create a new instance with ami-03715d51 on t2.micro with an AWS Tag "webtest"
resource "aws_instance" "web" {
    ami = "ami-9978f6ee"
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"
    key_name  = "${var.key_name}"
    subnet_id = "${aws_subnet.eu-west-1a.id}"
    security_groups = [ "${aws_security_group.webtestssh.id}", "${aws_security_group.webtesthttp.id}" ] 
    user_data = "${template_file.userdata.rendered}"
    tags {
        Name = "webtest"
    }
    connection {
        user = "ubuntu"
        key_file = "${var.key_file}"
    }
}

resource "aws_eip" "lb" {
    instance = "${aws_instance.web.id}"
    vpc = true
}

# This is used to save the test results on AWS S3.
resource "aws_s3_bucket" "b" {
    bucket = "webpagetest"
    acl = "private"

    tags {
        Name = "My webpagetest bucket"
    }
}
