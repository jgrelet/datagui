function ymdhms = to_date(year_base, dec_day, output_type);
%
% function ymdhms = to_date(year_base, dec_day, output_type)
% returns ymdhms  equivalent to decimal day arg
% year_base (and year in output) is 4-digit, NOT (year-1900)
% output_type is optional string:
%     'string' or 's' (default) yields string output
%     'numeric' or 'n' yields numeric array output
% If dec_day is a matrix with N elements, ymdhms will be
% either an array of N strings, or an Nx6 array with columns
%        [yr mo da hr mn sc]
% If dec_day has N elements, year_base must have either 1 or N.
%

% 93/02/10 JR
% 95/12/03 EF: modified for vector arguments and matrix output.
%              Algorithm changed to fix bugs for dec_day large,
%              or dec_day < 0.

if (nargin < 2 | nargin > 3)
  help to_date
  error('Incorrect number of arguments.')
end

if (nargin == 2)
   output_type = 's';
end

c = output_type(1);
if (c == 's' | c == 'S')
   string_out = 1;
elseif (c == 'n' | c == 'N')
   string_out = 0;
else
   help to_date
   error('output_type string must start with s or n');
end

% First, round to the nearest second, since we will be
% needing integer seconds:
dec_day = round(dec_day(:)*86400)/86400;

n_dd = length(dec_day);
year_base = year_base(:);
n_yb = length(year_base);

if (n_yb ~= 1 & n_yb ~= n_dd)
   help to_date
   error('Year_base must be scalar, or match dec_day');
end

if (any(year_base < 1000))
   disp('WARNING: in to_date, year_base should be full year, not year-1900');
end

% 
dd_int = floor(dec_day);
dd_pos = dec_day - dd_int;  % Positive, 0 to 1.


dd_secs = round(dd_pos * 86400);
second = round(rem(dd_secs,60));   % round is needed because of truncation error

dd_mins = round((dd_secs - second)/60);
minute = round(rem(dd_mins, 60));

dd_hrs = round((dd_mins - minute) / 60);
hour = round(rem(dd_hrs, 24));




% integer seconds since start of year 1:
secs = to_sec([year_base ones(n_yb,2) zeros(n_yb,3)]) + (dd_int * 86400);
days1 = round(secs / 86400);         % whole days since start of year 1

year   = 1 + round(days1 / 365.25);   % first guess at year
finished = 0;
itcount = 0;
while (~finished),
   % seconds to start of "year":
   s1   = to_sec([year ones(n_dd,2) zeros(n_dd,3)]);
   % whole days from start of "year" to dec_day:
   days   = days1 - round(s1/86400);
   nonleap_mask = ( rem(year, 4) > 0 | (rem(year,100) == 0 & rem(year,400) ~= 0) );
   leap_mask = ~nonleap_mask;
   iless = (days < 0);
   imore = (leap_mask & (days >= 366)) | (nonleap_mask & (days >= 365));

   finished = 1;
   if (any(iless)),
      year(iless) = year(iless) - 1;
      finished = 0;
   end
   if (any(imore)),
      year(imore) = year(imore) + 1;
      finished = 0;
   end
   itcount = itcount + 1;
   if itcount > 100,
      disp('Iterations exceeded 100 in to_date.')
      error('Please tell EF  exact input values, so problem can be duplicated.');
   end
end

c_norm= [0 31 59 90 120 151 181 212 243 273 304 334];
c_leap= [0 31 60 91 121 152 182 213 244 274 305 335];
cumdays = c_norm(ones(n_dd,1),:) .* nonleap_mask(:,ones(1,12)) ...
        + c_leap(ones(n_dd,1),:) .* leap_mask(:,ones(1,12));

mx = cumdays <= days(:,ones(1,12));
month = sum(mx.').';

cumdays = c_norm(month).' .* nonleap_mask + c_leap(month).' .* leap_mask;

day = round(1 + days - cumdays);  % was "fix"

ymdhms = [year month day hour minute second];

if (string_out)
   ymdhms = sprintf('%04.0f/%02.0f/%02.0f %02.0f:%02.0f:%02.0f', ...
                      ymdhms.');
   ymdhms = reshape(ymdhms, 19, n_dd).';
end
