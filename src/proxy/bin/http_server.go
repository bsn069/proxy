package main

import (
	"flag"
	"fmt"
	"net/http"
)

type Pxy struct {
}

func (p *Pxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("client:%s %s %s\n", r.RemoteAddr, r.Method, r.Host)

	fmt.Printf("r.URL.Scheme:%s \n", r.URL.Scheme)
	fmt.Printf("r.URL.Host:%s \n", r.URL.Host)
	fmt.Printf("r.URL.Path:%s \n", r.URL.Path)

	if prior, ok := r.Header["X-Forwarded-For"]; ok {
		fmt.Println("prior:", prior)
	}

	fmt.Fprintf(w, "OK")
}

func main() {
	pstrListenAddr := flag.String("addr", ":80", "listen addr")
	flag.Parse()

	fmt.Println("Serve on ", *pstrListenAddr)
	pPxy := &Pxy{}
	http.ListenAndServe(*pstrListenAddr, pPxy)
}
