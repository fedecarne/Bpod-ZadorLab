function [data] = usbdux_daq(opcode,varargin)
global options

switch opcode
    case 'init'

        options = struct('n_scan',1,...
                 'freq',60000,... 
                 'n_chan',16,...
                 'filename','/dev/comedi0',...
                 'subdevice', 0,...
                 'channel', 0,...
                 'range', 0,...
                 'aref', 'AREF_GROUND',...
                 'physical', 1, ...
                 'voltage_divider_factor',1050/50);
             
        [status,cmdout] = system('make');
        disp(cmdout)

    case 'acquire'
        
        optionNames = fieldnames(options);

        nArgs = length(varargin);
        if round(nArgs/2)~=nArgs/2
            error('need propertyName/propertyValue pairs')
        end

        for pair = reshape(varargin,2,[])

            inpName = lower(pair{1});

            if any(strcmp(inpName,optionNames))
                options.(inpName) = pair{2};
            else
              error('%s is not a recognized parameter name',inpName)
            end
        end
        
        [status,cmdout] = system(['./cmd_acq ' num2str(options.n_scan)...
                                             ' ' num2str(options.freq)...
                                             ' ' num2str(options.n_chan)...
                                             ' ' num2str(options.filename)...
                                             ' ' num2str(options.subdevice)...
                                             ' ' num2str(options.channel)...
                                             ' ' num2str(options.range)...
                                             ' ' num2str(options.aref)...
                                             ' ' num2str(options.physical)]);
        d = sscanf(cmdout,'%f');
try
        data = reshape(d,options.n_chan,options.n_scan);
        
        %rescale gived voltage divider attenuation
        data = data*options.voltage_divider_factor;
catch ME
        disp(['Daq Error: ' cmdout])
        try
        data = reshape([d; nan(options.n_chan*options.n_scan-size(d,1),1)],options.n_chan,options.n_scan);
        catch ME
            disp(ME.message)
            data = [];
        end
end
    otherwise
        error([mode ' is an invalid op code for usbdux_daq.'])
end

end

