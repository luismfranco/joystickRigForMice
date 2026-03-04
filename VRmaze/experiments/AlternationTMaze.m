function code = AlternationTMaze
% mazeLLR   Code for the ViRMEn experiment mazeLLR.
%   code = mazeLandR   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
    
    vr.mazeType = 'AlternationTMaze';
    vr = initializeAlternationTMaze(vr);
    
    
% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    [vr] = runtimeAlternationTMaze(vr);

    
% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    
    [vr] = finalizeAlternationTMaze(vr);

    
