#!/bin/bash
apt update -y
apt install nginx git -y
rm -rf /var/www/html/*
git clone https://github.com/AishwaryaPawar149/Terraform-Jenkins-Static-Website.git /var/www/html/
systemctl restart nginx
systemctl enable nginx