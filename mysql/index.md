# MySQL 
Many MySQL tips you can cut/paste.

## Common Commands
```
# Shell logon
mysql -h{hostname} -u{username} -p{pwd} db-name 

# Dump all variables from `mysql` shell 
use information_schema;`

# Show processes from `mysql` shell
show processlist ;
show full processlist ;
select left(VARIABLE_NAME,30),left(VARIABLE_VALUE,50) from GLOBAL_VARIABLES order by 1;

# Grant minimum required user privileges to do mysqldump
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER, RELOAD, REPLICATION CLIENT, ON `mydb`.* TO 'dumpuser'@'%' ;

# Backup dump from OS shell
$ mysqldump -h{hostname} -udumpuser -p{pwd} db-name | gzip -c > db-name-dump.sql.gz

# Restoring from a dump from OS shell
gunzip db-name-dump.sql.gz
mysql -h{hostname} -u{username} -p{pwd} db-name < db-name-dump.sql

# Create a DB and user
mysql -h mysite-prd-db01.mine.com -P 3306 -u root -p
create database stag_mysite ;
create user 'stag-mysite-user'@'%' identified by '<strong-pwd>' ;
grant all on stag_mysite.* to 'stag-mysite-user'@'%' ;

# List users
select * from mysql.user;

# Change user password
set password for 'stag-mysite-user'@'%' = password('<strong-pwd>') ;

# Delete user
DROP USER 'jeffrey'@'localhost';
```

## Additional Commands
```
# Show user grants
show grants for 'jeffrey'@'%';

# Check table sizes
select SUM(data_length) + SUM(index_length) as size from information_schema.tables where table_schema = 'MYDB';

# Check number of records in a table:
SELECT COUNT(*) FROM table_name;

# Vital table info for a database:
select TABLE_NAME,TABLE_ROWS,AVG_ROW_LENGTH, DATA_LENGTH,INDEX_LENGTH,DATA_FREE from information_schema.tables where TABLE_SCHEMA="DB_NAME"; 

# Check size of all databases
SELECT table_schema "DB Name", Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" FROM information_schema.tables GROUP BY table_schema;

# Check size of all tables on DB named MYDB
SELECT table_name AS "Table", round(((data_length + index_length) / 1024 / 1024), 2) "Size in MB" FROM information_schema.TABLES WHERE table_schema = "MYDB" ORDER BY (data_length + index_length) DESC;

# Removing unneeded, default, troublesome blank users
select host,user,password from mysql.user ;
drop user ''@'localhost' ;
drop user ''@'<HOSTNAME>' ;

# Case insensitivity can be a real pain it's better to use the recommended "1" in /etc/my.cnf
lower_case_table_names = 1

# Change user password
mysql -hhostname -uroot -ppassword DBNAME
select author_name, author_id, author_password from mt_author where author_id = 1;
update mt_author set author_password = encrypt('foobar') where author_id = 1;
 
# Enable MYSQL slow query logging
SET GLOBAL slow_query_log = ON; FLUSH LOGS;
```

## Reset Forgoten Root User Password
```
mysqld_safe --skip-grant-tables

# You should see mysqld start up successfully. If not, well you have bigger issues. Now you should be able to connect to mysql without a password.

mysql --user=root mysql

update user set Password=PASSWORD('new-password') where user='root';
flush privileges;
exit;

# Stop mysqld again, and restart as normal
```
