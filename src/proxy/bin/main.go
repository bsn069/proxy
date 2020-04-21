package main

import (
	"fmt"
	"log"
	"os"
	"proxy/socks5"
)

func main() {
	fmt.Println(1)

	creds := socks5.StaticCredentials{
		"foo": "bar",
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

	if err := server.ListenAndServe("tcp", "127.0.0.1:11080"); err != nil {
		panic(err)
	}
}
