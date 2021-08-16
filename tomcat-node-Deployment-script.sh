#!/bin/bash
#===================================================================================
#
# FILE: tomcat-node-Deployment-script.sh
#
# USAGE: ./tomcat-node-deployment
#
# DESCRIPTION: 
#              This script will remove "data", "tmp" and "work" folders on particular node (which is given as argument for this script)
#	       Also it'll rename and zip the catalina.out file
#
# CREATED BY : Hariharaprasath
#
#
# COMPANY: TechMango
#
# VERSION: 1.0
#
# CREATED: 23-Feb-2021 - 01:30 AM IST
# 
# Need to check values on the script
#
# Step:1 - "TOMCAT_HOME=/opt/Tomcat" -This is tomcat dir path so plz must be change on the value
# Step:2 - "WAR_FILE=/home/sys-user/Downloads/sample.war" - War deployment file path
# Step:3 - "EAR_FILE_NAME=sample.war" "war/jar/ear" i have mentioned my war file so please change according to your war file
# Step:4 - "hostname and ip address include the scripts if need use this, otherwise plz delete or command the lines"-lineno-11,12
# Step:5 - "I have removed the war extracted file on webapps folder so please check the war extracted file name on script-lineno-29,1-8
#===================================================================================

TOMCAT_HOME=/opt/Tomcat
TOMCAT_WEBAPPS=$TOMCAT_HOME/webapps
TOMCAT_SHUTDOWN=$TOMCAT_HOME/bin/shutdown.sh
TOMCAT_START=$TOMCAT_HOME/bin/startup.sh
WAR_FILE=/home/sys-user/Downloads/sample.war
EAR_FILE_NAME=sample.war
TIME=$(date +"%Y-%m-%d-%H%M")
hostname=`hostname -f`
ip=`hostname -I | awk '{print $1}'`

echo "Going to down the tomcat server"

$TOMCAT_SHUTDOWN

if [ -d $TOMCAT_HOME ]
        then
             
                echo "TOMCAT HOME Folder is available ( $TOMCAT_HOME )"
                if [ -d $TOMCAT_HOME ]
                        then
                                echo "'$TOMCAT_HOME' Folder Available"
				
                                echo "Removing 'sample' 'work' folders in $TOMCAT_HOME'"
                                cd $TOMCAT_HOME &&
                                rm -rf work
 				cd webapps  &&
				rm -rf sample
                                ESTATUS=$?
                                if [ $ESTATUS -eq 0 ]
                                        then
						
                                                echo "'work' 'sample'  folders removed successfully"
                                        else
					
                                                echo "ERROR - While remove 'work' 'sample' folders from $TOMCAT_HOME"
                                                echo "JOB TERMINATED"
                                                exit 1
                                fi
                                if [ -f $TOMCAT_HOME/logs/catalina.out ]
                                        then
						
                                                echo "'$TOMCAT_HOME/logs/catalina.out' file available"
						
                                                echo "Renaming 'catalina.out' to catalina.out.$TIME and compressing it"
                                                cd $TOMCAT_HOME/logs && mv catalina.out catalina.out.$TIME &&
                                                gzip catalina.out.$TIME
                                                ESTATUS=$?
                                                if [ $ESTATUS -eq 0 ]
                                                        then
								
                                                                echo "Renamed and compressed catalina.out file"
								
                                                                echo "Compressed log file name is 'catalina.out.$TIME.zip'"
                                                        else
								
                                                                echo "ERROR - while rotate or compress catalina.out file"
                                                                echo "JOB TERMINATED"
                                                                exit 1
                                                fi
                                        else
                                                echo "WARNING - $TOMCAT_HOME/logs/catalina.out file NOT found"
                                fi
                        else
				
                                echo "'$TOMCAT_HOME' folder NOT availbale"
                                echo "HINT - Check whether the node name is correct or not"
                                echo "JOB TERMINATED"
                                exit 1
                fi
        else
		
                echo "ERROR - TOMCAT Home folder NOT available ($TOMCAT_HOME)"
                echo "JOB TERMINATED"
                exit 1
fi


if [ ! -w $TOMCAT_HOME -o ! -w $TOMCAT_WEBAPPS ]; then
    echo "$TOMCAT_HOME and $TOMCAT_WEBAPPS must be writable." 1>&2
    exit 1
fi

if [ ! -r $WAR_FILE ]; then
    echo "$WAR_FILE is missing. Download it and run this again to deploy it." 1>&2
else
    echo "copy the war file to webapp folder"	
    cp $WAR_FILE $TOMCAT_WEBAPPS
fi

echo " verify the md5sum in newly copied EAR/JAR/WAR files"

NEW_EAR_MD5=`md5sum $WAR_FILE  | awk '{print $1}'`

DEPLOYED_EAR_MD5=`md5sum $TOMCAT_HOME/webapps/$EAR_FILE_NAME | awk '{print $1}'`

if [ $NEW_EAR_MD5 == $DEPLOYED_EAR_MD5 ]
	then
		echo "$EAR_FILE_NAME - MD5SUM is matching"
                $TOMCAT_START
		echo "Node is ready to start"
else
		echo "$EAR_FILE_NAME - MD5SUM is NOT matching"
		echo "JOB TERMINATED"
		exit 1
fi

