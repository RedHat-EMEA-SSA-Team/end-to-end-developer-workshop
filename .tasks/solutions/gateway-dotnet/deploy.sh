##########################
# gateway-dotnet Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-dotnet
PROJECT_NAME=$1

cd ${CONTEXT_FOLDER}

#oc new-app dotnet:6.0~https://github.com/RedHat-EMEA-SSA-Team/end-to-end-developer-workshop#6.5 \
#        --context-dir=labs/gateway-dotnet \
#        --name=gateway-coolstore \
#        --labels=app=coolstore,app.kubernetes.io/instance=gateway,app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=gateway,app.openshift.io/runtime=dotnet,component=gateway

oc new-build dotnet:6.0 --name gateway-coolstore  \
  --labels=component=gateway \
  --env DOTNET_STARTUP_PROJECT=app.csproj --binary=true
oc start-build gateway-coolstore --from-dir=. -w

oc new-app gateway-coolstore:latest --name gateway-coolstore  --labels=app=coolstore,app.kubernetes.io/instance=gateway,app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=gateway,app.openshift.io/runtime=dotnet,component=gateway 

oc expose svc gateway-coolstore

oc annotate --overwrite deployment/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'

echo "Gateway .NET Deployed"