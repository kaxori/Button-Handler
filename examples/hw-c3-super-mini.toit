/*
IO layout ESP32-C3 Super Mini:

            [USB]
 5: MISO, A5  |    5V:
 6: MOSI      |    GND
 7: SS        |    3V3
 8: SDA, LED  |   4: A4
 9: SCL       |   3: A3
10:           |   2: A2
20: RX        |   1: A1
21: TX        |   0: A0     DHT22
             ANT


GP
IO: IO device
------------------
 8: I2C SDA  |
 9: I2C SCL  |
10: LED blau |  

*/

// onboard
GPIO-ONBOARD-LED-BLUE ::= 8       // collides with I2C-SDA
GPIO-ONBOARD-BOOT-BUTTON ::= 9    // collides with I2C SCL


GPIO-SDA ::= 8    // onboard LED
GPIO-SCL ::= 9

GPIO-LED-BLUE ::= 10
GPIO-DHT22 ::= 0   // DHT22


GPIO-BUTTON2 ::= 7