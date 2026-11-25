---
title: "Bot-Hoven"
subtitle: "A robot that plays the piano"
date: 2025-04-01
period: "August 2024 – May 2025"
weight: 10
status: stub
context: "Capstone, team of six, sponsored by PTx Trimble · IEEE Winnipeg Section 2nd Prize"
role: "ros2_control hardware interfaces (I2C and SPI), Raspberry Pi bring-up, and the Pico 2 stepper firmware"
coverAlt: "The finished robot: two hands on a rail above an 88-key keyboard"
summary: "Our capstone: two robotic hands on a keyboard, driven by ROS2 on a Raspberry Pi. I wrote the layer between ROS2 and more than 20 servos, solenoids and steppers."
stack: ["ROS2 Jazzy", "ros2_control", "C++17", "Pico SDK", "I2C / SPI", "Docker"]
links:
  - { name: "GitHub organisation", url: "https://github.com/bot-hoven" }
  - { name: "YouTube channel", url: "https://www.youtube.com/@Bot-hoven" }
video:
  src: "/media/bot-hoven/chopin.mp4"
  poster: "/media/bot-hoven/chopin.jpg"
  caption: "Bot-Hoven playing a continuation of Chopin's Nocturne Op. 9 No. 2, written by our music-generation model."
  youtube: "https://www.youtube.com/@Bot-hoven"
---
Bot-Hoven was our six-person capstone at the University of Manitoba, sponsored by PTx Trimble. Two robotic hands, built from servo-driven fingers and solenoids, ride on stepper-driven carriages along a piano keyboard. A Raspberry Pi running ROS2 coordinates them. It won second prize at the IEEE Winnipeg Section capstone competition in 2025.

## My part

I owned the **hardware interface layer**, the code that turns ROS2's view of the robot ("finger 3 to 40°, left hand to middle C") into bus transactions:

- **ros2_control plugins** for the PCA9685 (servo PWM), MCP23017 (GPIO expander for the solenoids) and the CL42T stepper drivers, all configured from the robot's URDF/xacro.
- **An I2C bus manager** shared by every plugin over Linux character devices, with block transfers that cut each control cycle from 113 bytes in 31 transactions to 39 bytes in 3, plus a bus-recovery routine for when an I2C device locks up.
- **The SPI link** from the Pi to a Raspberry Pi Pico 2, and the **Pico firmware**, written with Alessandro Potenza: an SPI peripheral that runs one stepper motor per core, with his timers and PID motion control.
- Raspberry Pi 5 bring-up: getting the low-level drivers working under the team's real-time (PREEMPT_RT) kernel, and I2C/SPI access from inside our Docker dev container.

The rest of the team built the hands and electronics, the simulator, and a reinforcement-learning experiment based on Google's RoboPianist.

## Photos and video

{{< clip src="/media/bot-hoven/2024-10-09-first-servo.mp4" date="2024-10-09" >}}
The first test: a potentiometer turning a servo.
{{< /clip >}}

{{< photo src="photos/2024-11-11-pi-driving-stepper-driver.jpg" date="2024-11-11" tall="true" alt="A Raspberry Pi wired through a breadboard to a CL42T stepper driver" >}}
The Pi driving a stepper driver straight off a breadboard. Linux couldn't produce steady step pulses, which is why a Pico 2 took the job later.
{{< /photo >}}

{{< photo src="photos/2024-11-15-first-rail.jpg" date="2024-11-15" tall="true" alt="A linear guide rail on a table with 3D-printed mounts" >}}
The first linear rail, with printed mounts.
{{< /photo >}}

{{< photo src="photos/2024-11-17-belt-and-carriage.jpg" date="2024-11-17" tall="true" alt="A rail with a belt, a carriage and a stepper motor on a plywood board" >}}
Belt, carriage and stepper on a plywood board. Three days later it moved under software control.
{{< /photo >}}

{{< clip src="/media/bot-hoven/2024-11-20-belt-moving.mp4" date="2024-11-20" >}}
The carriage moving along the belt for the first time.
{{< /clip >}}

{{< clip src="/media/bot-hoven/2025-01-12-cpp-servos-solenoids.mp4" date="2025-01-12" >}}
Servos and solenoids driven over I2C from plain C++, before ROS2 was involved.
{{< /clip >}}

{{< clip src="/media/bot-hoven/2025-01-20-ros2-control-shared-i2c.mp4" date="2025-01-20" >}}
The same actuators under ros2_control, with every plugin sharing one I2C bus.
{{< /clip >}}

{{< photo src="photos/2025-02-07-tempo-rig.jpg" date="2025-02-07" alt="A bench setup: a solenoid clamped over a limit switch, wired to breadboards" >}}
The tempo rig: a solenoid clamped over a limit switch, timed by an Arduino Nano. The fingers reached about 238 BPM against a 120 BPM target.
{{< /photo >}}

{{< photo src="photos/2025-02-28-level-shifter.jpg" date="2025-02-28" alt="A Raspberry Pi Pico 2 and a level-shifter board on a breadboard" >}}
A Pico 2 and a level shifter on the breadboard, bringing up the SPI link to the stepper firmware.
{{< /photo >}}

{{< photo src="photos/2025-03-13-single-finger.jpg" date="2025-03-13" alt="A single robotic finger on a carriage above a digital keyboard" >}}
One finger on the carriage, over the keyboard. The next day it hit every target in the random-key test.
{{< /photo >}}

{{< photo src="photos/2025-04-02-first-full-hand.jpg" date="2025-04-02" alt="A five-finger robotic hand on the rail, seen from above, with power supplies on the bench" >}}
The first complete five-finger hand on the rail.
{{< /photo >}}

{{< photo src="photos/2025-04-02-hand-pcb.jpg" date="2025-04-02" alt="Servo leads running into the hand circuit board" >}}
Servo leads going into the hand board.
{{< /photo >}}

{{< photo src="photos/2025-04-02-e-waste.jpg" date="2025-04-02" alt="A cardboard box full of Raspberry Pis and circuit boards" >}}
Late in the project, a transistor on our power distribution board failed and put 24 V onto everything, so every board had to be re-soldered. Another Pi died after brushing the same 24 V rail. With 24 V, 5 V and 3.3 V all on screw terminals and no keyed connectors, the wiring was treacherous. This box is the casualties.
{{< /photo >}}

{{< photo src="photos/2025-04-04-team.jpg" date="2025-04-04" alt="The six team members and our advisor talking at the front of a lecture room" >}}
The team and our advisor, just before the final presentation.
{{< /photo >}}

{{< clip src="/media/bot-hoven/2025-04-04-homing.mp4" date="2025-04-04" >}}
Homing: both hands run to their limit switches, then the robot measures the keyboard in steps.
{{< /clip >}}

{{< clip src="/media/bot-hoven/2025-04-24-mary-had-a-little-lamb.mp4" date="2025-04-24" >}}
Mary Had a Little Lamb, with me standing by.
{{< /clip >}}

{{< photo src="photos/2025-04-29-finished-robot.jpg" date="2025-04-29" alt="The finished robot: two hands on a rail above the keyboard" >}}
The finished robot.
{{< /photo >}}

{{< clip src="/media/bot-hoven/2025-05-08-a-major-scale.mp4" date="2025-05-08" >}}
An A major scale, which mixes white and black keys.
{{< /clip >}}
