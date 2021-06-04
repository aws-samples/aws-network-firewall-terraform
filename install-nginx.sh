#! /bin/bash
sudo yum update -y
sudo amazon-linux-extras enable nginx1.12 -y
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx