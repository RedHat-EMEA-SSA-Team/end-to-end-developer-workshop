##################################
# Continuus Integration Solution #
##################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/inventory-quarkus
USER_ID=$1

oc project cn-project${USER_ID}

GITEA_URL=http://gitea-server.gitea.svc:3000
GITEA_URL_WITH_CREDENTIALS=http://user${USER_ID}:openshift@gitea-server.gitea.svc:3000

curl -X DELETE ${GITEA_URL_WITH_CREDENTIALS}/api/v1/repos/user${USER_ID}/inventory-quarkus \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json"

curl -X POST ${GITEA_URL_WITH_CREDENTIALS}/api/v1/user/repos \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    -d '{"name" : "inventory-quarkus"}' 

cd ${CONTEXT_FOLDER}
rm -rf .git
git init
git remote add origin ${GITEA_URL}/user${USER_ID}/inventory-quarkus.git
git add *
git commit -m "Initial"
git push ${GITEA_URL_WITH_CREDENTIALS}/user${USER_ID}/inventory-quarkus.git

cat << EOF | oc apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: inventory-pipeline-pvc
  namespace: cn-project${USER_ID}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
EOF

cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: inventory-pipeline
  namespace: cn-project${USER_ID}
spec:
  tasks:
    - name: git-clone
      params:
        - name: URL
          value: 'http://gitea-server.gitea.svc:3000/user${USER_ID}/inventory-quarkus.git'
        - name: SUBMODULES
          value: 'true'
        - name: DEPTH
          value: '1'
        - name: SSL_VERIFY
          value: 'true'
        - name: DELETE_EXISTING
          value: 'true'
        - name: REVISION
          value: master
      taskRef:
        params:
          - name: kind
            value: task
          - name: name
            value: git-clone
          - name: namespace
            value: openshift-pipelines
        resolver: cluster
      workspaces:
        - name: output
          workspace: shared-workspace
    - name: s2i-java
      params:
        - name: VERSION
          value: openjdk-21-ubi8
        - name: CONTEXT
          value: .
        - name: TLS_VERIFY
          value: 'false'
        - name: MAVEN_CLEAR_REPO
          value: 'false'
        - name: BUILD_ARGS
          value: |
            MAVEN_MIRROR_URL=http://nexus.opentlc-shared.svc:8081/repository/maven-all-public
            MAVEN_CLEAR_REPO=true
        - name: IMAGE
          value: >-
            image-registry.openshift-image-registry.svc:5000/cn-project${USER_ID}/inventory-coolstore
      runAfter:
        - git-clone
      taskRef:
        params:
          - name: kind
            value: task
          - name: name
            value: s2i-java
          - name: namespace
            value: openshift-pipelines
        resolver: cluster
      workspaces:
        - name: source
          workspace: shared-workspace
  workspaces:
    - name: shared-workspace
EOF

# tkn pipeline start inventory-pipeline -n cn-project${USER_ID} \
#     --workspace name=shared-workspace,claimName=inventory-pipeline-pvc
# tkn pipeline logs inventory-pipeline -n cn-project${USER_ID} --last -f
