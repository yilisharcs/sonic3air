@echo on

pushd curl
call build_curl.bat no_pause
popd

pushd imgui
call build_imgui.bat no_pause
popd

:: Done
pause
