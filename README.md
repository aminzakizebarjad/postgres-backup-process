#backing up postgress
We were running a thingsboard-ce docker based installation on a private cloud provider.  
Unfortunatly we lost all of data in postgresql and cassandra.  
At that moment the write and read rate was high with a cpu load of 70%.  
I just downed a single container and saw that many of the containers were recreated in an unknown manner.  
After that we were having a problem in thingsboard core logs which were relevant to a table that was trying to find from the relational database.  
We checked out the size of the database folders and it was suprisingly low.  
We understood that we have stocked into a disaster.  
I was doing some tests on the servers and the tests were successful in two servers with a running thingsboard on them. When i reached the third, things messeds up and I fund myself in a trouble.  
The first two belonged to our own company but the third belonged to our partner company.  
So we get to the point of creating a server for hoding up our database backups.  
In this repo we have a bash script that must run on the server were the thingsboards is being installed.  

