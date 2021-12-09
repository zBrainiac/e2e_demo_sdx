
docker pull sburn/apache-atlas:latest
docker run -d -p 21000:21000 --name atlas sburn/apache-atlas /opt/apache-atlas-2.1.0/bin/atlas_start.py



docker-compose down &&
docker rm -f $(docker ps -a -q) &&
docker volume rm $(docker volume ls -q)