#!/bin/bash
# Godot를 터미널에서 실행하여 크래시 로그 확인
/Applications/Godot.app/Contents/MacOS/Godot --path . 2>&1 | tee godot_crash.log
