#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

yum update -y
yum install -y httpd amazon-ssm-agent
systemctl start httpd
systemctl enable httpd
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
echo "<h1>Multi-Endpoint NFW Demo - ${project_name} - Instance 1</h1>" > /var/www/html/index.html
echo "<p>This instance is behind AWS Network Firewall with multiple endpoints</p>" >> /var/www/html/index.html
echo "<p>Timestamp: $(date)</p>" >> /var/www/html/index.html