% Net
net = squeezenet;

sz = net.Layers(1).InputSize;
f = figure;
scoresIdx = 1;
ScoresIdxMax = 100;
scores = zeros([1,ScoresIdxMax]);
bug = true;

% Video
cam_url = 'http://172.16.28.74:8080/video';

clear cam
% cam = webcam;%('USB2.0 Camera');
cam = ipcam(cam_url);

while isvalid(f)
    img = snapshot(cam);
    
    % [Y, score] = classify(net, imresize(img, sz(1:2)), 'ExecutionEnvironment', 'gpu');
    [Y, score] = classify(net, imresize(img, sz(1:2)));
    score = max(score)*100;
    scores(scoresIdx) = mean([scores(mod(scoresIdx - (1:2) - 1,ScoresIdxMax)+1), score]);
    
    disp(['I think it''s a ' char(Y) ' (' num2str(round(score)) '% sure)']);
    if isvalid(f)
        try
            
            subplot(4,5,[2:4, 7:9, 12:14, 17:19]);
            imshow(img);
            title(['I think it''s a ' char(Y) ' (' num2str(round(score)) '% sure)']);
            
            subplot(8, 20, 20*(1:6)+3);
            if bug
                b = bar(0);
                bug = false;
            else
                b = bar(scores(scoresIdx));
            end
            % b.FaceColor = [0.8500 0.3250 0.0980];
            j = jet(64);
            colormap(flip(j(32:58, :)));
            c = colormap;
            b.FaceColor = c(round(size(c,1)*scores(scoresIdx)/100), :);
            % colorbar
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
    scoresIdx = mod(scoresIdx, ScoresIdxMax) + 1;
end