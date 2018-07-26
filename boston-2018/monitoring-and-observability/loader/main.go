package main

import (
	"crypto/tls"
	"fmt"
	"strings"
	"strconv"
	"time"
	"net/http"
	"os"
)

type Endpoint struct {
	N uint64
	URL string
}

func main() {
	ok := true
	ee := make([]Endpoint, 0)

	for _, e := range os.Environ() {
		if strings.HasPrefix(e, "LOAD_TEST_") {
			l := strings.SplitN(e, "=", 2)
			ll := strings.SplitN(l[1], ":", 2)
			n, err := strconv.ParseUint(ll[0], 10, 64)
			if err != nil {
				fmt.Fprintf(os.Stderr, "%s -- invalid LOAD_TEST_* environment variable\n", e)
				ok = false
			}
			ee = append(ee, Endpoint{N: n, URL: ll[1]})
		}
	}

	if len(ee) == 0 {
		fmt.Fprintf(os.Stderr, "no LOAD_TEST_* env vars set...\n")
		fmt.Fprintf(os.Stderr, "try LOAD_TEST_SOMEONE=300000:https://example.com\n")
		ok = false
	}

	if !ok {
		fmt.Fprintf(os.Stderr, "unable to continue...\n")
		os.Exit(1)
	}

	c := http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}
	for _, e := range ee {
		go func (u string, n uint64) {
			t := time.NewTicker(time.Duration(e.N) * time.Millisecond)
			for _ = range t.C {
				if (n >= 1000) {
					fmt.Printf("LOAD: GET %s\n", u)
				}
				go func () {
					req, err := http.NewRequest("GET", u, nil)
					if err != nil {
						fmt.Fprintf(os.Stderr, "GET %s failed: %s\n", u, err)
						return
					}
					res, err := c.Do(req)
					if err != nil {
						fmt.Fprintf(os.Stderr, "GET %s failed: %s\n", u, err)
						return
					}
					res.Body.Close()
				}()
			}
		}(e.URL, e.N)
	}

	fmt.Printf("waiting patiently...\n")
	<-make(chan int, 0)
}
