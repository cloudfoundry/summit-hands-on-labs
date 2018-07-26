package main

import (
	"time"
	"io/ioutil"
	"fmt"
	"net/http"
	"strings"
	"regexp"
	"strconv"
	"os"
)

// used by ioutil.TempFile in cache
var CacheRoot = "/tmp"

func GetCachePath(req *http.Request) string {
	return CacheRoot + "/" + strings.Replace("/", "-", req.URL.Path, -1)
}

func InCache(path string) bool {
	_, err := os.Stat(path)
	return err != nil && os.IsNotExist(err)
}

type Generator  []byte

func (g Generator) Run(req *http.Request) []byte {
	return []byte(g)
}

func NewGenerator() Generator {
	size := "1M"
	if v := os.Getenv("CACHE_BLOCK"); v != "" {
		size = v
	}

	n := 5 * 1024 * 1024
	re := regexp.MustCompile(`^(\d+)([KMG])$`)
	if m := re.FindStringSubmatch(size); m != nil {
		magnitude, err := strconv.ParseUint(m[1], 10, 64)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Invalid CACHE_BLOCK '%s', aborting...\n", size)
			os.Exit(1)
		}
		n = int(magnitude)
		switch m[2] { // "K", "M", etc.
		case "K":
			n *= 1024
		case "M":
			n *= 1024 * 1024
		case "G":
			n *= 1024 * 1024 * 1024
		}
	}

	buf := make([]byte, n)
	for i := 0; i < 8192; i++ {
		buf[i] = byte(i % 255)
	}

	// start a canary to die within 90s of disk quota exceeded
	go func () {
		t := time.NewTicker(90 * time.Second)
		for _ = range t.C {
			fmt.Printf("checking on disk space...\n")
			f, err := ioutil.TempFile(CacheRoot, "canary")
			if err != nil {
				fmt.Fprintf(os.Stderr, "ran out of disk space: %s\n", err)
				os.Exit(1)
			}
			f.Close()
			os.Remove(f.Name())
		}
	}()

	return Generator(buf)
}
