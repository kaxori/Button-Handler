/**
  Example in non blocking mode. 
  While main task is in the event loop the button service task runs asynchronously to detect button events.
*/

import .hw-c3-super-mini
import button_handler show *

button := ButtonService --gpio=GPIO-ONBOARD-BOOT-BUTTON --low-active
button2 := ButtonService --gpio=GPIO-BUTTON2 --low-active --debounce-ms=120

main:
  print "\n\n\nsimple button-handler test\n"

  button2.start-service
  button2.set-press-action :: print "PRESS"
  button2.set-release-action :: print "RELEASE"


  // event loop
  30.repeat: 
    sleep --ms=1_000

  button2.stop-service
  print "done.\n"
