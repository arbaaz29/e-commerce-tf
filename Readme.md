# Architecture Diagram Overview:
<image src="/images/architecture.png">

# In-Depth service architecture:
<image src="/images/Services_attached.png">

# How to use Terraform:
```bash
    terraform fmt #formats the code (optional)

    terraform validate # optional

    terraform plan # check if any errors are occuring during the staging phase

    terraform apply 

```

# Pre-requisites:

1. Install terraform and add it to your path

2. Create a IAM user Admin with AdminAccess Policy

3. Create access credentials that can be used in aws cli

4. Configure your aws cli using the token

5. Hosted Zones (either via Route53 DNS or Import from other domain)

6. SSL/TLS certificate for the CloudFront issued via ACM

7. S3 bucket with static contents and attach it to cloudfront for edge caching


# Assets created

1. 2 Public subnets for load balancers in 2 availability zones

2. 2 private subnets for ec2 instances in 2 availability zones

3. 2 private subnets for rds in 2 availability zones

4. Routes of all the private and public subnets for ec2 and loadbalancers are attached to NAT and Internet Gateway respectively

5. Route of private subnet for rds is only attached to NAT gateway and doesn't lead outside the network, but the instances within the VPC can still access it

6. Issue certificates and validate them via DNS validation method through ACM

7. Security Groups:

    i. loadbalancer - ingress and egress to port 80 and 443 from everywhere

    ii. private-webserver - ingress and egress to port 80 and 443 from everywhere

    iii. private-rds - ingress and egree to port 3306 from the security group private-webserver

8. Load balancer with ssl certificate to encrypt data in transit, configured target groups and listners for redirecting insecure communication to secure communication channel ( you may see error as the certificates are self signed and are not validated via any nameserver to cut on charges) 

9. KMS key to encrypt data at rest encrypting ebs volumes, rds and s3 buckets

10. WAF to block XSS and SQLi using AWS managed rules

11. New instance in public subnet that you can access using ssh just remember to change the key_name attribute in instances to the keys you have

12. The automated bash script will download and setup the application within the instances 

13. LoadBalancer with stickiness for session management, so that there won't be overlap in data

14. S3 bucket for storing access logs and coonnection logs from lb

15. Cloudwatch alarms and log groups for metric consumption and log collection from WAF

16. Route53 for routing traffic to the respective resources

17. AMI, creating custom ami for Autoscaling groups

18. Launch Template to launch the ami and configuring the instances

19. Autoscaling group to launch the instances according to CPU utilization, desired instances are 2 and minimum 1 and maximum 4
    i. This means that atleast 1 instance will be running at all times

20. Secrets manager stores secrets in a central way, these credentials and endpints are used in db connection for the application