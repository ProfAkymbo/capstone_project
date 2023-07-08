# Variables
variable "ID" {
  description = "Unique identifier."
  type        = string
}


# Resources
resource "aws_security_group" "InstanceSecurityGroup" {
  name        = "UdaPeople-${var.ID}"
  description = "Allow port 22, port 9100 and port 3030."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

}
resource "aws_instance" "EC2Instance" {
  instance_type = "t2.micro"
  security_group_names = [aws_security_group.InstanceSecurityGroup.name]
  key_name      = aws_key_pair.devkey.key_name
  ami           = "ami-068663a3c619dd892" # Replace with the appropriate AMI ID for your region and requirements

  tags = {
    Name = "backend-${var.ID}"
  }
}


# Create a .pem file
# RSA key of size 2048 bits
resource "tls_private_key" "new-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "private_key" {
  filename          = "${var.ID}-key.pem"
  content = tls_private_key.new-key.private_key_pem
  file_permission   = "0700"
}


# Create a Key Pair
resource "aws_key_pair" "devkey" {
  key_name   = "${var.ID}-key"
  public_key = tls_private_key.new-key.public_key_openssh
# public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCldJxUMlogWB1Uu9/aDYFttIQZi1qP4H1BvfYmlbAKqWlAE3aGODI2MHytxvUk9j8BM7LI3+MibMASRSnXGX6UkHsg+3Vorsj6Nq/n2zjLjqLD6PqE+ijoNx6bjRmgztP7iTgfIBYplu6snT0MXCPXUIEUfMZyh2s251RdBEvaJuf/IgmUmssxbT9juToxjKLHmQGOcH4HmsGt33b5G3JL9KMidA3ACmrNZOZzDl48ZbQYaPLCqOVITC9fz9zo2Zlzzp27CJu4Drw15ycvkK2/nsjL9rBbxjhJigqgZWtHRwphg2OtQsYzXoe8OeCqx/Is2QSiTD6J4mUq2WrL2UdP2/CscPt1W543SwGl1k8hloze3dHlgWEjgGZlLbmx9APiHwsrX7vNZkpCi4vCsCVHdiygnOqQxHnNKKNYVTpojxVPym4ElYlx1hurCN6ndMbneeRjYfB29yB5vNc2YgV7oN+HgkOB3PYWp9y+NdBXXFcMmGegMa8y9H9d6qTrINE= vagrant@ubuntu-focal"
}