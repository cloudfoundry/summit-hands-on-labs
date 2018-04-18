package main_test

import (
	"."

	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
)

var a main.App
var valid_uids = make([]string, 0)

func TestMain(m *testing.M) {
	a = main.App{}
	a.Initialize(os.Getenv("APP_VERSION"), os.Getenv("DB_PATH"))
	fmt.Println("running tests")
	initDB(a)
	code := m.Run()
	os.Exit(code)

}
func initDB(a main.App) {
	// CLEAR DB FROM EARLIER RUNS
	a.DB.Delete("toDo", "")
	// CREATE MOCK TODO AND STORE UIDS IN SLICE
	uid := uuid.Must(uuid.NewRandom())
	valid_uids = append(valid_uids, uid.String())
	a.DB.Write("toDo", uid.String(), main.ToDo{Name: "first", UID: uid.String(), Created: time.Now().String(), Done: "unfinished"})
	uid = uuid.Must(uuid.NewRandom())
	valid_uids = append(valid_uids, uid.String())
	a.DB.Write("toDo", uid.String(), main.ToDo{Name: "second", UID: uid.String(), Created: time.Now().String(), Done: "unfinished"})
}

func TestFinishToDo(t *testing.T) {
	req, _ := http.NewRequest("PUT", "/todo/finish/"+valid_uids[0], nil)
	response := executeRequest(req)
	checkResponseCode(t, http.StatusOK, response.Code)

	if body := response.Body.String(); body == "[]" {
		t.Errorf("Expected an non empty answer. Got %s", body)
	} else {
		buf := new(bytes.Buffer)
		buf.ReadFrom(response.Body)
		toDo := main.ToDo{}
		json.NewDecoder(buf).Decode(&toDo)
		fmt.Println(toDo.Done)
	}
}
func TestGetToDo(t *testing.T) {
	req, _ := http.NewRequest("GET", "/todo/"+valid_uids[0], nil)
	response := executeRequest(req)
	checkResponseCode(t, http.StatusOK, response.Code)

	if body := response.Body.String(); body == "[]" {
		t.Errorf("Expected an non empty answer. Got %s", body)
	} else {
		buf := new(bytes.Buffer)
		buf.ReadFrom(response.Body)
		toDo := main.ToDo{}
		json.NewDecoder(buf).Decode(&toDo)
		fmt.Println(toDo.UID)
	}
}

//func TestGetAll(t *testing.T){
//  req, _ := http.NewRequest("GET", "/todos/", nil)
//  response := executeRequest(req)
//  checkResponseCode(t, http.StatusOK, response.Code)
//  if body := response.Body.String(); body == "[]" {
//    t.Errorf("Expected an non empty answer. Got %s", body)
//  }else{
//    buf := new(bytes.Buffer)
//    buf.ReadFrom(response.Body)
//    var toDos main.ToDoCollection
//    json.NewDecoder(buf).Decode(&toDos)
//    for _, toDo := range toDos{
//      fmt.Println(toDo.UID)
//    }
//  }
//}
func TestPutToDo(t *testing.T) {
	toDo := main.ToDo{Name: "Third", UID: "", Created: time.Now().String(), Done: "unfinished"}
	buf := new(bytes.Buffer)
	json.NewEncoder(buf).Encode(toDo)
	req, _ := http.NewRequest("PUT", "/todo/", buf)
	response := executeRequest(req)
	checkResponseCode(t, http.StatusOK, response.Code)

	if body := response.Body.String(); body == "[]" {
		t.Errorf("Expected an non empty array. Got %s", body)
	} else {
		json.NewDecoder(response.Body).Decode(&toDo)
		fmt.Println(toDo.UID)
	}
}

func executeRequest(req *http.Request) *httptest.ResponseRecorder {
	rr := httptest.NewRecorder()
	a.Router.ServeHTTP(rr, req)
	return rr
}
func checkResponseCode(t *testing.T, expected, actual int) {
	if expected != actual {
		t.Errorf("Expected response code %d. Got %d\n", expected, actual)
	}
}
