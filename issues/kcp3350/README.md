
start pprof proxy
```bash
kubectl port-forward -n kcp-alpha deployment/alpha 6060:6060 &
```

```bash
curl http://localhost:6060/debug/pprof/profile?seconds=30 > pprof-profile-30s
```

pre pprof
```bash
curl http://localhost:6060/debug/pprof/goroutine > pprof-pre
```

set kubeconfig to kcp
```bash
export KUBECONFIG=../../kcp.kubeconfig
```

create a single worksapces
```bash


curl http://localhost:6060/debug/pprof/goroutine > pprof-default
k apply -f org-ws.yaml
```

pprof after one ws
```bash
curl http://localhost:6060/debug/pprof/goroutine > pprof-one
k delete -f org-ws.yaml
curl http://localhost:6060/debug/pprof/goroutine > pprof-one-post
```

```bash
for i in {1..10}; do echo "$i"; k apply -f org-ws.yaml; sleep 3; k delete -f org-ws.yaml; sleep 3; done
```

pprof after 100 ws
```bash
curl http://localhost:6060/debug/pprof/goroutine > pprof-100
```


```bash
k apply -f org-ws.yaml
```

```bash
k delete -f org-ws.yaml
```

```dlv
b pkg/reconciler/tenancy/workspace/workspace_reconcile_scheduling.go:287

b pkg/server/genericapiserver.go:689

b pkg/util/wait/wait.go:72

transcript -t -x goroutines-pre
goroutines -s
transcript -off

transcript -t -x goroutines-post
goroutines -s
transcript -off

```
