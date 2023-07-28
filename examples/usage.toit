/**
A simple example to show the usage of the ButtonHandler.


# used HW devices:
- Pushbutton, low active, connected to GPIO.
- LED, high active, connected to GPIO.

Adapt GPIO to support your controller setup.



*/

import log
import ..src.button_handler show *
import gpio
//import button_handler show *



// GPIO ports of ESP32 prototype
GPIO_LED_RED ::= 7       // LED used to indicate button press
GPIO_LED_GREEN ::= 8    // LED used to indicate clicks, long press
GPIO_BUTTON ::= 21       // Push button (low active)


blink --led/gpio.Pin --nTimes/int :
  task ::
    nTimes.repeat:
      led.set 1
      sleep --ms=200
      led.set 0
      sleep --ms=300

main:
  //logger ::= log.Logger log.WARN_LEVEL log.DefaultTarget --name="usage"
  log.set_default (log.default.with_level 3)

  logger := log.default
  logger.with_level log.WARN_LEVEL  // DOES NOT WORK

  
  logger.info "example usage ..."
  logger.info "synchronized" --tags={
    "adjustment": 1,
    "time": 2,
  }


//  net.open
  print "\n\nTest ButtonHandler \n"
    
  // IO initialisation
  led := gpio.Pin GPIO_LED_RED --output
  led2 := led //gpio.Pin GPIO_LED_GREEN --output
  pushButton := gpio.Pin GPIO_BUTTON --input --pull_up


  buttonHandler := ButtonHandler pushButton
    //--logger=logger
    --label="button1"
    --singleClickAction= :: 
      print "CLICK"
      blink --led=led2 --nTimes=1

    --doubleClickAction= :: 
      print "CLICK-CLICK"
      blink --led=led2 --nTimes=2

    --trippleClickAction= :: 
      print "CLICK-CLICK-CLICK"
      blink --led=led2 --nTimes=3

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


  led.set 0
  led2.set 0
  print "play around with the button and see what happens ..."
  while true:
    sleep --ms=1000