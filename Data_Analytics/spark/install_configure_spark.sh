#### Script to install Spark Standalone in your ubuntu environment
#### Please read the tags carefully to 
#### ***** Tag 1 : Locations/Files Affected
#### ****** /usr/local/spark will be created 
#### ****** /usr/local/spark/conf/spark-defaults.conf will be created
#### ****** /usr/local/spark/conf/spark-env.sh will be created
#### ****** ~/.bashrc will affected for adding SPARK_HOME
#### ***** Tag 2 : 
#### ****** Command Line options include (in order)
#### ****** master host ip

apt-get install python
p_ver=$(python -c "import sys; print sys.version_info[:][0]")

# echo "Python version is $p_ver";
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

if [ $p_ver -ne 2 ]; then
	echo "Python version is not ";
	sudo add-apt-repository ppa:fkrull/deadsnakes
	sudo apt-get update
	sudo apt-get install python2.7
else
	echo "Python version is 2";
fi;
if [ $JAVA_HOME -eq '' ]; then
	add-apt-repository ppa:webupd8team/java
	apt-get update
	apt-get install oracle-java8-installer
	echo "
/$JAVA_HOME=/usr/lib/jvm/java-8-oracle
	" >> ~/.bashrc
	source ~/.bashrc
fi;

if [[ $SPARK_HOME == '' ]]; then
	echo "Installing Spark please wait .............";
	rm -rf /usr/local/spark
	pip install --upgrade pip
	if [ $# -eq 1 ];then

		echo "Ok Mater IP is provided";
		ip=$@

		wget https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
		tar xvf spark-2.1.1-bin-hadoop2.7.tgz
		rm spark-2.1.1-bin-hadoop2.7.tgz
		mv spark-2.1.1-bin-hadoop2.7 spark

		mv spark /usr/local

		echo "
export SPARK_HOME=/usr/local/spark
export PATH=\$PATH:\$SPARK_HOME/bin
		"  >> ~/.bashrc

		source ~/.bashrc

		rm aws-java-sdk-1.7.4.jar
		wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar
		mv aws-java-sdk-1.7.4.jar $SPARK_HOME/jars
		hadoop-aws-2.7.3.jar
		wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar
		mv hadoop-aws-2.7.3.jar $SPARK_HOME/jars


		## begin with spark-defaults settings
		touch $SPARK_HOME/conf/spark-defaults.conf
		echo "
spark.driver.extraClassPath  $SPARK_HOME/jars/aws-java-sdk-1.7.4.jar:$SPARK_HOME/jars/hadoop-aws-2.7.3.jar
spark.executor.extraClassPath  $SPARK_HOME/jars/aws-java-sdk-1.7.4.jar:$SPARK_HOME/jars/hadoop-aws-2.7.3.jar
spark.hadoop.fs.s3a.impl        org.apache.hadoop.fs.s3a.S3AFileSystem
spark.hadoop.fs.s3a.access.key  AKIAJM7PY4JDECMVU2EA
spark.hadoop.fs.s3a.secret.key  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
spark.hadoop.fs.s3a.experimental.input.fadvise random
spark.hadoop.fs.s3n.access.key  AKIAJM7PY4JDECMVU2EA
spark.hadoop.fs.s3n.secret.key  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
spark.hadoop.fs.s3.access.key  AKIAJM7PY4JDECMVU2EA
spark.hadoop.fs.s3.secret.key  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
spark.serializer                   org.apache.spark.serializer.KryoSerializer
spark.shuffle.manager              SORT
spark.shuffle.consolidateFiles     true
spark.shuffle.spill                true
spark.shuffle.spill.compress       false
spark.shuffle.compress             true
spark.io.compression.codec         snappy
		"  >> $SPARK_HOME/conf/spark-defaults.conf

		## begin with spark-env settings
		touch $SPARK_HOME/conf/spark-env.sh

		echo "
export SPARK_WORKER_INSTANCES=9
export SPARK_WORKER_MEMORY=6G
export SPARK_WORKER_CORES=32
export SPARK_EXECUTOR_INSTANCES=9
export SPARK_EXECUTOR_MEMORY=5700M
export SPARK_EXECUTOR_CORES=32
export SPARK_MASTER_IP= $ip
		"  >> $SPARK_HOME/conf/spark-env.sh



		source $SPARK_HOME/conf/spark-env.sh


		## begin installing and configuring Jupyter Notebook
		pip install ipython
		pip install jupyter


		jupyter notebook --generate-config --allow-root

		#nano ~/.jupyter/jupyter_notebook_config.py

		echo "
c.NotebookApp.ip = '*'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.token = ''
c.NotebookApp.password= ''
c.LocalAuthenticator.create_system_users = True
		" >> ~/.jupyter/jupyter_notebook_config.py

	else
		echo "Please provide a valid Master IP to save yourself pain of setting it Later. Ciao!";
	fi;

else
	echo "Spark already installed and running............";
fi;
