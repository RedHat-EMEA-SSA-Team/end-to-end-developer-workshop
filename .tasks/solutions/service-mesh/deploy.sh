#########################
# Service Mesh Solution #
#########################

DIRECTORY=`dirname $0`
USER_ID=$1
APPS_HOSTNAME_SUFFIX=$(oc whoami --show-console | sed 's%.*\(apps.*\)$%\1%g')

oc project cn-project${USER_ID}

oc patch deployment/catalog-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

oc patch deployment/inventory-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

oc patch deployment/gateway-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

## Create the local gateway
cat << EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: istio-ingressgateway
spec:
  type: ClusterIP
  selector:
    istio: ingressgateway
  ports:
  - name: http2
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
EOF

oc expose service istio-ingressgateway

cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: istio-ingressgateway
spec:
  selector:
    matchLabels:
      istio: ingressgateway
  template:
    metadata:
      annotations:
        # Select the gateway injection template (rather than the default sidecar template)
        inject.istio.io/templates: gateway
      labels:
        # Set a unique label for the gateway. This is required to ensure Gateways can select this workload
        istio: ingressgateway
        # Enable gateway injection. If connecting to a revisioned control plane, replace with "istio.io/rev: revision-name"
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: istio-proxy
        image: auto # The image will automatically update each time the pod starts.
EOF

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ingressgateway
  namespace: cn-project${USER_ID}
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
    - port:
        number: 8080
        name: http
        protocol: HTTP
      hosts:
        - "*"
EOF

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: gateway-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - "*"
  gateways:
    - ingressgateway
  http:
    - route:
        - destination:
            port:
              number: 8080
            host: gateway-coolstore
EOF

oc set env deployment/web-coolstore COOLSTORE_GW_ENDPOINT="http://istio-ingressgateway-cn-project${USER_ID}.${APPS_HOSTNAME_SUFFIX}"

oc new-app https://github.com/RedHat-EMEA-SSA-Team/end-to-end-developer-workshop \
    --strategy=docker \
    --context-dir=/labs/catalog-go \
    --name=catalog-coolstore-v2 \
    --labels=app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=golang

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - catalog-coolstore
  http:
  - route:
    - destination:
        host: catalog-coolstore
      weight: 0
    - destination:
        host: catalog-coolstore-v2
      weight: 100
EOF