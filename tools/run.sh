#!/bin/bash
# Test run: start the game, stop it after SECS seconds (default 30), show the end of the log and a symbolized guest
# backtrace. Silent and hidden by default (ITPRECOMP_NO_AUDIO=0 / SHOW=1 to change that). Test runs use a scratch
# save folder (build/testsave, emptied first unless KEEPSAVE=1) and never touch save/.
# Extra ITPRECOMP_* variables pass through. Linux without system packages: build/deps-linux/lib is on the library path.
cd "$(dirname "$0")/.."
SECS=${SECS:-30}
export ITPRECOMP_NO_AUDIO=${ITPRECOMP_NO_AUDIO:-1} ITPRECOMP_NO_MOVIE_AUDIO=${ITPRECOMP_NO_MOVIE_AUDIO:-1}
export ITPRECOMP_NO_LAUNCHER=1
[ -z "$SHOW" ] && export ITPRECOMP_HIDDEN=1
# (Wayland: SDL's libdecor-gtk plugin aborts on this desktop's GTK settings schema; XWayland works)
export SDL_VIDEO_DRIVER=${SDL_VIDEO_DRIVER:-x11}
[ -d build/deps-linux/lib ] && export LD_LIBRARY_PATH="$PWD/build/deps-linux/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
[ -z "$KEEPSAVE" ] && rm -rf build/testsave
mkdir -p build/testsave
export ITPRECOMP_SAVE_DIR=build/testsave
LOG=${LOG:-build/run.log}
${RUNPREFIX} ./build/itprecomp extracted > "$LOG" 2>&1 &
PID=$!
for i in $(seq 1 "$SECS"); do sleep 1; kill -0 $PID 2>/dev/null || break; done
kill -9 $PID 2>/dev/null && echo "(still running after ${SECS}s, killed)"
wait $PID 2>/dev/null
grep -v "^\[svc\]" "$LOG" | grep -v "host backtrace" | tail -"${TAIL:-40}"
grep -q "itpgame.so+" "$LOG" && { echo "guest call stack:"; (cd tools && ./venv/bin/python symgame.py "../$LOG"); }
exit 0
