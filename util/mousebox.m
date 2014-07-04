function ax = mousebox()

  disp('Mouse button 1 down upper left corner, up on lower right')
  disp('to select region.  Or, press a key to abort.')
  % The following code comes from the rbbox helpdesk
  % example.
  k = waitforbuttonpress;
  if k ~= 0,
    error('Stopped by keypress.');
  end
  point1 = get(gca, 'CurrentPoint');
  finalrect = rbbox;
  point2 = get(gca, 'CurrentPoint');
  point1 = point1(1, 1:2);
  point2 = point2(1, 1:2);
  p1 = min(point1,point2);
  ofs = abs(point1 - point2);
  ax = [p1(1), p1(1) + ofs(1), p1(2), p1(2) + ofs(2)];

