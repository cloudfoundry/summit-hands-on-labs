package main

import (
	"net/http"
	"io"
	"os"
	"io/ioutil"
)

func main() {
	g := NewGenerator() // the expensive process

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {

		file := GetCachePath(req)

		if !InCache(file) {
			// cache the data
			f, _ := ioutil.TempFile(CacheRoot, "cache")
			f.Write(g.Run(req))
			f.Close()
		}

		// satisfy request from cache
		f, _ := os.Open(file)
		io.Copy(w, f)
		f.Close()
	})

	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
