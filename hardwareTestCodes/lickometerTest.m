function lickometerTest

    % initialize arduino
    arduinoBoard = arduino('com3','uno');
    configurePin(arduinoBoard,'A4','DigitalOutput')     % lickometer pulse
    configurePin(arduinoBoard,'A5','AnalogInput')       % lickometer readout
    writeDigitalPin(arduinoBoard,'A4',1)                % activate lickometer pulse
    
    % Initial parameter values
    k = 1;
    buttonPressed = [];

    % Create figure for real-time plotting of sensor states
    figure,set(gcf,'position',[150 300 1650 400])
        h0 = animatedline('Color','k');
        b0 = abs(readDigitalPin(arduinoBoard,'A5')-1);
            addpoints(h0,k,b0)
            drawnow
        set(gca,'TickDir','out','Fontsize',10,'Fontweight','b')
        xlabel('bits','Fontsize',12,'Fontweight','b')
        ylabel('output','Fontsize',12,'Fontweight','b')
    
    % Loop for evaluating turning direction
    while isempty(buttonPressed)
        k = k+1;
        % Real-time plotting of sensor states
        a0 = abs(readDigitalPin(arduinoBoard,'A5')-1);
            addpoints(h0,k,a0)
            drawnow
        % Condition to stop test
        buttonPressed = get(gcf,'CurrentCharacter');
    end

