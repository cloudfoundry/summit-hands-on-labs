package main

import (
	"fmt"
	"net/http"
	"os"
)

func rootHandler(w http.ResponseWriter, r *http.Request) {

	name := os.Getenv("NAME")
	if len(name) == 0 {
		panic("No idea, what NAME is")
	}

	fmt.Fprintf(w, "Welcome, "+name+" ,to the  website!")
}

func main() {

	http.HandleFunc("/welcome", rootHandler)

	fs := http.FileServer(http.Dir("static/"))
	http.Handle("/", http.StripPrefix("/", fs))

	var port string
	port = os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}

	http.ListenAndServe(":"+port, nil)
}
