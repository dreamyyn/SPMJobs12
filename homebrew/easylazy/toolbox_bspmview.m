% bspmview, type 'help bspmview' to see help

function varargout = main(varargin)
    % ez.clean();
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'bspmview');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath);
    [varargout{1:nargout}] = bspmview(varargin{:}); 
end