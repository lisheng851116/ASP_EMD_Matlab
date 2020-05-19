function y =EMD(x,t,thr)
	%% step1: Initialize variable
	y = [];
	now_signal = x;
	k = 0;
	while(1)
		while(1)
            %% step2: Find the local peaks
			local_max = find_local_max(now_signal,t);
			%% step3: Connect local peaks
			up_envelope = spline(t(local_max),now_signal(local_max),t);
			%% step4: Find the local dips
			local_min = find_local_min(now_signal,t);
			%% step5: Connect the local dips
			down_envelope = spline(t(local_min),now_signal(local_min),t);
			%% step6-1: Compute the mean
			z = (up_envelope + down_envelope)/2;
			%% step6-2: Compute the residue
			h = now_signal - z;
			%% step7 : Check IMF
			%Find (local_max & local_min) of h 
			local_max = find_local_max(h,t);
			local_min = find_local_min(h,t);
			%Find (up_envelope & down_envelope) of h
			up_envelope = spline(t(local_max),h(local_max),t);
			down_envelope = spline(t(local_min),h(local_min),t);
			%Check (1)
			satisfy_1 = 1;
			if(~(isempty(find(h(local_max) < 0,1)) && isempty(find(h(local_min)>0,1))))
				satisfy_1 =0;
			end
			%Check (2)
			satisfy_2 = 1;
			mean = abs((up_envelope + down_envelope)/2);
			for i = 1:length(mean)
				if(mean(i)>thr)
					satisfy_2 = 0;
					break;
				end
			end
			if(satisfy_1 && satisfy_2)
				break
			else
				now_signal = h;
			end
		end
		%% step8: Check trend
		y = [y;h];
		now_signal = x - sum(y,1);
		local_max = find_local_max(now_signal,t);
		local_min = find_local_min(now_signal,t);
		if(length(local_max)+length(local_min)<=3)
			y = [y;now_signal];
			break;
		else
			k = k+1;
		end
	end
end

function local_max =  find_local_max(x,t)
	local_max = [];
	for i = 2: length(x) - 1
		if((x(i)>x(i-1)) && (x(i)>x(i+1)))
			local_max = [local_max i];
		end
	end
	% local peak boundary process
	if(size(local_max)<=1) % null array
		if(x(1)>=x(2))
			local_max = [local_max 1];
		end
		if(x(end)>=x(end -1))
			local_max = [local_max length(t)];
		end
	else % normal case
		if(x(1)>=x(2) && (t(local_max(1)) - t(1) > 0.8 * (t(local_max(2)) - t(local_max(1)))))
			local_max = [1 local_max];
		end
		if(x(end)>=x(end-1) && (t(end) - t(local_max(end)) > 0.8 * (t(local_max(end)) - t(local_max(end-1)))))
			local_max = [local_max length(t)];
		end
	end
	local_max = sort(local_max);
end
function local_min = find_local_min(x,t)
	local_min = [];
	for i = 2: length(x) - 1
		if((x(i)< x(i-1)) && (x(i) < x(i+1)))
			local_min = [local_min i];
		end
	end
	% local dips boundary process
	if(size(local_min)<=1) % null array
		if(x(1)<=x(2))
			local_min = [local_min 1];
		end
		if(x(end)<=x(end-1))
			local_min = [local_min length(t)];
		end
	else % normal case
		if(x(1)<=x(2) && (t(local_min(1)) - t(1) > 0.8 * (t(local_min(2)) - t(local_min(1)))))
			local_min = [1 local_min];
		end
		if(x(end)<=x(end-1) && (t(end) - t(local_min(end)) > 0.8 * (t(local_min(end)) - t(local_min(end-1)))))
			local_min = [local_min , length(t)];
		end
	end
	local_min = sort(local_min);
end