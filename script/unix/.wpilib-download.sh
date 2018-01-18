#!/bin/bash

# This script downloads the latest (known) file of the WPI C++ plugin.
# The .jar file (really a .zip) contains a cpp.zip that has the
# include/ and lib/ folders necessary to build/link an executable FRC robot.

# The resulting wpilib/include/ folder should be used as a g++ -I statement
# The wpilib/lib folder should be used as a g++ -L statement

# TODO: script determining the latest .jar file based on the date string
# rather than a hard coded file name.
# The latest version can be determined from
# http://first.wpi.edu/FRC/roborio/release/eclipse/site.xml

# most recent version available from the internet
version="$(wget --quiet http://first.wpi.edu/FRC/roborio/release/eclipse/plugins/ && cat index.html | grep wpilib.plugins.cpp | sed -r 's/^.*wpilib.plugins.cpp_(.*).jar.*$/\1/')"
# most recent downloaded version (for usage outside of Travis CI)
version=$(echo $version | tr -d '\n')
downloaded_version=$(cat wpilib/versions.txt)

printf "Version: $version Current: $downloaded_version\n"

echo "WPILib Download: $PWD"

if [ ! "$version" = "$downloaded_version" ] ; then
	# download core and cpp pugins
	wget -r -nd --no-clobber --progress=bar http://first.wpi.edu/FRC/roborio/release/eclipse/plugins/edu.wpi.first.wpilib.plugins.cpp_2018.1.1.jar

	# get rid of old data
	rm -rf $PWD/wpilib/
	mkdir $PWD/wpilib/

	# unpack and extract from cpp
	rm -rf $PWD/wpilib-cpp/
	unzip -q $PWD/edu.wpi.first.wpilib.plugins.cpp_2018.1.1.jar -d $PWD/wpilib-cpp/
	unzip -q $PWD/wpilib-cpp/resources/cpp.zip -d $PWD/wpilib/

	# get rid of irrelivant folders
	rm -rf $PWD/wpilib/doxygen/

	# unpack and extract from core
	wget -r -nd --no-clobber --progress=bar http://first.wpi.edu/FRC/roborio/release/eclipse/plugins/edu.wpi.first.wpilib.plugins.core_2018.1.1.jar
	rm -rf $PWD/wpilib-core/
	unzip -qo $PWD/edu.wpi.first.wpilib.plugins.core_2018.1.1.jar -d $PWD/wpilib-core/
	unzip -qo $PWD/wpilib-core/resources/common.zip -d $PWD/wpilib-core/

	# move lib files to correct location
	mkdir $PWD/wpilib/lib/
	mv -n $PWD/wpilib-core/lib/linux/athena/shared/* $PWD/wpilib/lib/
	mkdir $PWD/wpilib/lib-cpp/
	mv -n $PWD/wpilib/reflib/linux/athena/shared/* $PWD/wpilib/lib-cpp/
	rm -rf $PWD/wpilib/reflib/

	# clean up and delete temp files
	rm -rf $PWD/edu.wpi.first.wpilib.plugins.cpp_2018.1.1.jar
	rm -rf $PWD/edu.wpi.first.wpilib.plugins.core_2018.1.1.jar
	rm -rf $PWD/wpilib-cpp/
	rm -rf $PWD/wpilib-core/
else
	echo "Already at latest WPILIB version"
fi
rm index.html
echo "WPILIB Version = $version"
echo $version >> wpilib/versions.txt
