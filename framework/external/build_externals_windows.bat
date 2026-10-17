@echo on

pushd ogg-vorbis
call build_ogg-vorbis.bat no_pause
popd

pushd curl
call build_curl.bat no_pause
popd

pushd imgui
call build_imgui.bat no_pause
popd

:: Done
pause
