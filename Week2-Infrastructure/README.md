# Week 2 — AWS Infrastructure with Terraform

This provisions the AWS infrastructure to run the Week 1 CRUD app (from Docker Hub: `mutshutshudzi/crud-app`) in a production-style setup: private app tier, private database, public load balancer, and auto scaling.

---

## Architecture

```
                            Internet
                               |
                        [Internet Gateway]
                               |
                    ┌──────────┴──────────┐
                    │   Application Load   │
                    │      Balancer        │   <- public subnets
                    └──────────┬───────────┘
                               |
                 ┌─────────────┴─────────────┐
                 │      Auto Scaling Group     │
                 │   (EC2 instances running     │  <- private subnets
                 │     the app in Docker)        │
                 └─────────────┬─────────────┘
                               |
                        [NAT Gateway]  (outbound internet only,
                               |         e.g. to pull the Docker image)
                               |
                    ┌──────────┴──────────┐
                    │   RDS PostgreSQL     │   <- private subnets
                    └───────────────────────┘
```

- **VPC** with 2 public subnets + 2 private subnets across 2 AZs
- **Internet Gateway** — gives the public subnets (and the ALB) internet access
- **NAT Gateway** — lets the private app instances reach the internet outbound only (to `docker pull` the image), without being reachable from the internet
- **Security Groups** — layered so only the ALB is open to the internet; the app only accepts traffic from the ALB; the database only accepts traffic from the app
- **RDS PostgreSQL** — private, not publicly accessible
- **Launch Template + Auto Scaling Group** — EC2 instances that install Docker on boot and run the app container, automatically pointed at the RDS endpoint
- **Application Load Balancer** — public entry point, health-checks instances on `/health` and distributes traffic

---

## Files

| File | Purpose |
|---|---|
| `providers.tf` | Terraform + AWS provider setup |
| `variables.tf` | All configurable inputs |
| `networking.tf` | VPC, subnets, IGW, NAT, route tables |
| `security_groups.tf` | ALB / app / RDS security groups |
| `rds.tf` | PostgreSQL database |
| `compute.tf` | Launch template + Auto Scaling Group |
| `alb.tf` | Load balancer, target group, listener |
| `outputs.tf` | Useful values printed after apply (like the app URL) |
| `user_data.sh.tpl` | Boot script each EC2 instance runs to install Docker and start the app |
| `terraform.tfvars.example` | Template for your own `terraform.tfvars` (which is gitignored) |

---

## Prerequisites

- Terraform installed (`terraform -version`)
- AWS CLI installed and configured (`aws configure`) with credentials that have permission to create VPCs, EC2, RDS, and ELB resources
- The Week 1 image already pushed to Docker Hub (done: `mutshutshudzi/crud-app:latest`)

---

## Deploy

```bash
# 1. Create your real variables file (never commit this)
cp terraform.tfvars.example terraform.tfvars
# then edit terraform.tfvars and set a real db_password

# 2. Initialize Terraform (downloads the AWS provider)
terraform init

# 3. See what will be created
terraform plan

# 4. Create the infrastructure
terraform apply
# type "yes" when prompted
```

This takes **10-15 minutes**, mostly waiting for the RDS database and NAT Gateway to become available.

---

## After deploying

Terraform will print outputs including:

```
alb_dns_name = "http://crud-app-alb-xxxxxxxxxx.af-south-1.elb.amazonaws.com"
```

Open that URL in your browser — it's your CRUD app, now running on AWS instead of your laptop, with a real database behind it.

It can take a couple of minutes after `apply` finishes for instances to pass health checks and start receiving traffic.

---

## Tear down

To avoid ongoing AWS charges when you're done:

```bash
terraform destroy
```

---

## Notes on cost

This uses `t3.micro` for both EC2 and RDS, which are eligible for the AWS Free Tier on new accounts, but the **NAT Gateway is NOT free tier** and bills hourly plus per-GB — remember to `terraform destroy` when you're finished working, so you don't get an unexpected bill.
