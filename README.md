# NEBO CICD Continuous Integration, Release, and Deployment

This is a complete pipeline project build from scratch.

## Technologies used on the project:
- Jenkins
- AWS Cloud Services
- Terraform
- SonarQube (install on EC2 Jenkins sonar)
- Docker
- Golang as Programming language

## Schema 
![Pipeline_schema](/Images/NEBO_CICD_pipeline.jpeg)

## Setting up requirements

### Creating EC2 isntances

![Ec2_instances](/Images/NEBO_CICD_ec2_Instances.png)

### Creating ECR

![ecr](/Images/NEBO_CICD_create_ecr_repo.png)

### Config Pipeline

![Pipeline_config](/Images/NEBO_CICD_config_pipeline.png)


### Seting Jenkis Nodes

![nodes](/Images/NEBO_CICD_created_nodes.png)

### GitHub webhook

![webohook](/Images/NEBO_CICD_webhoook.png)

### Installing SonarQube and Creating Projects

![EC2_SonarQube](/Images/NEBO_CICD_SonarQube.png)

#### SonarQube Webhook

![sonar_webhook](/Images/NEBO_CICD_Sonar_webhook.png)

## Runing Pipiline

### Pipeline flow

![pipeline_flow](/Images/NEBO_CICD_ppipipeline_working.png)

#### SonarQube scan

![sonar_scaner](/Images/NEBO_CICD_Sonar_analysis.png)

### Api Deploy

![api_deployed](/Images/NEBO_CICD_api_delivered.png)


## Additional Notes

- This Pipeline requires IAM Role and IAM User with proper permissions
- Credentials Are configured on the EC2 node tha run AWS realated stages
- Terraform, Git, Docker are installed on the nodes
- This project deploys terraform on AWS using FARGATE service
- Terraform state is store on S3
