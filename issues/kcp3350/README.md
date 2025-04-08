pre pprof
```bash
curl http://localhost:6060/debug/pprof/goroutine > pprof-pre
```

```bash
sh ./run-test.sh 100
```

pprof after 100 ws
```bash
curl http://localhost:6060/debug/pprof/goroutine > pprof-post
```

```bash
go tool pprof -http :8080 -diff_base pprof-pre pprof-post
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
