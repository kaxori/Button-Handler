// Copyright (C) 2023 kaxori.
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

import gpio
import gpio.pin
import actionRepeater show *


/**
ButtonHandler
Analyses button events and calls defined user code.

- 
*/
class ButtonHandler:
  static LONG_PRESS_PERIOD ::= 500
  static CLICK_END_PERIOD ::= 200

  button_ /gpio.Pin := ?
  pressAction_ /Lambda? := null
  releaseAction_ /Lambda? := null
  singleClickAction_ /Lambda? := null
  doubleClickAction_ /Lambda? := null
  trippleClickAction_ /Lambda? := null
  longPressAction_ /Lambda? := null
  
  handler_ /Task? := null

  pressPeriod_ /ActionRepeater? := null
  releasePeriod_ /ActionRepeater? := null

  longpressCount_ /int := 0
  clickCount_ /int := 0


  constructor .button_/gpio.Pin 
      --pressAction /Lambda? = null 
      --releaseAction /Lambda? = null
      --singleClickAction  /Lambda? = null
      --doubleClickAction  /Lambda? = null
      --trippleClickAction  /Lambda? = null
      --longPressAction /Lambda? = null
      :


    if pressAction != null:
      pressAction_ = pressAction 
  
    if releaseAction != null:
      releaseAction_ = releaseAction

    if longPressAction != null:
      longPressAction_ = longPressAction

    if singleClickAction != null:
      singleClickAction_ = singleClickAction

    if doubleClickAction != null:
      doubleClickAction_ = doubleClickAction

    if trippleClickAction != null:
      trippleClickAction_ = trippleClickAction

    handler_ = task::
      while true:
        // low active push button
        button_.wait_for 0
        buttonPressed_
        button_.wait_for 1
        buttonReleased_

    pressPeriod_ = ActionRepeater --timeout_ms=LONG_PRESS_PERIOD --action= ::
      ++longpressCount_
      if longPressAction_: longPressAction_.call


    releasePeriod_ = ActionRepeater --timeout_ms=LONG_PRESS_PERIOD --action= ::
      pressPeriod_.stop
      releasePeriod_.stop

      if clickCount_ == 1:
        if singleClickAction_: singleClickAction_.call
      else if clickCount_ == 2:
        if doubleClickAction_: doubleClickAction_.call
      else if clickCount_ == 3:
        if trippleClickAction_: trippleClickAction_.call

      // cleanup
      if releaseAction_ != null: releaseAction_.call
      clickCount_ = 0
      longpressCount_ = 0


  buttonPressed_:
    pressPeriod_.start
    if pressAction_ != null: pressAction_.call

  buttonReleased_:
    pressPeriod_.stop
    releasePeriod_.start
    if longpressCount_ == 0: ++clickCount_
    if releaseAction_ != null: releaseAction_.call