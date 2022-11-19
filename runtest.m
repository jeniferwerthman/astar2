function[numofmoves, caught] = runtest(mapfile, robotstart, targetstart)

envmap = load(mapfile);

close all;

%draw the environment
image(envmap'*255);

%current positions of the target and robot
robotpos = robotstart;
targetpos = targetstart;

%now comes the main loop
hr = -1;
ht = -1;
numofmoves = 0;
caught = 0;
state = createstate(envmap,robotpos,targetpos);
for i = 1:2000

    %draw the positions
    if (hr ~= -1)
        delete(hr);
        delete(ht);
    end;
    hr = text(robotpos(1), robotpos(2), 'R');
    ht = text(targetpos(1), targetpos(2), 'T');
    
    %call robot planner to find what they want to do
    t0 = clock;
    [newrobotpos,state] = robotplanner(envmap, robotpos, targetpos,state); 
    %compute movetime for the target
    currentnumofmoves = max(1, ceil(etime(clock,t0)/0.2));
    
    %check that the new commanded position is valid
    if (newrobotpos(1) < 1 | newrobotpos(1) > size(envmap, 1) | ...
            newrobotpos(2) < 1 | newrobotpos(2) > size(envmap, 2))
        fprintf(1, 'ERROR: out-of-map robot position commanded\n');
        return;
    elseif (envmap(newrobotpos(1), newrobotpos(2)) ~= 0)
        fprintf(1, 'ERROR: invalid robot position commanded\n');
        return;
    elseif (abs(newrobotpos(1)-robotpos(1)) > 1 | abs(newrobotpos(2)-robotpos(2)) > 1)
        fprintf(1, 'ERROR: invalid robot move commanded\n');
        return;
    end;        

    %call target planner to see how they move within the robot planning
    %time
    newtargetpos = targetplanner(envmap, robotpos, targetpos, targetstart, currentnumofmoves);
       
    %make the moves
    robotpos = newrobotpos;
    targetpos = newtargetpos;
    numofmoves = numofmoves + 1;
    
    %check if target is caught
    if (abs(robotpos(1)-targetpos(1)) <= 1 & abs(robotpos(2)-targetpos(2)) <= 1)
        caught = 1;
        break;
    end;
    
    pause(0.05);
    %pause();
end;

fprintf(1, 'target caught=%d number of moves made=%d\n', caught, numofmoves);