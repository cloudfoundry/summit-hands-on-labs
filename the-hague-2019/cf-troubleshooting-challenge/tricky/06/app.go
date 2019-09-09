package main

import (
	"fmt"
	"net/http"
	"os"
)

func rootHandler(w http.ResponseWriter, r *http.Request) {
	resultSum := 0
	resultMulty := 0
	for i := 1; i < 100000000000; i++ {
		resultSum += i
		resultMulty *= i
	}
	fmt.Println(resultMulty)
	fmt.Fprintf(w, "Welcome to my website!")
}

func main() {

	http.HandleFunc("/", rootHandler)

	fs := http.FileServer(http.Dir("static/"))
	http.Handle("/static", http.StripPrefix("/", fs))

	var port string
	port = os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}

	http.ListenAndServe(":"+port, nil)
}
