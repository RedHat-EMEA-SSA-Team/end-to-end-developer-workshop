##########################
# gateway-dotnet Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-dotnet
PROJECT_NAME=$1

cd ${CONTEXT_FOLDER}

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create dotnetcore31 gateway --app coolstore
odo url create gateway --port 8080
odo push
odo link inventory --port 8080
odo link catalog --port 8080

oc annotate --overwrite deployment/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label deployment gateway-coolstore app.openshift.io/runtime=dotnet --overwrite

echo "Gateway .NET Deployed"