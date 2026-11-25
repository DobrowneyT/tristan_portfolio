---
title: "TeaMate"
subtitle: "A robot arm that makes your tea"
date: 2025-03-01
period: "Winter 2025"
weight: 20
status: stub
context: "ECE 4180 Intro to Robotics, with Evan Evaniuk"
role: "Firmware: motion control, calibration and the brewing state machine"
coverAlt: "The arm lowering a tea bag into a mug"
summary: "A 3-DOF arm that picks up a tea bag, steeps it for exactly as long as you asked, agitates it, then throws it away."
stack: ["C++", "Arduino (MegaPi)", "PID control", "State machines"]
links:
  - { name: "GitHub", url: "https://github.com/DobrowneyT/teamate" }
video:
  src: "/media/teamate/demo.mp4"
  poster: "/media/teamate/demo.jpg"
  caption: "TeaMate making a cup of tea, start to finish."
  youtube: ""    # add the YouTube link here
---
TeaMate is a three-joint robot arm on a Makeblock MegaPi (an Arduino Mega 2560). You set a steep time with a rotary encoder and put your cup down. It picks up a tea bag, lowers it in, dips it gently while counting down, plays a tune when your tea is ready, and drops the bag in the bin.

## How it works

- **Joint control:** each joint is a geared DC motor with an encoder, run by a PID position loop.
- **Self-calibration:** on boot, the base finds its range from two line markers, and the shoulder and elbow drive gently into their mechanical stops (stall detection) to find their limits.
- **A seven-state machine** runs the brew: setup → wait for cup → fetch bag → into cup → count down and agitate → bin → done. Timing uses `millis()`, so nothing blocks.
- **Five kinds of input:** joint encoders, an ultrasonic cup detector, a line sensor, a rotary encoder for the UI, and an OLED display with LEDs and a buzzer for feedback.

## Kinematics

The project also includes a Jacobian-based inverse-kinematics and path-planning library for the arm, built from its Denavit–Hartenberg model. The full write-up will cover how it works.

## In photos

{{< photo src="photos/2025-03-16-drive-motor.jpg" date="2025-03-16" alt="A geared DC motor mounted in a blue Makeblock frame" >}}
One of the arm's geared drive motors in the Makeblock frame.
{{< /photo >}}
