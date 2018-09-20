function [weightedSpace] = plotColoredBehaviorSpace(space, weights, colorbarLabel, flip)
% Given a matrix of the behavioral space, outputs a matrix where the i-th
% behavioral region is weighted with the amount of the i-th element of
% weights.
%
% Jason M. Manley, updated Aug 2018

if nargin < 3
    colorbarLabel = '';
end

if nargin < 4
    flip = 0;
end

weightedSpace = zeros(size(space));

for i=1:size(space,1)
    for j=1:size(space,2);
        if space(i,j) ~= 0
            weightedSpace(i,j) = weights(space(i,j));
        end
        if flip == 1 && (space(i,j) == 0 || weights(space(i,j)) == 0 || isnan(weights(space(i,j))))
            weightedSpace(i,j) = 1000;
        end
    end
end

weightedSpace(isnan(weightedSpace)) = 255;
   
% Plots space with weighted regions
colormap default;
if flip == 1
    colormap(flipud(colormap));
end
% cmap = colormap;
% cmap_mod = cmap;
% cmap_mod(1,:) = [1 1 1];
% colormap(cmap_mod)
j=imagesc(weightedSpace);
caxis([min(weights(weights > 0))-(min(weights(weights > 0))/10) (max(weights)+(max(weights)/10))]);
h=colorbar;
% h.YTick = [log(1) log(10) log(100) log(1000)];
% h.YTickLabel = {'1','10','100','1000'};
ax = gca;
ax.XTick = [];
ax.YTick = [];
ylabel(h,colorbarLabel);
set(gca,'ydir','reverse');
set(gca,'fontsize',18);

end