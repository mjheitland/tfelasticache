#-- 3_compute/compute.tf ---

#------------------
#--- Data Providers
#------------------

data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    subnet = "element(data.terraform_remote_state.tf_network.outputs.aws_subnet_ids, count.index)"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  filter {
      name   = "root-device-type"
      values = ["ebs"]
    }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }  
}  


#-------------
#--- Variables
#-------------

variable "create_jumpbox" {
  description = "create a jumpbox for testing purposes in every AZ"
  type        = bool
  default     = false    
}

variable "project" {
  description = "project name is used as resource tag"
  type        = string
}

variable "key_name" {
  description = "name of keypair to access ec2 instances"
  type        = string
  default     = "MyAuroraKey"
}

variable "public_key_path" {
  description = "file path on deployment machine to public rsa key to access ec2 instances"
  type        = string
}

variable "jumpbox_instance_type" {
  description = "Instance type to use at master instance. If instance_type_replica is not set it will use the same type for replica instances"
  type        = string
}


#-------------
#--- Resources
#-------------

resource "aws_key_pair" "keypair" {
  count       = var.create_jumpbox == true ? 1 : 0
  
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "sg_jumpbox" {
  count       = var.create_jumpbox == true ? 1 : 0
  
  name        = "sg_jumpbox"
  description = "Used for access to the public instances"
  vpc_id      = module.vpc.vpc_id
  ingress { # allow ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # better to restrict to a specific ip of the box from where you are connecting to the jump box, e.g. ["54.239.6.185/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = format("%s_sg_jumpbox", var.project)
    project = var.project
  }
}

resource "aws_instance" "jumpbox" {
  count = var.create_jumpbox == true ? length(module.subnets.public_subnet_ids) : 0

  instance_type           = var.jumpbox_instance_type
  ami                     = data.aws_ami.amazon_linux_2.id # for Frankfurt Feb 2021 it would be "ami-02f9ea74050d6f812" 
  key_name                = aws_key_pair.keypair[0].id
  subnet_id               = sort(module.subnets.public_subnet_ids)[count.index]
  vpc_security_group_ids  = [ 
                              aws_security_group.sg_jumpbox[0].id,
                              module.vpc.vpc_default_security_group_id,
                              module.redis.security_group_id
                            ]
  user_data               = data.template_file.userdata.*.rendered[0]
  tags = { 
    Name = format("%s_jumpbox_%d", var.project, count.index)
    project = var.project
  }
}


#-----------
#--- Outputs
#-----------

output "keypair_id" {
  value = var.create_jumpbox == true ? join(", ", aws_key_pair.keypair.*.id) : ""
}

output "jumpbox_ids" {
  value = var.create_jumpbox == true ? join(", ", aws_instance.jumpbox.*.id) : ""
}

output "jumpbox_public_ips" {
  value = var.create_jumpbox == true ? join(", ", aws_instance.jumpbox.*.public_ip) : ""
}

output "sg_jumpbox" {
  value = var.create_jumpbox == true ? join(", ", aws_security_group.sg_jumpbox.*.id) : ""
}
