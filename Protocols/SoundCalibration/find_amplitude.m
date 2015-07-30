% This function finds the right attenuation for signal to get
% a desired sound pressure level.
%
% Santiago Jaramillo - 2007.11.15
% Modified by Peter Znamenskiy - 2009.02.18
% Modified by F. Carnevale - 2015.02.19

function [Amplitude] = find_amplitude(SoundParam,TargetSPL,BandLimits)
    
    InitialAmplitude = 0.2;
    AcceptableDifference_dBSPL = 0.5;
    MaxIterations = 8;
    SPLref = 20e-6;                         % Pa

    SoundParam.Amplitude = InitialAmplitude;

    for inditer=1:MaxIterations
    
        PowerAtThisFrequency = response_one_sound(SoundParam,BandLimits);
        PowerAtThisFrequency_dBSPL = 10*log10(PowerAtThisFrequency/SPLref^2);
        fprintf('Attentuation = %0.4f  ->  Power = %0.2f dB-SPL\n',SoundParam.Amplitude,PowerAtThisFrequency_dBSPL);

        PowerDifference_dBSPL = PowerAtThisFrequency_dBSPL - TargetSPL;
        if(abs(PowerDifference_dBSPL)<AcceptableDifference_dBSPL)
            break;
        elseif(inditer<MaxIterations)
            AmpFactor = sqrt(10^(PowerDifference_dBSPL/10));
            SoundParam.Amplitude = SoundParam.Amplitude/AmpFactor;
            % If it cannot find the right level, set to 0.1
            if(SoundParam.Amplitude>1)
                SoundParam.Amplitude=1;
            end
        end
    end
    
    Amplitude = SoundParam.Amplitude;
 
