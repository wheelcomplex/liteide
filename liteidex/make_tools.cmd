@echo off

if defined %GOPATH (
	set GOPATH=%CD%;%GOPATH%
) else (
	set GOPATH=%CD%
)

go install -ldflags "-s" -v github.com/visualfc/gotools
go install -ldflags "-s" -v github.com/nsf/gocode
