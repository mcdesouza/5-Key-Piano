# 5-Key Piano Using TI TM4C123GXL Microcontroller

This project demonstrates the implementation of a 5-key piano using the Texas Instruments **TM4C123GXL microcontroller**. The project is written in **ARM assembly** and developed in **Keil MicroVision**. It features external buttons and a buzzer that plays different frequencies corresponding to the pressed buttons. LEDs are used for visual feedback.
Project Features

## How It Works

    Hardware Setup:
        Buttons are connected to Port E (PE1–PE5) and pull-up resistors are enabled internally.
        LEDs are connected to the respective button pins for visual feedback.
        A buzzer is connected to PE0.

    Software Functionality:
        Timers are initialized to generate precise delays for the square wave output.
        When a button is pressed, the corresponding frequency is generated on PE0, creating a square wave to drive the buzzer.
        LEDs light up to indicate which button is pressed.

    Frequency Mapping:
    Each button corresponds to a unique frequency:
        Button 1 (PE1): Frequency 1
        Button 2 (PE2): Frequency 2
        Button 3 (PE3): Frequency 3
        Button 4 (PE4): Frequency 4
        Button 5 (PE5): Frequency 5

## Requirements

    Hardware:
        TI TM4C123GXL microcontroller.
        5 external push-buttons.
        5 LEDs.
        1 buzzer.
        Resistors as needed.

    Software:
        Keil MicroVision IDE.

## Demo

[[Link to Demo Video](https://drive.google.com/file/d/1lXPweoQZdbN_PKs7lyyIJh9niNJhGgYO/view?usp=sharing)]
How to Use

    Clone or download the repository.
    Open the project in Keil MicroVision.
    Connect the hardware as described above.
    Compile and flash the code onto the TM4C123GXL microcontroller.
    Press the buttons to hear corresponding tones and see LED feedback.

Project Files

    Lab3.uvprojx: ARM assembly code for the project.

