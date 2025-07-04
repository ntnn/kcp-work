
oidc-login
```bash
kubectl oidc-login setup \
    --oidc-issuer-url=https://127.0.0.1:5556/dex \
    --oidc-client-id=kcp \
    --oidc-client-secret=kcp \
    --certificate-authority=/opt/homebrew/etc/pki/ca.crt \
    --oidc-extra-scope=openid,email
```

```bash
export KUBECONFIG=.kcp/admin.kubeconfig
k ws use :root:provider
k apply -f issues/kcp3390/rbac-provider.yaml
```
