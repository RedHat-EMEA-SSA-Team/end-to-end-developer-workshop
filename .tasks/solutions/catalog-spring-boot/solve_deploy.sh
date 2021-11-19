################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/catalog-spring-boot
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create catalog --app coolstore
odo push

oc label deployment catalog-coolstore app.openshift.io/runtime=spring --overwrite

echo "Catalog Spring-Boot Deployed"