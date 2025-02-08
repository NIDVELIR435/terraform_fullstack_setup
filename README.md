### init project first
```shell
terraform init
```
next select workspace which you want to update
```shell
terraform warkspace select development
```
for selected workspace create .<workspace_name>.db.env (eg.: .development.db.env )
```shell
touch .development.db.env
```
and put inside expected mysql credentials
```shell
DB_USERNAME=mysql_user
DB_PASSWORD=aadg22cg2iuvrgrrg87n2g3Cr723
```
> **_KEEP IN MIND:_** if you work with exist infrastructure, you should put exist data according to the same file in s3
### Create hosted zone and certificate records.
> **_NOTE:_**   this needs to initially create domain name according to workspace, so created dns we should connect mannualy or send to external sys admin 
```shell
terraform apply -target="module.domain"
```
This will create record in aws ACm. According to the created record, add CNAME record to your dns provider where domain name registered
### When certificate will be issued by aws. Execute all rest commands 
```shell
terraform apply
```
#### terraform will show pending updates
