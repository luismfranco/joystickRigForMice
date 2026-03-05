# Joystick Rig For Mice

Behavioral rig for visually-guided decision-making tasks in head-fixed mice.

Formerly developed in the [Goard Lab](https://goard.mcdb.ucsb.edu/) at UC Santa Barbara in 2017-2018.

If you find this code helpful, please cite this publication: https://www.science.org/doi/full/10.1126/sciadv.abf9815

Although this behavioral rig can be adapted for different types of visually-guided tasks, the code in this repository was developed for virtual reality environments.

***Disclamimer: this virtual maze is built on [ViRMEn](https://github.com/Tank-Lab/ViRMEn/tree/main)***


# Behavioral Rig

This rig uses basic Thorlabs components such as breadboards, baseplates, optical posts, post holders, etc. In addition, it requires electronic components such as an optical encoder, servos, a solenoid valve, a relay, etc. All electronic components are controlled by an Arduino board. See [itemList](https://github.com/luismfranco/joystickRigForMice/tree/main/itemList) for more details. Also, [f3d files](https://github.com/luismfranco/joystickRigForMice/tree/main/renderings) are provided as a guide for the construction process.

![behaviorRig](https://github.com/user-attachments/assets/722fd5a6-a6ec-4abf-833c-64f2602037cb)

# How to Use

Make sure the [VRmaze](https://github.com/luismfranco/joystickRigForMice/tree/main/VRmaze) folder is added to the MATLAB path.

Also, make sure the correct Arduino pins are mapped to their corresponding electronic components. Pins can be updated [here](https://github.com/luismfranco/joystickRigForMice/blob/main/VRmaze/functions/initializeMaze.m).

Then, on the Command Window, type:  
``startMaze(mazeType, mouseName, varargin};``

Example:  
``startMaze('LandR', sLMF001, 'Duration', 600, 'Rig', 1, 'Reward', 10, 'FreeDecisions', 1.0, 'Servo1Lim', [1 0.6], 'Servo2Lim', [0 0.4], 'Imaging', 'off', 'Notification', 'off'};``

Explicitly defining all options is not required. However, if a string option is used as an input, the program will update its value. Otherwise, default values will be used.

# Example experiment

Mouse performing a visually-guided task. Briefly, the mouse must learn to associate a specific virtual context (1 or 2), with a joystick rotation (right or left).

![behavingMouse](https://github.com/user-attachments/assets/6976cf92-7700-4ddb-a047-309f52151b2c)

