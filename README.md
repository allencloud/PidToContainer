# PidToContainer
Shell to find docker container name due to specified pid

Everyone knows that each process in a Docker container has a pid number in init pid namespace as well. 

If a sysadmin enters the host machine and finds that one process is running out of its way, like taking up much more CPU resource, comsuing too much memory and so on. 

If it is a process in a certain container, then finding this container out must be the first thing he'd like to do.

##Principle
Never to contact with Docker Daemon.

If connection with Docker Daemon is TLS verified, pid2con will not work.

##Implementation
The way pid2con used is cgroup filesystem. In cgroup filesystem, there are lots of container's cgroup details including all processes in it. 

Traverse all containers to check whether user-specified pid is in one of them.
