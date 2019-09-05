package main

import (
	"fmt"
	"net/http"
	"os"
)

func rootHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to my website!")
}

func main() {

	http.HandleFunc("/main", rootHandler)

	fs := http.FileServer(http.Dir("static/"))
	http.Handle("/", http.StripPrefix("/", fs))

	var port string
	port = os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}

	http.ListenAndServe(":"+port, nil)
}
