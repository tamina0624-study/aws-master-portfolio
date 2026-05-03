output "vpc_id" { value = module.network.vpc_id }
output "subnet_public_1_id" { value = module.network.subnet_public_1_id }
output "subnet_public_2_id" { value = module.network.subnet_public_2_id }
output "subnet_id" { value = module.network.subnet_public_1_id }
output "my_ip" { value = data.http.ifconfig.response_body }
output "ami_id" { value = module.compute.ami_id }
