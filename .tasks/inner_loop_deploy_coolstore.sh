####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`
PROJECT_NAME=$1

#For Sandbox Starting from existing project

$DIRECTORY/solutions/inventory-quarkus/solve_deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/catalog-spring-boot/solve_deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/gateway-dotnet/deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/web-nodejs/deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/health-probes/deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/app-config/deploy.sh ${PROJECT_NAME}

echo -e "\033[0;32mThe deployment of the Coolstore Application in ${PROJECT_NAME} by Inner Loop has succeeded\033[0m"