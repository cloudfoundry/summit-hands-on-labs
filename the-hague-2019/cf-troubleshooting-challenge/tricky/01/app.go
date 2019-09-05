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
	port = "80"
	if len(port) == 0 {
		port = "80"
	}

	http.ListenAndServe(":"+port, nil)
}
