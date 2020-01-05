# docker_ssh_server
fresh ubuntu system with running ssh server

## How to build container

It is very easy:

    $ docker build -t ssh_server .

### or

    $ docker build https://github.com/risapav/docker_ssh_server.git

## How to run container

You should run container:

    $ docker run -d -P --name sshd ssh_server

## Run a test_sshd container

Then run it. You can then use docker port to find out what host port the container’s port 22 is mapped to:

    $ docker run -d -P --name test_sshd ssh_server
    $ docker port test_sshd 22

    0.0.0.0:49154

And now you can ssh as root on the container’s IP address (you can find it with docker inspect) or on port 49154 of the Docker daemon’s host IP address (ip address or ifconfig can tell you that) or localhost if on the Docker daemon host:

    $ ssh root@192.168.1.2 -p 49154

### or

    $ ssh root@localhost -p 49154

### The password is ``screencast``.

    root@f38c87f2a42d:/#

## Security

If you are making the container accessible from the internet you'll probably want to secure it bit. You can do one of the following two things after launching the container:

    Change the root password: docker exec -ti ssh_server passwd
    Don't allow passwords at all, use keys instead:
        $ docker exec ssh_server passwd -d root
        $ docker cp file_on_host_with_allowed_public_keys ssh_server:/root/.ssh/authorized_keys
        $ docker exec ssh_server chown root:root /root/.ssh/authorized_keys

## Environment variables

Using the sshd daemon to spawn shells makes it complicated to pass environment variables to the user’s shell via the normal Docker mechanisms, as sshd scrubs the environment before it starts the shell.

If you’re setting values in the Dockerfile using ENV, you need to push them to a shell initialization file like the /etc/profile example in the Dockerfile above.

If you need to passdocker run -e ENV=value values, you need to write a short script to do the same before you start sshd -D and then replace the CMD with that script.

## Clean up

Finally, clean up after your test by stopping and removing the container, and then removing the image.

    $ docker container stop test_sshd
    $ docker container rm test_sshd
    $ docker image rm ssh_server
