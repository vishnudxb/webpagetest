# Webpagetest Server

Why we need to use a Webpagetest Private Instances? May be you can find the answer from [here] (http://www.slideshare.net/patrickmeenan/velocity-2014-nyc-web-pagetest-private-instances)  

Here we are using [Terraform] (https://www.terraform.io/) inorder to do the Automation

#REQUIREMENTS
* Install Terraform
* You need to give the AWS ACCESS KEY, AWS SECRET KEY and the KEY PAIR and the KEY PAIR NAME on AWS

#HOW TO RUN THE COMMAND

```
vishnudxb@server:~# ./terraform apply -var 'access_key=<provide access key>' -var 'secret_key=<provide secret key>' -var 'key_file=<provide your pem file>' -var 'key_name=<give the keypair name on AWS>'

```
#For example

```
vishnudxb@server:~# ./terraform apply -var 'access_key=MYACCESSKEY' -var 'secret_key=MYSECRETKEY' -var 'key_file=/home/private.pem' -var 'key_name=private' 

```
