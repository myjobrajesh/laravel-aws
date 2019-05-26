# laravel deployment on aws
# laravel integration on aws, #deploy laravel on aws, #distribute laravel on AWS

# Steps 
- AWS integration 
- go to Aws from console panel and create below services to distribute laravel application on it
- AWS Requirement:
1. Staging server-instance
2. Production server instance
3. Worker server instance for production cron, this will create sqs queue automatically. Make sure queue should restart by: php artisan queue:restart

4.SQS - queue if required
5.Elastic Search service
6. S3 bucket (file-bucket) for files storage
7. S3 bucket (env-bucket) for storing  .env.production and .env.staging files
8. Redis cluster for session storage
9. RDS 1 for production
10. RDS 2 for staging if any
11. SES – Email

- Deployment

There are two method command line (eb) and direct login to that instance and deploy zip file.

This is command line (eb) method :


# First time deployment:

1. Open any folder say aws_laravel in local.
2. Cd to this folder and Use gitbash tool to in it.
3. Setup git  (First time setup)
4. Git init for new repo Else git clone -  Git clone : get clone url from gitlab.
5. Setup EB cli (First time setup) : Setup python, setup eb cli.

Python install (https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-windows.html)

pip install awsebcli --upgrade –user

add path environment vars : C:\Users\rchaudhari\AppData\Roaming\Python\Python37\Scripts

close terminal and reopen and then type : eb –version

run  : pip install awsebcli --upgrade –user

this will create two folder . .ebextensions and .elasticbeanstalk

. elasticbeanstalk in this folder it creates another config.yml file – automatic process.

. ebextensions in this folder we have to create 4 config files manually.  Named like –(These are already in git project source, so ref only.no need to create)

01setup.config

02env_vars.config

03artisan.config

.aws_deploy.sh ( this file we use for deployment, If environment change on aws then update here)

Final folder structure :
Hope 3 environment already created on AWS from GUI: production, staging(if required), worker.

~/workspace/my-app/

.ebextensions

--01setup.config

--02env_vars.config

--03artisan.config

env_vars.config.production

env_vars.config.staging

.elasticbeanstalk

config.yml

index.php, .env and another file.

cron.yaml (For cron scheduler)

.aws_deploy.sh ( deployment script)


--- How to deploy – every time.
on command line from root of folder run below commands:

./.aws_deploy.sh OR 

./.aws_deploy.sh production ( this should be in master branch, this will run worker environment automatically)

# Rollback

For this we should go to console of that environment and select version to deploy : https://console.aws.amazon.com/elasticbeanstalk/home

OR by command line  : eb deploy <environment> --version version_label
Example : eb deploy production –version test1

# worker
- We have to use worker tier for cron job to be run. Because in load balancer, it will dulicate if we use same instance. So better to use worker tier so it will runs per active environment.

- Worker Environment creation for CRON: This is a safest way.
 - Create worker environment from aws console on same env. And set HTTP_path : worker/schedule
- Create inbound and outbound rule for group.- Security group And also assign rds group rules to this.
- Content of cron.yaml : 

version: 1

cron:

- name: "schedule"

  url: "/worker/schedule"
  
  schedule: "* * * * *"

- Check REGISTER_WORKER_ROUTES  var=false on web tier environment from env. So make two env file one for web and one for worker, if not then use true for all env. In worker env we this should be true.

WE have already such script: to make deployments easier is create a deploy bash script that runs the eb deploy command in both environments, something like:

eb deploy -nh

eb deploy worker-app -nh

The -nh flag tells the eb command not to wait until the deploy completes before returning. The first command deploys to the default environment, the second deploys to the environment named worker-app. 
- Both environments should have same server setting.

# QUEUE
- For queue usage we have to set SQS queue setting in config/queue and set QUEUE_DRIVER = sqs. 
- Need to set the Queue Driver = database inside the .env file for local but for aws it should be QUEUE_DRIVER = sqs.
- Do this in local if you want to start queue without supervisor : `php artisan queue:work` 
- for linux we have to set supervisor to run queue 
- Restart : php artisan queue:restart
- For AWS queue : https://github.com/dusterio/laravel-aws-worker

# REDIS – AWS ElasticCache for Redis: session storage
- Create redis cluster form server: ElasticCache. Redis
- create security group that supports TCP.

# REF :
- For s3 package: composer require league/flysystem-aws-s3-v3 if required
- For AWS Elastic Search: composer require jsq/amazon-es-php if required
- YAML File format - http://www.yamllint.com/
- queue : https://github.com/dusterio/laravel-aws-worker




