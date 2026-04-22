#!/bin/bash

export RobotAutomationTag=$1

echo $HOME
#
# Create directories
#
mkdir -p $HOME/Airlinq
mkdir -p $HOME/Airlinq/platform
mkdir -p $HOME/Airlinq/application
mkdir -p $HOME/buildstatus

cd $HOME/Airlinq/application

if [ ! -d $HOME/Airlinq/application/stc-robot-automation ]
then
	git clone -b $RobotAutomationTag https://$GIT_TOKEN@github.com/peeyush-tm/stc-robot-automation
	#git clone -b feature-branch https://$GIT_TOKEN@github.com/peeyush-tm/stc-robot-automation
fi

application=robot-automation
BITBUCKET_TAG=$1

if [[ $RobotAutomationTag == *[.]* ]] || [[ $RobotAutomationTag == *[_]* ]]
then
        BITBUCKET_TAG=`echo "$RobotAutomationTag" | sed 's/.*\(Q2\|R2\|D2\)/\1/'`
else
        BITBUCKET_TAG=$RobotAutomationTag
fi


cd $HOME/Airlinq/application/stc-robot-automation

	mkdir -p $HOME/airlinqBuild/Airlinq/logs/$application
	mkdir -p $HOME/airlinqBuild/Airlinq/temp/$application
	mkdir -p $HOME/airlinqBuild/Airlinq/scripts/patch/$application/changelog
	mkdir -p $HOME/airlinqBuild/Airlinq/scripts/operations/$application
	mkdir -p $HOME/airlinqBuild/Airlinq/docs/$application/relnotes
	cp -r * $HOME/airlinqBuild/Airlinq/scripts/operations/$application
	cp -r docs/relnotes/* $HOME/airlinqBuild/Airlinq/docs/$application/relnotes
	cp .releasesequence $HOME/airlinqBuild/Airlinq/scripts/patch/$application

	cd $HOME/airlinqBuild/Airlinq
	find . -type f -print0 | xargs -0 cksum >> $HOME/airlinqBuild/Airlinq/docs/$application/relnotes/RobotAutomation-$RobotAutomationTag-cksum.txt
	cd -


