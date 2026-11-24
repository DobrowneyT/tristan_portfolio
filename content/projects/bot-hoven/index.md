---
title: "Bot-Hoven"
subtitle: "A robot that plays the piano"
date: 2025-04-01
period: "September 2024 – April 2025"
weight: 10
status: stub
context: "Capstone, team of six · IEEE Winnipeg Section 2nd Prize"
role: "ros2_control hardware interfaces (I2C and SPI), Raspberry Pi bring-up, and the Pico 2 stepper firmware"
summary: "Our capstone: two robotic hands on a keyboard, driven by ROS2 on a Raspberry Pi. I wrote the layer between ROS2 and more than 20 servos, solenoids and steppers."
stack: ["ROS2 Jazzy", "ros2_control", "C++17", "Pico SDK", "I2C / SPI", "Docker"]
links:
  - { name: "GitHub organisation", url: "https://github.com/bot-hoven" }
  - { name: "YouTube channel", url: "https://www.youtube.com/@Bot-hoven" }
video:
  src: ""        # e.g. /media/bot-hoven/demo.mp4 once uploaded to the VPS
  poster: ""     # e.g. /media/bot-hoven/poster.jpg
  youtube: "https://www.youtube.com/@Bot-hoven"
---
Bot-Hoven was our six-person capstone at the University of Manitoba. Two robotic hands, built from servo-driven fingers and solenoids, ride on stepper-driven carriages along a piano keyboard. A Raspberry Pi running ROS2 coordinates them. It won second prize at the IEEE Winnipeg Section capstone competition in 2025.

## My part

I owned the **hardware interface layer**, the code that turns ROS2's view of the robot ("finger 3 to 40°, left hand to middle C") into bus transactions:

- **ros2_control plugins** for the PCA9685 (servo PWM), MCP23017 (GPIO expander for the solenoids) and the CL42T stepper drivers, all configured from the robot's URDF/xacro.
- **An I2C bus manager** shared by every plugin over Linux character devices, with batched transactions that cut bus overhead by about 60%, plus a bus-reset routine for when an I2C device locks up.
- **The SPI link** from the Pi to a Raspberry Pi Pico 2, and the **Pico firmware**: an SPI peripheral that runs one stepper motor per core with PID motion.
- Raspberry Pi bring-up and the Docker dev container used to build and deploy the ROS workspace.

The rest of the team built the hands and electronics, the simulator, and a reinforcement-learning experiment based on Google's RoboPianist.
