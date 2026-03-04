function [velocity] = moveForwardWithJoystick(vr)

% Movement function

velocity = [vr.xSpeed vr.ySpeed 0 vr.angularSpeed];
