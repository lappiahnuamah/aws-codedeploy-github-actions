# Deploying API to EC2 Using AWS CodeDeploy and GitHub Actions

This guide walks you through deploying an API to an EC2 instance using AWS CodeDeploy and automating the process with GitHub Actions.

## Prerequisites
- **AWS Account**: Ensure you have an AWS account.
- **IAM User with Required Permissions**: Permissions for CodeDeploy, EC2, and S3.
- **GitHub Repository**: Your code repository set up on GitHub.
- **EC2 Instance**: A running EC2 instance.
- **Docker Hub Account**: For hosting your Docker images.

## Steps to Set Up
### 1. Set Up EC2 Instance
- Launch an EC2 instance using Amazon Linux 2 AMI.
- Add a user data script to install Docker and the CodeDeploy agent:
  ```bash
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y ruby wget docker
  sudo usermod -aG docker ec2-user
  sudo service docker start
  sudo systemctl enable docker
  cd /home/ec2-user
  wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
  chmod +x ./install
  sudo ./install auto
  sudo service codedeploy-agent start
  sudo systemctl enable codedeploy-agent
### 2. Create an IAM Role for CodeDeploy

    Navigate to the IAM console.
    Create a new role with the following policies:
        AWSCodeDeployFullAccess
        AmazonS3ReadOnlyAccess (if using S3 for deployment).
    Attach the role to your EC2 instance.

### 3. Configure AWS CodeDeploy

    Create a CodeDeploy application and deployment group.
    Configure the deployment group to target your EC2 instances.

### 4. Prepare Your GitHub Repository

    Create the following directory structure in your repository:
    ├── scripts/
    ├── before_install.sh
    ├── start_server.sh
    ├── appspec.yml
- Example appspec.yml:
  
      version: 0.0
      os: linux
      files:
        - source: /
          destination: /home/ec2-user/deployment
      hooks:
        BeforeInstall:
          - location: scripts/before_install.sh
            timeout: 300
            runas: ec2-user
        ApplicationStart:
          - location: scripts/start_server.sh
            timeout: 300
            runas: ec2-user
### 5. Set Up GitHub Actions
  - Create a workflow file: .github/workflows/deploy.yml
  - Example content: 
    ```bash
    name: Deploy API to EC2
    on:
      push:
        branches:
          - main
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v3
          - name: Login to Docker Hub
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.DOCKER_HUB_USERNAME }}
              password: ${{ secrets.DOCKER_HUB_PASSWORD }}
          - name: Build and push Docker image
            run: |
              docker build -t ${{ secrets.DOCKER_HUB_USERNAME }}/todoapp .
              docker push ${{ secrets.DOCKER_HUB_USERNAME }}/todoapp:latest
          - name: Deploy with AWS CodeDeploy
            run: |
              aws deploy create-deployment \
                --application-name todoapp \
                --deployment-group-name todoapp-deployment-group \
                --github-location repository=${{ github.repository }},commitId=${{ github.sha }}
            env:
              AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
              AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
              AWS_REGION: us-east-2
### 6. Set Up GitHub Secrets
 - Add the following secrets to your GitHub repository:
     - DOCKER_HUB_USERNAME
     - DOCKER_HUB_PASSWORD
     - AWS_ACCESS_KEY_ID
     - AWS_SECRET_ACCESS_KEY  
### 7. Push Changes to GitHub
 Commit and push all changes to the main branch.
Monitor deployment in GitHub Actions and AWS CodeDeploy consoles.

### Conclusion
By following this guide, you can automate the deployment of your API to an EC2 instance using AWS CodeDeploy and GitHub Actions.

### Resources
- [AWS CodeDeploy Documentation](https://docs.aws.amazon.com/codedeploy/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com/)


---

### 3. **Commit and Push**
1. Add the above content to the `README.md` file in your repository.
2. Use the following commands to push changes:
   ```bash
   git init
   git add README.md
   git commit -m "Add project documentation"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<repository-name>.git
   git push -u origin main


