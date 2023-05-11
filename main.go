// ----------------------------------------------------------------------------
//  Name         : Proxy Bridge
//  Desc         : Proxy Bridge using Golang
//  Author       : Wildy Sheverando [Wildy2832]
//  Date         : 03-03-2023
//  License      : GNU General Public License V3
//  License Link : https://raw.githubusercontent.com/wildy2832/lcn/main/gplv3
// ----------------------------------------------------------------------------

package main

import (
    "io"
    "log"
    "net"
    "time"
)

func main() {
    // Configuration
    host := "127.0.0.1"
    port := "22"
    listen := "80"

var _defaultPage = []byte(`
<!DOCTYPE html>
<html>
<head>
<title>Welcome to opensocks!</title>
</head>
<body>
<p>Welcome to opensocks!</p>
</body>
</html>`)

    // Listen new bridged port
    ln, err := net.Listen("tcp", ":"+listen)
    if err != nil {
        log.Fatal(err)
    }
    defer ln.Close() // Closing defer

    // Log for starting information
    log.Printf("Server started on port: %s\n", listen)
    log.Printf("Redirecting requests to: %s at port %s\n", host, port)

    for {
        // Conn handle
        conn, err := ln.Accept()
        if err != nil {
            log.Println(err)
            continue
        }

        // Log Output
        log.Printf("Connection received from %s:%s\n", conn.RemoteAddr().Network(), conn.RemoteAddr().String())

        go func(c net.Conn) {
            // Dial Target in tcp with time out
            dconn, err := net.DialTimeout("tcp", host+":"+port, 10*time.Second)
            if err != nil {
                log.Println(err)
                return
            }
            
            // Return HTTP Response Switching Protocols to client
            _, err = c.Write([]byte("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n\Content-Length: 99999999999999\Content-Type: text/html"))
            if err != nil {
                log.Println(err)
                return
            }

            // Copy client request to target (Forward)
            go func() {
                if _, err := io.Copy(dconn, c); err != nil {
                    log.Printf("Error copying data from client to destination server: %v\n", err)
                }
            }()

            // Copy Return from target to client
            if _, err := io.Copy(c, dconn); err != nil {
                log.Printf("Error copying data from destination server to client: %v\n", err)
            }

            // Log output
            log.Printf("Connection terminated for %s:%s\n", conn.RemoteAddr().Network(), conn.RemoteAddr().String())
        }(conn)
    }
}
