
BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

export JAVA_HOME='/c/develop/tools/java/corretto-1.8.0_382'
export MAVEN_HOME='/c/develop/tools/maven'
export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"

mvn clean package

if [[ $? -ne 0 ]] || [[ ! -e target/tomcat-8.5-ext.jar ]]; then
  echo "fail to build"
fi

cp target/tomcat-8.5-ext.jar /c/develop/tools/tomcat/tomcat-8.5.93/lib

ls -al /c/develop/tools/tomcat/tomcat-8.5.93/lib/tomcat-8.5-ext.jar
