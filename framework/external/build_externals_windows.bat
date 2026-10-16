@echo on

pushd curl
call build_curl.bat no_pause
popd

:: Done
pause
