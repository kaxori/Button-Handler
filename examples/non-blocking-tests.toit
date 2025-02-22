/**
  Example in non-blocking mode. 
  While main task is in the event loop the button service task runs asynchronously to detect button events.
*/
import .hw-c3-super-mini
import button_handler show *


button := ButtonService --gpio=GPIO-ONBOARD-BOOT-BUTTON --low-active
button2 := ButtonService --gpio=GPIO-BUTTON2 --low-active --debounce-ms=120




main:
  button2.set-press-action :: log_ "PRESS"
  button2.set-release-action :: log_ "RELEASE"
  button2.set-long-press-action :: log_ "LONG PRESS"
  button2.set-single-click-action :: log_ "CLICK"
  button2.set-double-click-action :: log_ "DOUBLE CLICK"
  button2.set-many-click-action :: |clicks|log_ "MANY CLICK $clicks"
  button2.start-service

  // event loop
  30.repeat: 
    sleep --ms=1_000

  
  

log_ msg /string:
  time := Time.now.local
  time-str := "$(%02d time.h):$(%02d time.m):$(%02d time.s).$(%03d time.ns/1000000)"
  print "$time-str: $msg"