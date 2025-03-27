<image src="/images/architecture.png">



# Pre-requisites:

1. Install terraform and add it to your path

2. Create a IAM user Admin with AdminAccess Policy

3. Create access credentials that can be used in aws cli

4. Configure your aws cli using the token

# Things to do:

1. Configuring S3 buckets to use it as a static delivery option for efficiency

2. Configure CloudWatch to pull all the metrics

3. Configure secure communication between private instances and rds using the self signed certificate from acm

4. testing and load balancing

5. creating auto scaling and using cloud watch metrics to autoscale the instances

# How to use Terraform:
```bash
    terraform fmt #formats the code (optional)

    terraform validate # optional

    terraform plan # check if any errors are occuring during the staging phase

    terraform apply 

```


# Assets created

1. 2 Public subnets for load balancers in 2 availability zones

2. 2 private subnets for ec2 instances in 2 availability zones

3. 2 private subnets for rds in 2 availability zones

4. Routes of all the private and public subnets for ec2 and loadbalancers are attached to NAT and Internet Gateway respectively

5. Route of private subnet for rds is only attached to NAT gateway and doesn't lead outside the network, but the instances within the VPC can still access it

6. Private key and certificate and imported it to ACM

7. Security Groups:

    i. loadbalancer - ingress and egress to port 80 and 443 from everywhere

    ii. private-webserver - ingress and egress to port 80 and 443 from everywhere

    iii. private-rds - ingress and egree to port 3306 from the security group private-webserver

8. Load balancer with ssl certificate to encrypt data in transit, configured target groups and listners for redirecting insecure communication to secure communication channel ( you may see error as the certificates are self signed and are not validated via any nameserver to cut on charges) 

9. KMS key to encrypt data at rest encrypting ebs volumes, rds and s3 buckets

10. WAF to block XSS and SQLi using AWS managed rules

11. New instance in public subnet that you can access using ssh just remember to change the key_name attribute in instances to the keys you have

12. You can try deploying your code onto the instances within the private subnet 
