

**Example 1 - simple counter** \
demo video - https://youtube.com/shorts/6MVUDAG_9WA \
First test is just an app with one button. 
1. App and ESP32 both subscribe to /counter variable
2. When button pressed – increase value of /counter by 1
3. ESP32 gets the stream update and displays it on serial terminal.

![image](https://github.com/ICST-Technion/Realtime-IOT-examples/assets/3014352/e8844eb5-20b4-404e-92dd-b26b37e95a9e)


**Example 2 - command and status**\
demo video - https://www.youtube.com/watch?v=rOvv4k19umM \
App with 3 buttons, text display for feedback from ESP32.
ESP32 is outputting data to serial console.
- All the buttons update /command/type (each command has a different number) and also increment /command/runningCount. This is allow the ESP32 to be updated even if the same command is sent multiple times.
- The text display updates when /status is updated.
- ESP32 listens to all “children” of /command so it is updated if any of them is changed.
![image](https://github.com/ICST-Technion/Realtime-IOT-examples/assets/3014352/b8060bc2-cb42-474d-801d-6578649a1824)

**Example 3 - command list - push method**\
WIP






