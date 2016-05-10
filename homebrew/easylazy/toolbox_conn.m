function varargout = main(varargin)
    % add extensions to path
    if isempty(which('conn'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^conn');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end
    % addpath(genpath(thePath));
    % addpath(genpath_exclude(thePath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'})); % avoid weird functions from marsbar/spm folders, wfu
    [varargout{1:nargout}] = conn(varargin{:}); 
end % end function