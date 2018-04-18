package main

import (
	"fmt"
	"net/http"
	"crypto/tls"
	"os"
)

func main() {
	endpoint := os.Getenv("GET_ENDPOINT_URL")
	if endpoint == "" {
		fmt.Fprintf(os.Stderr, "No GET_ENDPOINT_URL environment variable specified!\n")
		fmt.Fprintf(os.Stderr, "This app needs to know where to make b2b requests to...\n")
		fmt.Fprintf(os.Stderr, "bailing out...\n")
		os.Exit(1)
	}

	c := http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		req, _ := http.NewRequest("GET", endpoint, nil)
		go c.Do(req)

		w.WriteHeader(200)
		fmt.Fprintf(w, "backend process started!\n")
	})
	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
