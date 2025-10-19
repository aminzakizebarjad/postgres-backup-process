# Backing up Postgresql  

## Procedure explaination  

With this script You will be available to back up a postgresql database which is being ran via docker as running container.  
Every time you dump a database in a new backup the previous backups will be removed based on a sort that is done over backup files.  
Backups are created with the datetime as appendix of backup file name.  
Upcoming procedure will be to transfer the dumped backup into the backup server.  

### Assumptions 
Backup server's ssh private key must be available on the Host (notice that the ssh keys are specific to each user).  
It's assumed that you know the Backup server IP and the user that handles the transfer on that backup server. Also it is assumed that
the targert transfer directory exists on backup server and belongs to the target user.  

## The Story  

### The crash on server  

We were running a thingsboard-ce docker based installation on a private cloud provider.  
Unfortunatly we lost all of data in postgresql and cassandra.  
At that moment the write and read rate was high with a cpu load of 70%.  
I just downed a single container, after recreating that many of other containers were recreated in an unwilling manner.  
After that we were having a problem in thingsboard core logs which were relevant to a table that was trying to find from the relational database.  
We checked out the size of the database folders and it was suprisingly low in size.  
We understood that we have stocked into a disaster.  
### What was I up to  

I was doing some tests on the servers and the tests were successful in two servers with a running thingsboard on them. When i reached the third, things messeds up and I found myself in a trouble.  
The first two belonged to our own company but the third belonged to our partner company.  
So we get to the point of creating a server for holding up our database backups.  
In this repo we have a bash script that must run on the server were the thingsboards is being installed.  

### Reasons that the disaster happened  

I found that one of my colleagues partnering me in maintaning servers have requested a snapshot dating back in 3 month.  
I checked on the problem on the net and it stated that this could be the reason the problem happened.  
But to this date we found no other reasons.  

## About the bash script  

Contains 4 functions  
1. get_params  
2. create_backup   
3. remove_previous_backup  
4. transfer_to_bu_server  

### get params  
this function takes all parameters that you need to put this bash script into funciton.  
if you give less parameters than expected then this will give user some Error folowing the proper usage.  
the **usage** will be like below  
```
pg_backup_process.sh --tb_dir [directory where thingsboard is cloned] --db_dir [directrory of where postgresql database saves data] --bu_user [the user on backup server] --bu_ip [backup server ip address] --bu_dir [where in backup server the backup resides] --bu_key [the ssh key to connect to backup server]
```  



 
