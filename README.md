# Docker-Volumes-Migration-in-Linux

## What is it for?

Here you can find bash scripts to run on you Linux machine in order to backup Docker volumes. You can use them only if your volumes are stored in the default location of Docker instead of mounting locally. Here is an example of how to create the kind of volumes I'm talking about.

### Example that does not work
```
version: '3.9'
services:
  web:
    image: nginx:alpine
    ports:
      - "8000:80"
    volumes:
      - ./app:/usr/share/nginx/html
```

### Example that does work
```
version: '3.9'
services:
  web:
    image: nginx:alpine
    ports:
      - "8000:80"
    volumes:
      - nginx_data:/usr/share/nginx/html

volumes:
  nginx_data:
```
Based on the previous example (the last one) we can migrate it to another machine or just do a backup to restore it later.

## How to use (Only backup and restore in the same machine)
To backup and restore it later you need to clone this repository.
```
git clone https://github.com/Andes-hosting/Docker-Volumes-Migration-in-Linux.git
```
After that you need to get inside the folder you just cloned from the repository.
```
cd /Docker-Volumes-Migration-in-Linux
```

### First Step: Backup

Before doing any backup, remember to stop your docker container to avoid data corruption.

Once you have cloned the repository, run the first script called `backup_volume.sh`, to backup the volume.
```
sudo sh backup_volume.sh <volume name>
```
>_Note: You always have to use sudo, because the folder where docker saves the volumes are restricted to only root users._

By the way if you don't know the name of the volume you intend to save, you can always do:
```
docker volume ls
```
To get the list of volumes in your machine.

If you could follow along the previous instructions, you should have a new compressed file called `volume_name_backup_date.tar.gz` in the directory `/home/root/backup`.

### Second Step: Restore
So, it's been a while and you want to restore the volume to the time you did the backup.

To do so, you need to get inside the folder of the repository as you previously did and then run the second script called `restore_volume.sh`.
```
sudo sh restore_volume.sh </home/root/backup/volume_name_backup_date.tar.gz> <volume name>
```
After running it, the volume should have been completly replaced with the backup you did.

## How to use (Migration to another machine)

In case you need to migrate a service from one machine to another we recommend you to do it with the following steps (which are really similar to the ones explained before).

### First Step: Backup

Before doing any backup, remember to stop your docker container to avoid data corruption.

You just need to do the backup using the script called `backup_volume.sh`, to do so just go inside the folder where you cloned this repository and do as follows.
```
sudo sh backup_volume.sh <volume name>
```
In case you don't know the `<volume name>`, remember you can always use `docker volume ls` to check it.

If you could follow along the previous instructions, you should have a new compressed file called `volume_name_backup_date.tar.gz` in the directory `/home/root/backup`.

### Second Step: Migrate Backup Volume to your new Machine

You need to transfer your volume backup or several volume backups to the other machine, to do so we recommend using `rsync` from the machine where you have done the backup, and use `ssh` protocol to transfer the files.

This is an example of how to run it:
```
sudo rsync -avz -e ssh /home/root/backup/* user@ip_address:/home/user/
```
You'll probably need to place the password of the destination machine to complete the prcoess, unless you have a `.pem` file to avoid using passwords, in that case you can do as follows:
```
sudo rsync -avz -e "ssh -i /home/user/.ssh/file_name.pem" /home/root/backup/* user@ip_address:/home/user/
```
If everything run well you should now have your volume backups in the destination machine in the `/home/user/volume_name_backup_date.tar.gz` or wherever you decided to place it.

### Third Step: Before Restoring

Before you restore the backup in the new machine, you need to deploy the docker service you expect to move you volume to, this is needed for the folder of the volume to be created. Then, you need to stop the docker container and then you can go ahead and use the `restore_volume.sh`.

## Fourth Step: Restore the Backup in you new Machine

Finally, you just have to run:
```
sudo sh restore_volume.sh </home/user/volume_name_backup_date.tar.gz> <volume name>
```
That would be enough to have your volume migrated from one machine to the other.

>_Note: If the docker container you are using requieres you to add a domain name and in the migration or backup you have modify that, there might be some issues. This problem aries in cases like Chatwoot, Leantime, Shlink, and other, while this situation is no issue for other container that are independent from the domain url, like uptime-kuma and focalboard as some examples._