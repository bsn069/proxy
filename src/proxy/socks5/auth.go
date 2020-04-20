package socks5

import (
	"fmt"
	"io"
)

const (
	NoAuth          = uint8(0)
	noAcceptable    = uint8(255)
	UserPassAuth    = uint8(2)
	userAuthVersion = uint8(1)
	authSuccess     = uint8(0)
	authFailure     = uint8(1)
)

var (
	UserAuthFailed  = fmt.Errorf("User authentication failed")
	NoSupportedAuth = fmt.Errorf("No supported authentication mechanism")
)

// A Request encapsulates authentication state provided
// during negotiation
type AuthContext struct {
	// Provided auth method
	Method uint8
	// Payload provided during negotiation.
	// Keys depend on the used auth method.
	// For UserPassauth contains Username
	Payload map[string]string
}

type Authenticator interface {
	Authenticate(reader io.Reader, writer io.Writer) (*AuthContext, error)
	GetCode() uint8
}

// NoAuthAuthenticator is used to handle the "No Authentication" mode
type NoAuthAuthenticator struct{}

func (a NoAuthAuthenticator) GetCode() uint8 {
	return NoAuth
}

func (a NoAuthAuthenticator) Authenticate(reader io.Reader, writer io.Writer) (*AuthContext, error) {
	_, err := writer.Write([]byte{socks5Version, NoAuth})
	return &AuthContext{NoAuth, nil}, err
}

// UserPassAuthenticator is used to handle username/password based
// authentication
type UserPassAuthenticator struct {
	Credentials CredentialStore
}

func (a UserPassAuthenticator) GetCode() uint8 {
	return UserPassAuth
}

func (a UserPassAuthenticator) Authenticate(reader io.Reader, writer io.Writer) (*AuthContext, error) {
	// Tell the client to use user/pass auth
	if _, err := writer.Write([]byte{socks5Version, UserPassAuth}); err != nil {
		return nil, err
	}

	// Get the version and username length
	header := []byte{0, 0}
	if _, err := io.ReadAtLeast(reader, header, 2); err != nil {
		return nil, err
	}

	// Ensure we are compatible
	if header[0] != userAuthVersion {
		return nil, fmt.Errorf("Unsupported auth version: %v", header[0])
	}

	// Get the user name
	userLen := int(header[1])
	user := make([]byte, userLen)
	if _, err := io.ReadAtLeast(reader, user, userLen); err != nil {
		return nil, err
	}

	// Get the password length
	if _, err := reader.Read(header[:1]); err != nil {
		return nil, err
	}

	// Get the password
	passLen := int(header[0])
	pass := make([]byte, passLen)
	if _, err := io.ReadAtLeast(reader, pass, passLen); err != nil {
		return nil, err
	}

	// Verify the password
	if a.Credentials.Valid(string(user), string(pass)) {
		if _, err := writer.Write([]byte{userAuthVersion, authSuccess}); err != nil {
			return nil, err
		}
	} else {
		if _, err := writer.Write([]byte{userAuthVersion, authFailure}); err != nil {
			return nil, err
		}
		return nil, UserAuthFailed
	}

	// Done
	return &AuthContext{UserPassAuth, map[string]string{"Username": string(user)}}, nil
}

// authenticate is used to handle connection authentication
func (s *Server) authenticate(conn io.Writer, bufConn io.Reader) (*AuthContext, error) {
	fmt.Println("处理连接认证")

	// Get the methods
	fmt.Println("获取客户端支持的认证类型")
	methods, err := readMethods(bufConn)
	if err != nil {
		return nil, fmt.Errorf("Failed to get auth methods: %v", err)
	}

	// Select a usable method
	fmt.Println("从客户端上发的支持的认证列表中 选取服务器也支持的认证方法")
	for _, method := range methods {
		cator, found := s.authMethods[method]
		if found {
			fmt.Println("找到匹配的认证方法", method)
			return cator.Authenticate(bufConn, conn)
		}
	}

	// No usable method found
	fmt.Println("未找到匹配的认证方法")
	return nil, noAcceptableAuth(conn)
}

// noAcceptableAuth is used to handle when we have no eligible
// authentication mechanism
func noAcceptableAuth(conn io.Writer) error {
	fmt.Println("回复客户端，没找到匹配的认证方法", socks5Version, noAcceptable)
	conn.Write([]byte{socks5Version, noAcceptable})
	return NoSupportedAuth // 不支持的认证方法
}

// readMethods is used to read the number of methods
// and proceeding auth methods
func readMethods(r io.Reader) ([]byte, error) {
	fmt.Println("获取连接认证方法数")

	header := []byte{0}
	if _, err := r.Read(header); err != nil {
		return nil, err
	}

	numMethods := int(header[0])
	fmt.Println("客户端支持的认证方法数 1字节", numMethods)
	methods := make([]byte, numMethods)
	_, err := io.ReadAtLeast(r, methods, numMethods)
	fmt.Println("认证方法类型数组", numMethods)
	return methods, err
}
