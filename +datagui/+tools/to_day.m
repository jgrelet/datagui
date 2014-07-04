function dd = to_day(year_base, year, month, day, hour, minute, second)
%        dd = to_day(year_base, year, month, day, hour, minute, second)
% or          to_day(year_base, [year month day hour minute second])
%
% returns decimal-day equivalent of arg
% >>>year and year_base are total, NOT just last 2 digits<<<
% hour, minute, second are optional, set to 0 by default
% Input arguments may be column or row vectors, except that
% year_base may be a scalar or a vector.
% With 2 arguments, the second must have 3-6 columns
% Output argument is a column vector.
%


% 93/02/10 JR
% 95/12/03 EF and JH modified for matrix input, vector output.



[nr_year, nc_year] = size(year);
if nargin < 2 | (nargin > 2 & nargin < 4) | (nargin == 2 & nc_year < 3)
  help to_day
  error('Insufficient argument list')
end

if (nargin == 2)
   n_secs = nr_year;
else
   n_secs = nr_year * nc_year;
end

hh = zeros(n_secs,1);   % optional args default
mm = hh;
ss = hh;

if nargin == 2  % vector form
  if nc_year > 3
    hh = year(:,4);
    if nc_year > 4
      mm = year(:,5);
      if nc_year > 5
        ss = year(:,6);
      end
    end
  end
  month = year(:,2);
  day   = year(:,3);
  year  = year(:,1);
else
  if nargin > 4
    hh = hour(:);
    if nargin > 5
      mm = minute(:);
      if nargin > 6
        ss = second(:);
      end
    end
  end
  month = month(:);
  day   = day(:);
  year  = year(:);
end

if (any(year < 1000) | any(year_base < 1000))
   disp('WARNING: in to_day, year and year_base should be full,')
   disp(' not year-1900');
end

if (  length(year) ~= n_secs | length(month) ~= n_secs ...
    | length(day)  ~= n_secs | length(hh)    ~= n_secs ...
    | length(mm)   ~= n_secs | length(ss)    ~= n_secs),
    help to_day
    error('All input vectors except year_base must have same length');
end

year_base = year_base(:);
n_yb = length(year_base);
if (n_yb ~= 1 & n_yb ~= n_secs)
   help to_day
   error('year_base must be scalar, or have same number of elements as other args')
end

dd = (to_sec([year month day hh mm ss]) -  ...
      to_sec([year_base ones(n_yb,2) zeros(n_yb,3)])) / 86400;

