function [M_table] = lzg_summary(ac_curv, ac_n, varargin)
%
% NAME
%
%	function [M_table] = lzg_summary(  ac_curv, ac_n	...
%					   [, ab_percent, 	...
%					    astrc_rowName])
%
% ARGUMENTS
% INPUT
%	ac_curv		cell		a cell structure containing curvature 
%					arrays
%	ac_n		cell		a cell structure containing curvature
%					histograms
%	ab_percent	bool (opt)	if specified, return lzg as percentages
%	astrc_rowName	str cell (opt)	string cell array containing row names 
%	
%
% OUTPUTS
%	M_table		matrix		a summary table of the results:
%					l, z, g, sum, max, pos
%
% DESCRIPTION
%
%	'lzg_summary' simply accepts a cell of histogram arrays and 
%	runs 'lzg', generating the output in a tabulated format.
%
% PRECONDITIONS
%
% 	o ac_curv is usually generated by 'curvs_plot'.
% 
% SEE ALSO
%
% 	o curvs_plot.m
% 	o lzg.m
%
% HISTORY
% 09 January 2006
% o Initial design and coding.
%
% 08 November 2006
% o Added filter_pos() and filter_neg()
%


function [av_out]	= filter_pos(av_in)
	v_posi		= find(av_in > 0);
	av_out		= zeros(1, length(v_posi));
	for i = 1:length(v_posi)
		av_out(i) = av_in(v_posi(i));
	end
end

function [av_out]	= filter_neg(av_in)
	v_negi		= find(av_in <= 0);
	av_out		= zeros(1, length(v_negi));
	for i = 1:length(v_negi)
		av_out(i) = av_in(v_negi(i));
	end
end


[rows cols] = size(ac_curv);
if rows ~= 1
	error('1', 'input cell array must be a row cell.');
end

bins		= 100;
b_leftBoundSet	= 0;
b_rightBoundSet	= 0;
b_rowNamesSet	= 0;
b_percent 	= 0;
if length(varargin)
	b_percent = varargin{1};
	if ~isnumeric(b_percent)
	    error_exit('checking on percent flag',		...
			'flag must be boolean',	...
			'10');
	end
	if length(varargin) >= 2
		strc_rowNames	= varargin{2};
		b_rowNamesSet 	= 1;
		[rows, cols]	= size(strc_rowNames);
		[rowsI, colsI]	= size(ac_curv);
		if rows ~= rowsI
		    error_exit('checking on strc_rowNames',		...
			   'size mismatch',	...
			   '30');
		end
	end
end

M_table	= zeros(cols, 15);

for cell = 1:cols
	[l z g]	= lzg(ac_curv{cell}, b_percent);

%  	if b_rowNamesSet
%  		fprintf(1, '%5s:', strc_rowNames{cell});
%  	else
%  		fprintf(1, '%2d:', cell);
%  	end
%  	if b_percent
%  		fprintf(1, '%10f%10f%10f\n', l, z, g);
%  	else
%  		fprintf(1, '%%10d%10d%10d\n', l, z, g);
%  	end

	M_table(cell, 1)	= l;
	M_table(cell, 2)	= z;
	M_table(cell, 3)	= g;
	M_fX			= ac_n{cell};
	v_t			= M_fX(:,1)';
	v_fx			= M_fX(:,2)';
	v_curv			= ac_curv{cell};
	[rows bins] 	= size(v_fx);
	f_lowest	= min(v_curv);		M_table(cell, 4)  = f_lowest;	
	v_posLowest	= find(v_curv==f_lowest);	
	posLowest	= v_posLowest(1);	M_table(cell, 5)  = posLowest;
	f_highest	= max(v_curv);		M_table(cell, 6)  = f_highest;
	v_posHighest	= find(v_curv==f_highest);
	posHighest	= v_posHighest(1);	M_table(cell, 7)  = posHighest;
	f_som		= sum(v_fx);		M_table(cell, 8)  = f_som;
	f_absav		= mean(abs(v_curv));	M_table(cell, 9)  = f_absav;
	f_av		= mean((v_curv));	M_table(cell, 10) = f_av;
	f_dev		= std(v_curv); 		M_table(cell, 11) = f_dev;
	v_positive	= filter_pos(v_curv);
%  	v_positive	= (v_curv>0);
	f_pav		= mean(v_positive);	M_table(cell, 12) = f_pav;
	f_pstd		= std(v_positive);	M_table(cell, 13) = f_pstd;
	v_negative	= filter_neg(v_curv);
%  	v_negative	= (v_curv<=0)
	f_nav		= mean(v_negative);	M_table(cell, 14) = f_nav;
	f_nstd		= std(v_negative);	M_table(cell, 15) = f_nstd;
end

b_printTable	= 0;
if b_printTable
    for cell = 1:cols
	if b_rowNamesSet
		fprintf(1, '%5s:', strc_rowNames{cell});
	else
		fprintf(1, '%2d:', cell);
	end
	fprintf(1, ' min: ');
	fprintf(1, '%22s', sprintf('%f (%d)', 	M_table(cell, 4), M_table(cell, 5)));
	fprintf(1, ' max: ');
	fprintf(1, '%22s', sprintf('%f (%d)', 	M_table(cell, 6), M_table(cell, 7)));
	fprintf(1, ' sum:');
	fprintf(1, ' %10s', sprintf('%f',   	M_table(cell, 8)));
	fprintf(1, ' absav:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 9)));
	fprintf(1, ' av:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 10)));
	fprintf(1, ' std:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 11)));
	fprintf(1, ' pav:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 12)));
	fprintf(1, ' pstd:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 13)));
	fprintf(1, ' nav:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 14)));
	fprintf(1, ' nstd:');
	fprintf(1, '%10s', sprintf('%f',	M_table(cell, 15)));
	fprintf(1, '\n');
    end
end

end