function h = cistdplot(x, y, halfwidth, colour)
% ciplot(x, y, halfwidth)       
% ciplot(x, y, halfwidth, colour)
%
% Plots a shaded region on a graph between specified lower and upper confidence intervals (L and U).
% l and u must be vectors of the same length.
% Uses the 'fill' function, not 'area'. Therefore multiple shaded plots
% can be overlayed without a problem. Make them transparent for total visibility.
% x data can be specified, otherwise plots against index values.
% colour can be specified (eg 'k'). Defaults to blue.

% Raymond Reynolds 24/11/06
% Modified by Javier G. Orlandi to use same upper and lower (2015)


if nargin<4
    colour='b';
end
lower = y-halfwidth;
upper = y+halfwidth;

% convert to row vectors so fliplr can work
if find(size(x)==(max(size(x))))<2
x=x'; end
if find(size(lower)==(max(size(lower))))<2
lower=lower'; end
if find(size(upper)==(max(size(upper))))<2
upper=upper'; end

h = fill([x fliplr(x)],[upper fliplr(lower)],colour);


