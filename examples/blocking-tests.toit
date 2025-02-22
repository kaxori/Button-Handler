/**
  Example in blocking mode. 
  While waiting execution of main task is blocked.
*/
import .hw-c3-super-mini
import button_handler show *

button := ButtonHandler --gpio=GPIO-ONBOARD-BOOT-BUTTON --low-active
button2 := ButtonHandler --gpio=GPIO-BUTTON2 --low-active --debounce-ms=120


main:
  print "\n\n\nsimple button-handler test\n"

  DURATION ::= (Duration --s=3)

  print "press button with $DURATION timeout"
  5.repeat:
    duration := button2.wait-for-press --timeout=DURATION
    if duration < DURATION:
      print "PRESSED"
      button2.wait-for-release
      print "RELEASED"

    else:
      print "TIMEOUT"


  print "button-click with timeout"
  5.repeat:
    duration := button2.wait-for-click --timeout=DURATION
    if duration >= DURATION:
      print "TIMEOUT"
    else:
      print "clicked in $duration.in-ms ms"

  print "done."