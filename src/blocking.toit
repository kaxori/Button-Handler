
/**

button press:
button release:
button click:

*/
import log
import gpio show *

import esp32
//import .button_service


/**
ButtonHandler
Analyses button events and calls defined user code.
- 
*/
class ButtonHandler:

  static DEBUG /bool ::= false
  
  static ENDLESS /int ::= 0
  static DEBOUNCE-PERIOD-MS /int ::= 20       // 
  static CLICK-END-PERIOD-MS /int ::= 400     // adapt this value to pressing speed: higher value allow slower clicks
  static LONG-PRESS-PERIOD-MS /int ::= 1000   // long press event after this press period


  gpio := ?
  debounce-ms /int
  is-low-active /bool := ?
  pin := ?
  logger_ /log.Logger



  constructor 
      --.gpio 
      --.debounce-ms/int=DEBOUNCE-PERIOD-MS
      --low_active=null
      --logger /log.Logger = (log.default.with_name "button-handler")
      :

    logger_ = logger
    is-low-active = low-active != null
    
    if is-low-active:
      pin = Pin gpio --input --pull-up=true
    else:
      pin = Pin gpio --input --pull-down=true

    if DEBUG:
      log_ """
      ButtonHandler:
      \t- gpio: $gpio
      \t- debounce: $debounce-ms ms
      \t- low active: $is-low-active
      """
    else: print "ButtonHandler: DEBUG off"




  /*
    MotionSensor is unkown by default
    a polling handler task handles state changes
    if it caused wakeup than trigger changes state to activated
  */
  is-pressed -> bool:
    button-is-pressed := is_low_active ? pin.get == 0 : pin.get == 1
    log_ "button-is-pressed: $button-is-pressed"
    return button-is-pressed


  /**
  Waits until the button is pressed.
    If 
  */
  wait-for-press --timeout/Duration?=null -> Duration:
    log_ "wait for button press .."
    start_ := esp32.total-run-time
    e := catch: 
      with-timeout timeout:
        wait-for-activation_; log_ "pressed"
    if e:  log_ "timeout"
    return Duration --us=(esp32.total-run-time - start_)


  wait-for-release --timeout/Duration?=null -> Duration:
    log_ "wait for button release .."
    //wait-for-deactivation_; log_ "released" 

    start_ := esp32.total-run-time
    e := catch: 
      with-timeout timeout:
        wait-for-deactivation_; log_ "released"
    if e:  log_ "timeout"
    return Duration --us=(esp32.total-run-time - start_)



  /** 
  Wait for complete press/release cycle. 
  */
  wait-for-click --timeout/Duration?=null -> Duration:
    log_ "wait for click"
    start_ := esp32.total-run-time
    e :=catch: 
      with-timeout timeout:
        wait-for-activation_; log_ "pressed"
        wait-for-deactivation_; log_ "released"
    if e:  log_ "timeout"
    return Duration --us=(esp32.total-run-time - start_)



  // -----private functions -------------------------------------------
  log_ msg /string:
    if DEBUG: 
      time := Time.now.local
      time-str := "$(%02d time.h):$(%02d time.m):$(%02d time.s).$(%03d time.ns/1000000)"
      logger_.debug "$time-str: $msg"


  /** Wait a defined period of time to skip the bouncing phase. */
  debounce_: 
    sleep --ms=debounce-ms

  /** wait until the button is pressed. */
  wait-for-activation_: 
    pin.wait_for (is-low-active ? 0 : 1)
    debounce_

  /** wait until the button is released. */
  wait-for-deactivation_: 
    pin.wait_for (is-low-active ? 1 : 0)
    debounce_
