echo "Hello! Welcome to Data Science Cluster setup process"
echo "This file contains settings and installs for (not in same order)"
echo "		1. Java (Latest)"
echo "		2. pip (latest for python 2.*)"
echo "		3. Spark 2.1 "
echo "		4. Jupyter Notebook (latest)"
echo " 		5. Essential Python Packages for Data Science Purpose"
echo "		6. Essential R packages for Data Science Purpose"


# config variables , you can adjust according to need

# CRITICAL KEYS ,,,,, DO NOT LET EXPOSURE OR MISUSE,,,,,, AWS KEYS
# PLEASE do not compromise with this keys
AWS_ACCESS_KEY='put your access key here'
AWS_SECRET_KEY='put your secret key here'

# must change if different config
env_var_file='.bashrc'
master_ip='127.0.0.1'
user_home='/home/ajay'
machine_cpu_size=64

# files to support S3 access from cluster , change only when new version is been tested properly
aws_java_sdk_download_url='http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar'
hadoop_aws_download_url='http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar'
aws_sdk_file_name=$(echo $aws_java_sdk_download_url | sed 's#.*/##')
hadoop_aws_file_name=$(echo $hadoop_aws_download_url | sed 's#.*/##')
aws_java_sdk_path="jars/$aws_sdk_file_name"
hadoop_aws_path="jars/$hadoop_aws_file_name"


# not that much needed for changing these
spark_dir_path='/usr/local/'
full_access_code='0777'
jupyter_launch_port=8888
preffred_python_version='python2.7'
python_ppa_location='ppa:deadsnakes/ppa'
preffred_python_version_major=2

# change only after testing the newest spark bugs check and proper installation
spark_download_url='https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz'
spark_dir_default_name='spark'
# for installation prefer WIKI page for spark standalone setup

# do not disturb settings
spark_zip_file_name=$(echo $spark_download_url | sed 's#.*/##')
no_error=/dev/null

pip_download_url='https://bootstrap.pypa.io/get-pip.py'
pip_install_file_name=$(echo $pip_download_url | sed 's#.*/##')
jupyter_dir="$user_home/.jupyter"

# spark configuration file names .........
###### Please do not change names in any case ######
spark_default_conf_file_name='conf/spark-defaults.conf'
spark_env_file_name='conf/spark-env.sh'
spark_log4j_file_name='conf/log4j.properties'

# spark default settings for worker and executors
spark_memory_min=8
SPARK_WORKER_MEMORY='8G'
SPARK_EXECUTOR_MEMORY='8G'
SPARK_WORKER_CORES=4
SPARK_EXECUTOR_CORES=4
SPARK_WORKER_INSTANCES=$((machine_cpu_size/spark_memory_min))
SPARK_EXECUTOR_INSTANCES=$((machine_cpu_size/spark_memory_min))

# Python version checking and setting it to $preffred_python_version

python_ver_complete=$(python -c "import platform; print( platform.python_version())")
python_ver_major_minor=${python_ver_complete%.*}
python_ver_major=${python_ver_major_minor%.*}

# checkign python version no.
if [[ $python_ver_major != $preffred_python_version_major ]];	then
	echo "Python version is not preffered version "
	echo "Installing Python $preffred_python_version version and making it as default"
	# adding essential packages for smooth install of $preffred_python_version
	sudo apt-get install -y build-essential checkinstall
	sudo apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
	# adding repo for python all versions
	sudo add-apt-repository $python_ppa_location -y
	# quick system update for reflecting changes
	sudo apt-get update
	# installing $preffred_python_version from package manager
	sudo apt-get install $preffred_python_version -y
	# adding to bashrc file and making changes system-wide
	echo "alias python=$preffred_python_version" >> $user_home/$env_var_file && source $user_home/$env_var_file
else
	echo "Python version is $preffred_python_version_major.*. OK to proceed."
fi

# installing pip for python2.7
pip_presense=$(command -v pip)
if [[ $pip_presense == '' ]]; then
	echo "pip is not installed"
	echo "Downloading and Installing pip latest"
	# deleting if any install file previously exists 
	rm get-pip* >> $no_error
	# downloading pip install file
	wget --no-check-certificate $pip_download_url
	# installing pip
	python $pip_install_file_name
	# deleting install file since it is of no use now
	rm $pip_install_file_name >> $no_error

else
	echo "pip is already installed with $(pip --version) version"
fi

# installing R latest
R_presence=$(command -v R)
if [[ $R_presence == '' ]]; then
	echo "R is not installed"
	echo "Downloading and Installing R latest"
	# command to install latest R
	sudo apt-get install r-base -y
else
	echo "R is already installed with $(R --version) version"
fi

# installing Java
java_presense=$(command -v java)
if [[ $java_presense == '' ]]; then
	echo " Java is not installed"
	echo " Downloading and Installing latest Java"
	# command to install latest Java
	sudo apt-get install default-jdk -y
else
	echo " Java is already installed with $(java -version) version"
fi

# installing jupyter notebook
jupyter_presense=$(command -v jupyter notebook)
if [[ $jupyter_presense == '' ]]; then
	echo " Jupyter is not installed"
	echo " Downloading and Installing Jupyter"
	# installing dependencies
	sudo apt-get install python-dev -y
	# installing jupyter 
	sudo pip install jupyter 
else
	echo " Jupyter is already installed with version"
fi

