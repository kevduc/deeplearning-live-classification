warnStruct = warning('off', 'backtrace');

% Create net
net = squeezenet;
sz = net.Layers(1).InputSize;

% Create figure
f = figure;
barInit = true;

% Score buffer
scoresIdx = 1;
ScoresIdxMax = 100;
scores = zeros([1,ScoresIdxMax]);

% Video
clear cam

while isvalid(f)
    if ~exist('cam', 'var')
        try
            cam = webcam;
        catch ME
            warning(ME.message);
            continue
        end
    end
    
    try
        img = snapshot(cam);
    catch ME
        if strcmp(ME.identifier, 'matlab:ipcamera:ipcam:timeout')
            clear cam
            continue
        end
    end
    
    %     [Y, score] = classify(net, imresize(img, sz(1:2)), 'ExecutionEnvironment', 'gpu'); % Use GPU
    [Y, score] = classify(net, imresize(img, sz(1:2)));
    score = max(score)*100;
    scores(scoresIdx) = mean([scores(mod(scoresIdx - (1:2) - 1,ScoresIdxMax)+1), score]);
    
    formattedScore = ['I think it''s a ' char(Y) ' (' num2str(round(score)) '% sure)'];

    disp(formattedScore);

    if isvalid(f)
        try
            subplot(4,5,[2:4, 7:9, 12:14, 17:19]);

            imshow(img);

            title(formattedScore);
            
            subplot(8, 20, 20*(1:6)+3);

            if barInit
                scoreBar = bar(0);
                barInit = false;
            else
                scoreBar = bar(scores(scoresIdx));
            end
            
            % Add color to the score bar propotional to the score
            j = jet(64);
            colormap(flip(j(32:58, :)));
            c = colormap;
            scoreBar.FaceColor = c(round(size(c,1)*scores(scoresIdx)/100), :);

            % Format plot
            ylim([0 100]);
            xticks([]);
            xticklabels({});
            ticks = 0:20:100;
            yticks(ticks);
            yticklabels(num2cell(ticks));
            ytickformat('percentage');
            grid on
            yyaxis right
            ylim([0 100]);
            yticks(round(scores(scoresIdx)));
            yticklabels(num2str(round(scores(scoresIdx))));
            ytickformat('percentage');
            
            drawnow
        catch ME
        end
    end

    % Shift score buffer index (loop if necessary)
    scoresIdx = mod(scoresIdx, ScoresIdxMax) + 1;
end

warning(warnStruct);
clear cam
