%% get hyperbola parameters according to phase difference.
function [a, b] = HyperbolaParameters(heta_A, heta_B, wave_length, c)
    phase_difference = heta_A - heta_B;
    if (phase_difference > 0)       % 0 < heta < pi
        distance = (wave_length*phase_difference)/(4*pi);
    elseif (phase_difference < 0)   % -pi < heta < 0
        distance = (wave_length*phase_difference)/(4*pi) + wave_length/2;
    end
    a = distance / 2;
    b = sqrt(c^2 - a^2);
end