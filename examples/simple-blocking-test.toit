/**
  Example in blocking mode. While waiting execution of main task is blocked.
*/

import .hw-c3-super-mini
import button_handler show *

button := ButtonHandler --gpio=GPIO-ONBOARD-BOOT-BUTTON --low-active
button2 := ButtonHandler --gpio=GPIO-BUTTON2 --low-active --debounce-ms=120


main:
  print "\n\n\nsimple button-handler test\n"

  print "is pressed: $button2.is-pressed\n"

  print "wait for button press ..."
  button2.wait-for-press
  print "pressed\n"
  
  print "wait for button release ..."
  button2.wait-for-release
  print "released\n"
