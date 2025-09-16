apiVersion: v1
clusters:
- cluster:
    server: ${cluster_endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: ${cluster_id}
contexts:
- context:
    cluster: ${cluster_id}
    user: ${cluster_id}
  name: ${cluster_id}
current-context: ${cluster_id}
kind: Config
preferences: {}
users:
- name: ${cluster_id}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${cluster_id}"
