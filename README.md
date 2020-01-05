# docker_ssh_server
fresh ubuntu system with running ssh server

## build with this:
docker build -t ssh_server .

## run this command
docker run -d ssh_server

## Security

If you are making the container accessible from the internet you'll probably want to secure it bit. You can do one of the following two things after launching the container:

    Change the root password: docker exec -ti ssh_server passwd
    Don't allow passwords at all, use keys instead:

$ docker exec ssh_server passwd -d root
$ docker cp file_on_host_with_allowed_public_keys ssh_server:/root/.ssh/authorized_keys
$ docker exec ssh_server chown root:root /root/.ssh/authorized_keys
