function val=brickfn(fn,varargin)
val = calllib('vnx_fsynth',['fnLSG_' fn],varargin{:});
end