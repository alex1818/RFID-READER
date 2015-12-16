clear all;
close all;
clc;

filePath = 'C:\Users\MarinYoung\Desktop\DATA\pos 1\';
csvFileName = '20151215_161158';
file = [filePath, csvFileName];
file = [file, '.csv'];

sheet = 1;
xlRange = 'A2:J10000';
[ndata, text] = xlsread(file, sheet, xlRange);
len = length(ndata);    % length of rows

A = Point(0.08,  0);
B = Point(0,     0);
C = Point(-0.08, 0);
Antenna = Point(0.6, 1.2);

tagA = rawDataPacket('2');
tagB = rawDataPacket('3');
tagC = rawDataPacket('4');

for i = 1 : 1 : len
    epc = ndata(i, 1);
    %time = ndata(i, 2);
    %antenna = ndata(i, 3);
    %tx_power = ndata(i, 4);
    %frequency = ndata(i, 5);
    %rssi = ndata(i, 6);
    phase_in_radian = ndata(i, 7);
    %phase_in_degree = ndata(i, 8);
    %doppler_shift = ndata(i, 9);
    %velocity = ndata(i, 10);
    
    epc = num2str(epc);
    
    switch epc
        case tagA.EPC
            tagA.PhaseInRadian = tagA.PhaseInRadian + phase_in_radian;
            tagA.count = tagA.count + 1;
        case tagB.EPC
            tagB.PhaseInRadian = tagB.PhaseInRadian + phase_in_radian;
            tagB.count = tagB.count + 1;
        case tagC.EPC
            tagC.PhaseInRadian = tagC.PhaseInRadian + phase_in_radian;
            tagC.count = tagC.count + 1;
    end
end 

% let average phase in 5 seconds as the measured phase.
phaseA = tagA.PhaseInRadian / tagA.count;
phaseB = tagB.PhaseInRadian / tagB.count;
phaseC = tagC.PhaseInRadian / tagC.count;

distAB = Distance(A, B);
distBC = Distance(B, C);
distAC = Distance(A, C);

wave_length = 3.0e8 / tagA.Frequency;
% suppose B(0, 0), A(distAB, 0), C(-distAB, 0)
[AC_a, AC_b] = HyperbolaParameters(phaseA, phaseC, wave_length, distAC/2);
[r_AC_a, r_AC_b] = HyperbolaParameters(phaseC, phaseA, wave_length, distAC/2);

[AB_a, AB_b] = HyperbolaParameters(phaseA, phaseB, wave_length, distAB/2);
[r_AB_a, r_AB_b] = HyperbolaParameters(phaseB, phaseA, wave_length, distAB/2);

[BC_a, BC_b] = HyperbolaParameters(phaseB, phaseC, wave_length, distBC/2);
[r_BC_a, r_BC_b] = HyperbolaParameters(phaseC, phaseB, wave_length, distBC/2);


syms x  y;
AC_eqn = (x^2)/(AC_a^2) - (y^2)/(AC_b^2) - 1;
r_AC_eqn = (x^2)/(r_AC_a^2) - (y^2)/(r_AC_b^2) - 1;

AB_eqn = ((x-distAB/2)^2)/(AB_a^2) - (y^2)/(AB_b^2) - 1;
r_AB_eqn = ((x-distAB/2)^2)/(r_AB_a^2) - (y^2)/(r_AB_b^2) - 1;

BC_eqn = ((x+distBC/2)^2)/(BC_a^2) - (y^2)/(BC_b^2) - 1;
r_BC_eqn = ((x-distBC/2)^2)/(r_BC_a^2) - (y^2)/(r_BC_b^2) - 1;


% eqn_AB = ((x-distAC/4)^2)/(AB_a^2) - (y^2)/((distAC/2)^2 - AB_a^2) - 1;
% eqn_AC = (x^2)/(AC_a^2) - (y^2)/(distAC^2 - AC_a^2) - 1;
% eqn_BC = ((x+distAC/4)^2)/(BC_a^2) - (y^2)/((distAC/2)^2 - BC_a^2) - 1;


figure;
range = [-1.5, 1.5, -1.5, 1.5];

h1 = ezplot(AC_eqn, range);
set(h1, 'Color', 'red', 'LineStyle', '-');
hold on;
rh1 = ezplot(r_AC_eqn, range);
set(rh1, 'Color', 'red', 'LineStyle', ':');
hold on;
h2 = ezplot(AB_eqn, range);
set(h2, 'Color', 'blue', 'LineStyle', '-');
hold on;
rh2 = ezplot(r_AB_eqn, range);
set(rh2, 'Color', 'blue', 'LineStyle', ':');
hold on;
h3 = ezplot(BC_eqn, range);
set(h3, 'Color', 'green', 'LineStyle', '-');
hold on;
rh3 = ezplot(r_BC_eqn, range);
set(rh3, 'Color', 'green', 'LineStyle', ':');
hold on;

legend('AC', 'rAC', 'AB', 'rAB', 'BC', 'rBC');
Attribute_Set = {'LineWidth',1.5}; 


plot(A.x, A.y, 'x');
plot(B.x, B.y, 'x');
plot(C.x, C.y, 'x');
plot(Antenna.x, Antenna.y, 'o', 'Color', 'black');


 