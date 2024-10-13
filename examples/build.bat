@echo off
setlocal enabledelayedexpansion

SET build_type=-debug
SET compile_flags=-vet
SET build_dir=..\build

if not exist "%build_dir%" mkdir "%build_dir%"

for /d %%F in (*) do (
    echo Building: %%F
    
    if exist "%build_dir%\%%F" (
        rmdir /s /q "%build_dir%\%%F"
    )

    mkdir "%build_dir%\%%F"

    odin build "%%F" %build_type% %compile_flags% -collection:actrune=../actrune -out:"%build_dir%\%%F\%%F.exe"
)
