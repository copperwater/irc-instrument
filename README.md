To run this ChucK script, you'll need to have a program broadcasting OSC messages to UDP port localhost:6666 (that should be coming from IRC messages).

I used my [Python bot library](https://github.com/copperwater/knob2) to make a bot that lurks on whatever IRC server and channels you want it to. It never says anything, but it catches all messages, formats them as OSC, and repeats them out to that port.
In order to use that, get a copy of that repository, and replace its main.py with the main.py in this repository; then place osc_sender.py in its extensions folder.
