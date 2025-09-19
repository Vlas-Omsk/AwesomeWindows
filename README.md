## OBS

### Task scheduler

Create task with next settings:

On "General" tab:

![Triggers](/Images/OBSGeneral.png)

1. When running the task use your user
2. Select "Run only when user is logged on"
3. Enable "Run with highest priveleges"

On "Triggers" tab:

![Triggers](/Images/OBSTriggers.png)

1. Add trigger with task "At log on"
2. Use your user in "Specific user"
3. Enable "Repeat task every" and select "5 minutes" for duration of "Indefinitely"
4. Enable trigger using check at end of window

On "Actions" tab:

![Triggers](/Images/OBSActions.png)

1. Add action "Start a program"
2. Program/Script: `wscript.exe`
3. Arguments: `"D:\Scripts\start-hidden.vbs" "D:\Scripts\start-obs.bat"` _(use your locations)_

On "Settings" tab:

![Triggers](/Images/OBSSettings.png)

1. Enable "Allow task to be run on demand"
2. Enable "Stop the task if it runs longer than" with "3 days"
3. Enable "If the running task does not end when requested, force it to stop"
4. Select "Do not start a new instance" in "if the task is already running, then the following rule aaplies"