# doing configuration of jupyter notebook
# refer WIKI page for config details
# since all users will access and modify settings at some points , we want every user to have full access to this folder
sudo chmod -R $full_access_code $jupyter_dir
jupyter notebook --generate-config -y
echo "
c.NotebookApp.ip = '*'   
c.NotebookApp.port = $jupyter_launch_port
c.NotebookApp.open_browser = False
c.NotebookApp.token = ''
" >> $jupyter_dir/jupyter_notebook_config.py

# installing spark 
spark_presense=$(command -v spark-submit)
if [[ $spark_presense == '' ]]; then
	echo " Spark is not installed"
	echo " Downloading and Installing Spark "
	# deleting any previous files of spark that exists
	rm -rf spark* >> $no_error
	rm -rf $spark_dir_path/spark*
	# downloading spark2.1 with inbuild hadoop2.7
	wget --no-check-certificate $spark_download_url
	# extract and rename file to spark
	tar -xvf $spark_zip_file_name  >> $no_error
	mv spark-2.1.1-bin-hadoop2.7 $spark_dir_default_name
	# moving file to my preffered location 
	mv $spark_dir_default_name/ $spark_dir_path
	# deleting any previous files of spark that exists
	rm $spark_zip_file_name >> $no_error
	# setting spark in environment variables
	echo "
export SPARK_HOME=$spark_dir_path$spark_dir_default_name
export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin
" >> $user_home/$env_var_file
	source "$user_home/$env_var_file"
else
	echo "Spark is already installed"
fi

SPARK_HOME=$spark_dir_path$spark_dir_default_name
sudo chmod -R a+rwX $SPARK_HOME/

touch "$SPARK_HOME/$spark_default_conf_file_name" >> $no_error
# no change default settings for SPARK default Configurations
# please do not change 
echo "
spark.driver.extraClassPath  $SPARK_HOME/$aws_java_sdk_path:$SPARK_HOME/$hadoop_aws_path
spark.executor.extraClassPath  $SPARK_HOME/$aws_java_sdk_path:$SPARK_HOME/$hadoop_aws_path
spark.hadoop.fs.s3a.impl        org.apache.hadoop.fs.s3a.S3AFileSystem
spark.hadoop.fs.s3a.access.key  $AWS_ACCESS_KEY
spark.hadoop.fs.s3a.secret.key  $AWS_SECRET_KEY
spark.hadoop.fs.s3a.experimental.input.fadvise random
spark.hadoop.fs.s3n.access.key  $AWS_ACCESS_KEY
spark.hadoop.fs.s3n.secret.key  $AWS_SECRET_KEY
spark.hadoop.fs.s3.access.key  $AWS_ACCESS_KEY
spark.hadoop.fs.s3.secret.key  $AWS_SECRET_KEY
spark.serializer                   org.apache.spark.serializer.KryoSerializer
spark.shuffle.manager              SORT
spark.cores.max   $((SPARK_EXECUTOR_CORES*4))
spark.deploy.defaultCores $((SPARK_EXECUTOR_CORES*4))
"  > "$SPARK_HOME/$spark_default_conf_file_name"

touch "$SPARK_HOME/$spark_env_file_name" >> $no_error
# no change environment setting 
echo "
export SPARK_WORKER_INSTANCES=$SPARK_WORKER_INSTANCES
export SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY
export SPARK_WORKER_CORES=$SPARK_WORKER_CORES
export SPARK_EXECUTOR_INSTANCES=$SPARK_EXECUTOR_INSTANCES
export SPARK_EXECUTOR_MEMORY=$SPARK_EXECUTOR_MEMORY
export SPARK_EXECUTOR_CORES=$SPARK_EXECUTOR_CORES
export SPARK_MASTER_IP=$master_ip
" > "$SPARK_HOME/$spark_env_file_name"

touch "$SPARK_HOME/$spark_log4j_file_name" >> $no_error
# no change logging settings
echo "
log4j.rootCategory=WARN, console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.err
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n

# Set the default spark-shell log level to WARN. When running the spark-shell, the
# log level for this class is used to overwrite the root logger's log level, so that
# the user can have different defaults for the shell and regular Spark apps.
log4j.logger.org.apache.spark.repl.Main=WARN

# Settings to quiet third party logs that are too verbose
log4j.logger.org.spark_project.jetty=WARN
log4j.logger.org.spark_project.jetty.util.component.AbstractLifeCycle=ERROR
log4j.logger.org.apache.spark.repl.SparkIMain$exprTyper=INFO
log4j.logger.org.apache.spark.repl.SparkILoop$SparkILoopInterpreter=INFO
log4j.logger.org.apache.parquet=ERROR
log4j.logger.parquet=ERROR

# SPARK-9183: Settings to avoid annoying messages when looking up nonexistent UDFs in SparkSQL with Hive support
log4j.logger.org.apache.hadoop.hive.metastore.RetryingHMSHandler=FATAL
log4j.logger.org.apache.hadoop.hive.ql.exec.FunctionRegistry=ERROR
" > "$SPARK_HOME/$spark_log4j_file_name"

# creating unrestricted access to locahost
# fixing ssh problems that can occur such as port connection refused
sudo apt-get remove openssh-client openssh-server -y >> $no_error
sudo apt-get update
sudo apt-get install openssh-client openssh-server -y >> $no_error

echo "Thank you for your patience. Setup is complete. Following commands are available "
echo "		spark-submit, pyspark, sparkR , R, pip, jupter notebook "
echo " for list of packages refer document on WIKI pages"
