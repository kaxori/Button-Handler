// Copyright (C) 2023 kaxori.
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

import log
import gpio
import gpio.pin
import action_repeater show *


/*
==> TODO

class ButtonHandlerActions:
  actions_ /List? := null

  static PRESS ::= 0
  static RELEASE ::= 1
  static LONG ::= 2
  static SINGLE_CLICK ::= 3
  static DOUBLE_CLICK ::= 4
  static TRIPPLE_CLICK ::= 5

  static SIZE_ACTIONS ::= 6


  constructor
      --pressAction /Lambda? = null
      --releaseAction /Lambda? = null
      --longPressAction /Lambda? = null
      --singleClickAction  /Lambda? = null
      --doubleClickAction  /Lambda? = null
      --trippleClickAction  /Lambda? = null
      :
      actions_ = List SIZE_ACTIONS null
      print "actions constructed"
      actions_[PRESS] = pressAction
      actions_[RELEASE] = releaseAction
      actions_[LONG] = longPressAction
      actions_[SINGLE_CLICK] = singleClickAction
      actions_[DOUBLE_CLICK] = doubleClickAction
      actions_[TRIPPLE_CLICK] = trippleClickAction
      debug


  constructor actions /ButtonHandlerActions
    :
    null
    print "copy constructor"
    debug


  debug:
    print "ButtonHandlerActions debug: $(actions_)"
    actions_.do:
      if it != null:
        print "$(it)"

*/


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

  logger_ /log.Logger
  label_ /string




  constructor .button_/gpio.Pin
      --pressAction /Lambda? = null
      --releaseAction /Lambda? = null
      --singleClickAction  /Lambda? = null
      --doubleClickAction  /Lambda? = null
      --trippleClickAction  /Lambda? = null
      --longPressAction /Lambda? = null
      --logger /log.Logger = (log.default.with_name "button handler")
      --label /string = ""
      :

    logger_ = logger
    label_ = label

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

    logger_.debug "$label_: constructed"


    /**
    Detects long press event.
    */
    pressPeriod_ = ActionRepeater --label="press period" --timespan_ms=LONG_PRESS_PERIOD --action= ::
        logger_.debug "$label_: press timing"
        ++longpressCount_
        if longPressAction_: longPressAction_.call


    /**
    Detects button release and performs registered action.
    */
    releasePeriod_ = ActionRepeater --label="release period" --timespan_ms=LONG_PRESS_PERIOD --action= ::
      logger_.debug "$label_: release timing"
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


  /**
  Re-Assigns actions to button events. Optionally all previously registered action are cleared.
  */
  assignAction --clearAll /bool = false
      --pressAction /Lambda? = null
      --releaseAction /Lambda? = null
      --singleClickAction  /Lambda? = null
      --doubleClickAction  /Lambda? = null
      --trippleClickAction  /Lambda? = null
      --longPressAction /Lambda? = null
    :

    logger_.debug "$label_: assignAction"
    if clearAll:
      pressAction_ = releaseAction_ = longPressAction_ = \
        singleClickAction_ = doubleClickAction_ = trippleClickAction_ = null
      logger_.debug "$label_: all actions cleared"

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


  //assignActions actions /ButtonHandlerActions:



  /**
  Starts press timing period and performs registered action.
  */
  buttonPressed_:
    pressPeriod_.start
    if pressAction_ != null: pressAction_.call

  /**
  Stops press timing period, starts release timing period and performs registered action.
  */
  buttonReleased_:
    pressPeriod_.stop
    releasePeriod_.start
    if longpressCount_ == 0: ++clickCount_
    if releaseAction_ != null: releaseAction_.call
