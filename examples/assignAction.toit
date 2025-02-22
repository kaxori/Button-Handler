/**
A simple example to show the usage of the ButtonHandler.


*/
import gpio
import button-handler show *


// GPIO ports of ESP32 prototype
GPIO_LED_RED ::= 2       // LED used to indicate button press
GPIO_LED_GREEN ::= 32    // LED used to indicate clicks, long press
GPIO_BUTTON ::= 4       // Push button (low active)


blink --led/gpio.Pin --nTimes/int :
  task ::
    nTimes.repeat:
      led.set 1
      sleep --ms=200
      led.set 0
      sleep --ms=300

main:
//  net.open
  print "\n\nTest ButtonHandler , action reassign\n"

  // IO initialisation
  led := gpio.Pin GPIO_LED_RED --output
  led2 := gpio.Pin GPIO_LED_GREEN --output
  pushButton := gpio.Pin GPIO_BUTTON --input --pull_up

  doHwTest := true
  buttonHandler := ButtonHandler pushButton
    --singleClickAction= ::
      print "CLICK"
      blink --led=led2 --nTimes=1

    --doubleClickAction= ::
      print "CLICK-CLICK"
      blink --led=led2 --nTimes=2

    --trippleClickAction= ::
      print "CLICK-CLICK-CLICK"
      blink --led=led2 --nTimes=3
      doHwTest = false

    --pressAction= :: led.set 1
    --releaseAction= :: led.set 0
    --longPressAction= ::
      print "LONG"
      task ::
        3.repeat:
          led2.set 1
          sleep --ms=20
          led2.set 0
          sleep --ms=30
        sleep --ms=20

  print "HW test - tripple click to exit"


  while doHwTest:
    sleep --ms=1000

  print "reassign actions"
  buttonHandler.assignAction --clearAll=true
    //--pressAction = null
    //--releaseAction = null
    //--singleClickAction = :: print "click"
    //--doubleClickAction = :: print "click 2"
    --trippleClickAction = ::
      print "click 3"
      blink --led=led --nTimes=3



  led.set 0
  led2.set 0
  print "play around with the button and see what happens ..."
  while true:
    sleep --ms=1000
