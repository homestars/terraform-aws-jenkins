tflint --init
terraform fmt -recursive -write=true -list=true
terraform init -backend=false;
terraform validate;
tflint -f compact -c ../.tflint.hcl;
