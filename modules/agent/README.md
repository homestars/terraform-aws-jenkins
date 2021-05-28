# terraform-aws-jenkins/agent
To deploy this module you need to have:
1. An existing VPC
2. A DockerHub hosted Agent image, and credentials with access to the image (and/or an override image)
3. The account ID for the jenkins master that needs permission to spin up this agent

Example minimal inputs are below (you need to fill in the blanks)
```hcl
inputs = {
  dockerhub_credentials_arn = ___
  environment_variables     = []
  jenkins_agent_image       = ___
  jenkins_master_account    = ___
  kms_keys                  = []
  secrets                   = []
  vpc_id                    = dependency.vpc.outputs.vpc_id
}
```
Remember to update your Jenkins Master to allow inbound from the ip range of the agent, and with the appropriate IAM roles!

## Jenkins Agent Image
Example dockerfile would look something like this (make sure you set the agent to use web socket connections!).
```dockerfile
FROM jenkins/inbound-agent:alpine

WORKDIR /ansible

USER root
RUN apk update && \
    apk add \
    ...

USER jenkins
ENV JENKINS_WEB_SOCKET="true"
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
```
