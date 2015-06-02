function val = smctest(ic, val, rate)

global smdata;

switch ic(3)
    case 1
        smdata.inst(ic(1)).data.val(ic(:, 2)) = val;
        if nargin >= 3
            %fprintf('%d %f %f\n',ic(:, 2), val, rate);
        else
            %fprintf('%d %f\n',ic(:, 2), val);
        end
    case 0
        val = smdata.inst(ic(1)).data.val(ic(:, 2));
    otherwise
        error('Operation not supported');
end
