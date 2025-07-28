package helpers

import (
	"context"
	"sync"

	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/apiserver/pkg/admission/plugin/policy/generic"
)

type [H generic.Hook] NewSourceFn func(context.Context) (generic.Source, error)

type SourceCache struct {
	lock              sync.RWMutex
	serverStopChannel <-chan struct{}
	entries           map[string]cacheEntry

	newSourceFn NewSourceFn
}

type cacheEntry struct {
	source generic.Source
	cancel context.CancelFunc
}

func NewSourceCache(fn NewSourceFn) *SourceCache {
	sc := new(SourceCache)
	sc.newSourceFn = fn
	return sc
}

func (sc *SourceCache) SetServerShutdownChannel(ch <-chan struct{}) {
	sc.lock.Lock()
	defer sc.lock.Unlock()
	p.serverStopChannel = ch
}

func (sc *SourceCache) Get(name string) (generic.Source, error) {
	sc.lock.Lock()
	defer sc.lock.Unlock()

	entry, ok := sc.entries[name]
	if ok {
		return entry.source
	}

	ctx, cancel := context.WithCancel(wait.ContextForChannel(sc.serverStopChannel))

	source, err := sc.newSourceFn(ctx, name)
	if err != nil {
		cancel()
		return nil, err
	}

	sc.entries[name] = cacheEntry{
		source: source,
		cancel: cancel,
	}

	return source, nil
}

func (sc *SourceCache) Remove(name string) {
	sc.lock.Lock()
	defer sc.lock.Unlock()
	entry, ok := sc.entries[name]
	if !ok {
		return
	}
	delete(sc.entries, name)
	entry.cancel()
}
