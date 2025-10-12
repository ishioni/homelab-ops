---
apiVersion: v1
kind: Namespace
metadata:
  name: flux-system
---
apiVersion: v1
kind: Secret
metadata:
  name: sops-age
  namespace: flux-system
stringData:
  age.agekey: op://Homelab/flux/AGE_PRIVATE_KEY
---
apiVersion: v1
kind: Namespace
metadata:
  name: security
---
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-secret
  namespace: security
stringData:
  1password-credentials.json: op://Homelab/op-connect/OP_CREDENTIALS_JSON
  token: op://Homelab/op-connect/OP_CONNECT_TOKEN
  ESO_TOKEN: op://Homelab/op-connect/ESO_TOKEN
