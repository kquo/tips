## AWS
Amazon Web Services tips.

### AWS EC2 Instance Types Comparison
See <http://www.ec2instances.info/>

### Useful Commands
Useful commands.

- EC2 instance metadata, from instance: `curl -s http://169.254.169.254/latest/meta-data/ ec2`

- Get AWS Instances ID: `InstId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>&1)`

