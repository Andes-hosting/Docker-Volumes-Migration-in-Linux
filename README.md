# Docker Volumes Migration in Linux

## What is it for?

This repository contains bash scripts designed to run on your Linux machine to backup Docker volumes. You can use these scripts if your volumes are stored in the default Docker location instead of being locally mounted. The following example illustrates how to create the type of volumes that are compatible with these scripts:

### Example that does not work
```yml
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
```yml
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
Based on the last example, you can migrate the volume to another machine or create a backup for later restoration.

## How to use (Backup and restore on the same machine)
To back up and later restore, clone this repository:
```sh
git clone https://github.com/Andes-hosting/Docker-Volumes-Migration-in-Linux.git
```
Navigate to the cloned repository:
```sh
cd /Docker-Volumes-Migration-in-Linux
```

### First Step: Backup

Before performing any backup, remember to stop your Docker container to prevent data corruption.

Run the backup_volume.sh script to back up the volume:
```sh
sudo sh backup_volume.sh <volume name>
```
>_Note: Always use `sudo` because the folder where Docker saves volumes is restricted to root users.._

If you don't know the volume name, you can list all volumes with:
```sh
docker volume ls
```
After following these instructions, you should find a compressed file named `volume_name_backup_date.tar.gz` in the `/home/root/backup` directory.

### Second Step: Restore
If you want to restore the volume to the state at the time of backup, navigate to the repository folder and run the restore_volume.sh script:
```sh
sudo sh restore_volume.sh </home/root/backup/volume_name_backup_date.tar.gz> <volume name>
```
After running the script, the volume should be completely replaced with the backup.

## How to use (Migration to another machine)
If you need to migrate a service from one machine to another, follow these steps, which are similar to the ones explained before.

### First Step: Backup

Before any backup, stop your Docker container to prevent data corruption.

Use the `backup_volume.sh` script by navigating to the cloned repository and executing:
```sh
sudo sh backup_volume.sh <volume name>
```
If you don't know the `<volume name>`, use `docker volume ls` to check.

After following these instructions, you should have a compressed file named `volume_name_backup_date.tar.gz` in the `/home/root/backup` directory.

### Second Step: Migrate Backup Volume to your new Machine

Transfer your volume backup (or several) to the other machine using `rsync` from the machine where you performed the backup. Use the `ssh` protocol to transfer the files. An example command:

```sh
sudo rsync -avz -e ssh /home/root/backup/* user@ip_address:/home/user/
```
If using a `.pem` file to avoid passwords:
```sh
sudo rsync -avz -e "ssh -i /home/user/.ssh/file_name.pem" /home/root/backup/* user@ip_address:/home/user/
```
Assuming successful execution, you should have your volume backups in the destination machine's `/home/user/volume_name_backup_date.tar.gz` or your specified location.

### Third Step: Before Restoring

Before restoring the backup on the new machine, deploy the Docker service you intend to move your volume to. This is necessary for the volume folder to be created. Stop the Docker container and proceed with using `restore_volume.sh`.

### Fourth Step: Restore the Backup on your new Machine

Run the following command:
```sh
sudo sh restore_volume.sh </home/user/volume_name_backup_date.tar.gz> <volume name>
```
This completes the process of migrating your volume from one machine to another.

>_Note: If the Docker container you are using requires a domain name, and you have modified it during migration or backup, there might be some issues. This problem arises in cases like Chatwoot, Leantime, Shlink, and others, while being a non-issue for containers independent of the domain URL, such as Uptime Kuma and Focalboard, among others._
