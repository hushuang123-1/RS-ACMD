function rs_check_dependencies()
if exist('ACMD', 'file') == 0
    error(['ACMD.m was not found. RS-ACMD uses the ACMD extractor of Chen et al. ', ...
           'Download it from the authors and add it to the MATLAB path or to the functions folder.']);
end
end
