package main

/*
curl --proxy-user user:pwd --socks5 localhost:1080 http://127.0.0.1
*/

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
		// AuthMethods: []socks5.Authenticator{cator, socks5.NoAuthAuthenticator{}},
		Logger: log.New(os.Stdout, "", log.LstdFlags),
	}

	server, err := socks5.New(conf)
	if err != nil {
		panic(err)
	}

	if err := server.ListenAndServe("tcp", *pstrListenAddr); err != nil {
		panic(err)
	}
}
