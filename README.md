# terraform-aws-jenkins
## Useage
<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

## Deployment
To deploy this module you need to have:
1. An existing VPC with at least two subnets
2. A DockerHub hosted Jenkins image, and credentials with access to the image (and/or an override image)
3. The url and ssl cert for the url you will redirect to the LB once it's created (module does not create route53 entry)
4. A github application, and a github user account with credentials to fill in below (password is the PAT for the account, secret is the secret from the app)
5. Once run, create a DNS entry pointing from the url provided to the dns record outputed by this module

Example minimal inputs are below (you need to fill in the blanks)
```hcl
inputs = {
  dockerhub_credentials_arn = ___
  github_client_id          = ___
  jenkins_master_image      = ___
  jenkins_url               = ___
  kms_keys                  = []
  private_subnet_ids        = dependency.vpc.outputs.private_subnets
  public_subnet_ids         = dependency.vpc.outputs.public_subnets
  secrets = [
    {
      Name      = "JENKINS_CRED_GITHUB_SECRET"
      ValueFrom = ___
    },
    {
      Name      = "JENKINS_CRED_GITHUB_PASSWORD"
      ValueFrom = ___
    }
  ]
  tls_certificate_arn = ___
  vpc_id              = dependency.vpc.outputs.vpc_id
}
```

### Jenkins Master Image
Example Dockerfile. Note this allows for setup without user interference
```dockerfile
FROM jenkins/jenkins:lts-alpine

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_OPTS --httpKeepAliveTimeout=30000

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

ENV CASC_JENKINS_CONFIG $REF/casc.yaml
COPY casc.yml $REF/casc.yaml
```

Example casc.yml. This uses the `github-oauth` for user management, `job-dsl` to seed jobs, and `amazon-ecs` to spin up agents on demand. All variables must be injected in terraform/ECS task.
```yaml
---
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              id: JENKINS_CRED_GITHUB
              password: ${JENKINS_CRED_GITHUB_PASSWORD}
              scope: GLOBAL
              username: ${JENKINS_GITHUB_USERNAME}
          - string:
              description: JENKINS_CRED_SLACK_INTEGRATION_TOKEN
              id: JENKINS_CRED_SLACK_INTEGRATION_TOKEN
              scope: GLOBAL
              secret: ${JENKINS_CRED_SLACK_INTEGRATION_TOKEN}
jenkins:
  authorizationStrategy:
    globalMatrix:
      permissions:
        - Agent/Build:myorg
        - Job/Build:myorg
        - Job/Read:myorg
        - Lockable Resources/View:myorg
        - Overall/Administer:myorg*jenkins-admin
        - Overall/Read:myorg
        - Run/Update:myorg
        - SCM/Tag:myorg
        - View/Configure:myorg
        - View/Create:myorg
        - View/Delete:myorg
        - View/Read:myorg
  clouds:
    - ecs:
        name: example-agent
        allowedOverrides: inheritFrom,label,memory,cpu
        cluster: ${JENKINS_EXAMPLE_AGENT_ARN}
        credentialsId: ''
        jenkinsUrl: ${JENKINS_URL}
        regionName: us-east-1
        retentionTimeout: 5
        slaveTimeoutInSeconds: 300
        templates:
          - assignPublicIp: false
            cpu: 0
            executionRole: ${JENKINS_EXAMPLE_AGENT_TASK_EXECUTION_ROLE_ARN}
            label: agent-int
            launchType: FARGATE
            memory: 0
            memoryReservation: 0
            networkMode: awsvpc
            platformVersion: 1.4.0
            privileged: false
            remoteFSRoot: /home/jenkins
            securityGroups: ${JENKINS_EXAMPLE_AGENT_SECURITY_GROUP}
            sharedMemorySize: 0
            subnets: ${JENKINS_EXAMPLE_AGENT_SUBNETS}
            taskDefinitionOverride: ${JENKINS_EXAMPLE_AGENT_TASK_DEFINITION_ARN}
            uniqueRemoteFSRoot: false
  crumbIssuer: standard
  mode: NORMAL
  numExecutors: 5
  remotingSecurity:
    enabled: true
  scmCheckoutRetryCount: 2
  securityRealm:
    github:
      clientID: ${JENKINS_GITHUB_CLIENTID}
      clientSecret: ${JENKINS_CRED_GITHUB_SECRET}
      githubApiUri: https://api.github.com
      githubWebUri: https://github.com
      oauthScopes: read:org,user:email,repo
  slaveAgentPort: 50000
  systemMessage: |
    Jenkins configured automatically by Jenkins Configuration as Code plugin
jobs:
  - script: |
      job('Job_DSL_Seed') {
        scm {
          git {
            remote {
              url('https://github.com/myorg/myseedrepo.git')
              credentials('JENKINS_CRED_GITHUB')
            }
            branch('main')
          }
        }
        steps {
          jobDsl {
            targets('jobs/**/*.groovy')
            removedJobAction('DELETE')
            removedViewAction('DELETE')
            removedConfigFilesAction('DELETE')
          }
        }
        triggers {
          githubPush()
          hudsonStartupTrigger {
            quietPeriod("90")
            runOnChoice("ON_CONNECT")
            label("")
            nodeParameterName("")
          }
        }
      }
security:
  globalJobDslSecurityConfiguration:
    useScriptSecurity: false
  queueItemAuthenticator:
    authenticators:
      - global:
          strategy: triggeringUsersAuthorizationStrategy
unclassified:
  location:
    adminAddress: jenkins@mydomain.com
    url: ${JENKINS_URL}
  slackNotifier:
    botUser: false
    room: "jenkins-deploys"
    sendAsText: false
    teamDomain: "mydomain"
    tokenCredentialId: "JENKINS_CRED_SLACK_INTEGRATION_TOKEN"
```
