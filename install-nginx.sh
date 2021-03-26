#! /bin/bash
amazon-linux-extras install nginx1.12 -y
systemctl start nginx
systemctl enable nginx