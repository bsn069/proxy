package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"proxy/socks5"
)

func main() {
	pstrListenAddr := flag.String("addr", ":1080", "listen addr")
	pstrUser := flag.String("user", "user", "user name")
	pstrPwd := flag.String("pwd", "pwd", "password")
	flag.Parse()
	fmt.Println("Serve on ", *pstrListenAddr)

	creds := socks5.StaticCredentials{
		*pstrUser: *pstrPwd,
	}
	cator := socks5.UserPassAuthenticator{Credentials: creds}
	conf := &socks5.Config{
		AuthMethods: []socks5.Authenticator{cator},
		Logger:      log.New(os.Stdout, "", log.LstdFlags),
	}

	conf = &socks5.Config{}
	server, err := socks5.New(conf)
	if err != nil {
		panic(err)
	}

	if err := server.ListenAndServe("tcp", *pstrListenAddr); err != nil {
		panic(err)
	}
}
