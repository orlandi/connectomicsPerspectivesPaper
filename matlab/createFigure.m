function h = createFigure(width, height)

if(width == 0)
    width = height*(sqrt(5)-1.0)/2.0;
elseif(height == 0)
    height = width*(sqrt(5)-1.0)/2.0;
end
figure;
set(gcf,'units','centimeters');
pos = get(gcf,'position');
set(gcf,'position',[pos(1:2), width, height]);
h = gcf;
