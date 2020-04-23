package main

import (
	"flag"
	"fmt"
	"net/http"
	"net/http/httputil"
)

type Pxy struct {
	pReverseProxy *httputil.ReverseProxy
}

func (p *Pxy) init() {
	p.pReverseProxy = &httputil.ReverseProxy{Director: p.director}
}

func (p *Pxy) director(r *http.Request) {
	fmt.Printf("client:%s %s %s\n", r.RemoteAddr, r.Method, r.Host)

	fmt.Printf("r.URL.Scheme:%s \n", r.URL.Scheme)
	fmt.Printf("r.URL.Host:%s \n", r.URL.Host)
	fmt.Printf("r.URL.Path:%s \n", r.URL.Path)

	if prior, ok := r.Header["X-Forwarded-For"]; ok {
		fmt.Println("prior:", prior)
	}
}

func (p *Pxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	p.pReverseProxy.ServeHTTP(w, r)
}

func main() {
	pstrListenAddr := flag.String("addr", ":8080", "listen addr")
	flag.Parse()

	fmt.Println("Serve on ", *pstrListenAddr)
	pPxy := &Pxy{}
	pPxy.init()
	http.ListenAndServe(*pstrListenAddr, pPxy)
}
