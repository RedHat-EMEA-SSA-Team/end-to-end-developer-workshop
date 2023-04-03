################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/catalog-spring-boot
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests oc:build oc:resource oc:apply

echo "Catalog Spring-Boot Deployed"