#!/bin/bash
DockerPidPath=/var/run/docker.pid
InputPid=0
DockerPid=0
DockerCgroupPath=/sys/fs/cgroup/memory/docker

function usage(){
	echo "NAME"
	echo "     pid2con - get container name by pid input"
	echo ""
	echo "SYNOPSIS"
	echo "     pid2con [pid]"
	echo ""
	echo "AUTHOR"
	echo "     Written by Allen Sun < allen.sun@daocloud.io > "
}

function verify_input_pid(){
	if [ -z $InputPid ]; then
		usage
		exit 1
	fi

	if [[ $InputPid != *[!0-9]* ]]; then
		if [[ $InputPid -gt 32768 ]] || [[ $InputPid -lt 1 ]]; then
			echo "Pid input should be 1~32768. Aborting..."
			exit 1
		fi
	else
		echo "Pid input should be an integer. Aborting..."
		exit 1
	fi
}

# read pid of docker daemon from /var/run/docker.sock
function read_docker_pid(){
	if [ ! -f "$1" ]; then
		echo "Pid file of Docker Daemon does not exist. Aborting..."
		exit 1
	fi 

	while read myline
	do
		DockerPid=$myline
	done < $1
}

function check_docker_existence()
{
	process=`ps -ef | awk '{$2==$DockerPid} END {print $2}'`
	if [ -z "$process" ]; then
		echo "Docker Daemon process does not exist. Aborting..."
		exit 1
	fi
}

function search_input_pid()
{
	# if cgroup subsystem does not exist, abort.
	if [ ! -e $DockerCgroupPath ]; then 
		echo "Docker's Cgroup does not exist. Aborting..."
		exit 1
	fi

	for dir in $(ls $DockerCgroupPath)
	do
		# get the length of filename in /sys/fs/cgroup/memory/docker
		length=$(expr length $dir)
		#echo $length
		if [ -d $DockerCgroupPath/$dir ]; then
			ContainerPath=$DockerCgroupPath/$dir/cgroup.procs
			while read myline
			do
				if [ $InputPid -eq $myline ]; then
					echo "Container ID: "$dir
					exit 0
				fi
			done < $ContainerPath
		fi 
	done

	echo "No docker container contains pid you input."
}



case "$1" in 
	help)
		usage
		;;
	--help)
		usage
		;;
	-h)
		usage
		;;
	*)	
		InputPid=$1

		verify_input_pid
		read_docker_pid $DockerPidPath
		check_docker_existence
		search_input_pid
	;;
esac