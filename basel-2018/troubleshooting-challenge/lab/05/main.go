package main

import (
	"fmt"
	"net/http"
	"os"
)

func CFSummit(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello Cloud Foundry Summit @ Bazel!");
}

func main() {
	http.HandleFunc("/", CFSummit);
	os.Getpid();

	port := "8081";

	http.ListenAndServe(":" + port, nil);
}