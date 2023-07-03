# Button_Handler

Generates different click actions from button state changes.

## Install
```
jag pkg install button_handler
```

## examples 

A simple usage example.
``` toit
import gpio
import buttonHandler show *

main:
  pushButton := gpio.Pin GPIO_BUTTON --input --pull_up
  buttonHandler := ButtonHandler pushButton
    --singleClickAction= :: 
      print "CLICK"
  ...
```
See the `examples` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kaxori/Button-Handler/issues