#!/bin/bash
# Update the package list and install necessary packages
sudo yum update -y
sudo yum install -y ruby wget

# Install Docker
sudo yum install docker -y
	
sudo usermod -aG docker ec2-user
sudo service docker start

# Enable Docker to start on boot
sudo systemctl enable docker

# Install AWS CodeDeploy Agent
cd /home/ec2-user
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Start the CodeDeploy agent
sudo service codedeploy-agent start

# Enable CodeDeploy agent to start on boot
sudo systemctl enable codedeploy-agent
	
# Print versions to verify installation
docker --version
codedeploy-agent --version
