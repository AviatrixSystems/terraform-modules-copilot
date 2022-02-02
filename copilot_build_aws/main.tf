resource "aws_vpc" "copilot_vpc" {
  count = var.use_existing_vpc == false ? 1 : 0
  cidr_block = var.vpc_cidr
  tags = {
    Name = "copilot_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  count = var.use_existing_vpc == false ? 1 : 0
  vpc_id = aws_vpc.copilot_vpc[0].id
  tags = {
    Name = "copilot_igw"
  }
}

resource "aws_route_table" "public" {
  count = var.use_existing_vpc == false ? 1 : 0
  vpc_id = aws_vpc.copilot_vpc[0].id
  tags = {
    Name = "copilot_rt"
  }
}

resource "aws_route" "public_internet_gateway" {
  count = var.use_existing_vpc == false ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  timeouts {
    create = "5m"
  }
}

resource "aws_subnet" "copilot_subnet" {
  count = var.use_existing_vpc == false ? 1 : 0
  vpc_id     = aws_vpc.copilot_vpc[0].id
  cidr_block = var.subnet_cidr
  tags = {
    Name = "copilot_subnet"
  }
}

resource "aws_route_table_association" "rta" {
  count = var.use_existing_vpc == false ? 1 : 0
  subnet_id      = aws_subnet.copilot_subnet[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "tls_private_key" "key_pair_material" {
  count     = var.use_existing_keypair == false ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "copilot_key_pair" {
  count      = var.use_existing_keypair == false ? 1 : 0
  key_name   = var.keypair
  public_key = tls_private_key.key_pair_material[0].public_key_openssh
}

resource "aws_security_group" "AviatrixCopilotSecurityGroup" {
  name        = "${local.name_prefix}AviatrixCopilotSecurityGroup"
  description = "Aviatrix - Copilot Security Group"
  vpc_id      = var.use_existing_vpc == false ? aws_vpc.copilot_vpc[0].id : var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      description      = ingress.key
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = ingress.value["cidrs"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  }
  egress = [
    {
      description      = "All out traffic allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}AviatrixCopilotSecurityGroup"
  })
}

resource aws_eip copilot_eip {
  vpc  = true
  tags = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.aviatrixcopilot.id
  allocation_id = aws_eip.copilot_eip.id
}

resource "aws_network_interface" "eni-copilot" {
  subnet_id       = var.use_existing_vpc == false ? aws_subnet.copilot_subnet[0].id : var.subnet_id
  security_groups = [aws_security_group.AviatrixCopilotSecurityGroup.id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}Aviatrix Copilot interface"
  })
}

resource "aws_instance" "aviatrixcopilot" {
  ami           = local.ami_id
  instance_type = var.instance_type
  key_name      = var.keypair

  network_interface {
    network_interface_id = aws_network_interface.eni-copilot.id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(local.common_tags, {
    Name = var.copilot_name != "" ? var.copilot_name: "${local.name_prefix}AviatrixCopilot"
  })
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = var.additional_volumes
  device_name = each.value.device_name
  volume_id   = each.value.volume_id
  instance_id = aws_instance.aviatrixcopilot.id
}
