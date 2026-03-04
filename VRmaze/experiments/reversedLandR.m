function code = reversedLandR
%   Code for the ViRMEn experiment reversedLandR.
%   code = reversedLandR Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
    
    vr.mazeType = 'reversedLandR';
    vr = initializeMaze(vr);
    
    
% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    [vr] = runtimeMaze(vr);

    
% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    
    [vr] = finalizeMaze(vr);

    