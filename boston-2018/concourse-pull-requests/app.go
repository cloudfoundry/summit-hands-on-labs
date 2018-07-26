package main

import (
	"bytes"
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/nanobox-io/golang-scribble"
)

type App struct {
	Router *mux.Router
	DB     *scribble.Driver
}

func (a *App) Initialize(version string, db_path string) {
	a.DB, _ = scribble.New(db_path, nil)
	a.Router = mux.NewRouter()
	a.initializeRoutes()
}
func (a *App) Run(addr string) {
	http.ListenAndServe(":8000", a.Router)
}
func (a *App) initializeRoutes() {
	// TODO uncomment
	//  a.Router.HandleFunc("/todos/", a.getAll).Methods("GET")
	a.Router.HandleFunc("/todo/{id}", a.getToDo).Methods("GET")
	a.Router.HandleFunc("/todo/finish/{id}", a.finishToDo).Methods("PUT")
	a.Router.HandleFunc("/todo/", a.putToDo).Methods("PUT")
}
func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}
func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, _ := json.Marshal(payload)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}
func (a *App) finishToDo(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	_, err := uuid.Parse(vars["id"])
	if err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid toDo ID")
		return
	}
	toDo := ToDo{UID: vars["id"]}
	toDo.getToDo(a.DB)
	toDo.finish(a.DB)
	buf := new(bytes.Buffer)
	json.NewEncoder(buf).Encode(&toDo)
	respondWithJSON(w, http.StatusOK, toDo)
}

func (a *App) putToDo(w http.ResponseWriter, r *http.Request) {
	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
	toDo := ToDo{}
	json.NewDecoder(buf).Decode(&toDo)
	toDo.putToDo(a.DB)
	json.NewEncoder(buf).Encode(&toDo)
	respondWithJSON(w, http.StatusOK, toDo)
}
func (a *App) getToDo(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	_, err := uuid.Parse(vars["id"])
	if err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid toDo ID")
		return
	}
	toDo := ToDo{UID: vars["id"]}
	toDo.getToDo(a.DB)
	buf := new(bytes.Buffer)
	json.NewEncoder(buf).Encode(&toDo)
	respondWithJSON(w, http.StatusOK, toDo)
}

//func (a *App) getAll(w http.ResponseWriter, r *http.Request) {
//  toDos := make(ToDoCollection,0)
//  toDos.getAll(a.DB)
//  buf := new(bytes.Buffer)
//  json.NewEncoder(buf).Encode(&toDos)
//  respondWithJSON(w, http.StatusOK, toDos)
//}
