% Code: Matlab
% Author: Alessandro N. Vargas (www.anvargas.com)
% Code process experimental data and generates pictures
% Code also creates polynomials (see the corresponding paper)
% Last update: UC Berkeley, Dec 06, 2023


clear all, close all, clc, format long, format compact,

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LDR data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = readtable("data_LDR_Nov_2023.xls");

vecVolt = T.voltage;
vecLux = T.lux;

c1 = polyfit(log(vecVolt),log(vecLux),3)
c_voltagelux_to_lux = c1;

lux = [];
for k=1:max(size(vecVolt))
    v = vecVolt(k);
    lux(k) = exp( c1(1)*log(v)^3 + c1(2)*log(v)^2 + c1(3)*log(v) + c1(4) );
end


figure(1)
loglog(vecVolt,vecLux,['s','blue'],vecVolt,lux,['--','red'])
axis([0 3 0 10000]) 
grid on

title('LDR curve')
xlabel('volt');  ylabel('Lux');
legend('real','simul.');

savefile = sprintf('dataLDR_all.mat')
save(savefile, 'vecVolt', 'vecLux', 'lux','-v7');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arduino data - Input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


T = readtable("data_ArduinoDue_Input_Nov_2023.xls");

vecBit = T.bit;

vecVolt = T.volts;

c_arduino_due_input_bit_to_volts = polyfit(vecBit,vecVolt,1)

c = polyfit(vecVolt,vecBit,1);
c_arduino_input = c



bits = [];
for k=1:max(size(vecVolt))
    v = vecVolt(k);
    bits(k) = c(1)*v + c(2) ;
end


figure(2)
hold on
plot(vecVolt,vecBit,'s');
plot(vecVolt,bits,'r');
grid on
legend('real','simul.');

title('Arduino Due - data Input')
xlabel('volt');  ylabel('Bit');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arduino data - Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
T = readtable("data_ArduinoDue_Output_Nov_2023.xls");

vecBit = T.bit;

vecVolt = T.volts;


c_arduino_due_output_volts_to_bit = polyfit(vecVolt,vecBit,1)

c = polyfit(vecBit,vecVolt,1);
c_arduino_output = c

volts = [];
for k=1:max(size(vecBit))
    b = vecBit(k);
    volts(k) = c(1)*b + c(2) ;
end


figure(3)
hold on
plot(vecBit,vecVolt,'s');
plot(vecBit,volts,'r');
grid on
legend('real','simul.');

title('Arduino Due - data Output')
xlabel('Bit');  ylabel('volt');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plasma reactor data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = readtable("dataPowerPlasma_Nov2023.xls");

vecPower = cellfun(@str2num,T.power);

vecVoltageLux = cellfun(@str2num,T.voltagelux);

c1 = c_voltagelux_to_lux;
lux = [];
power = [];
for k=1:max(size(vecVoltageLux))
    
    % if power is less than 2 watts, then it means the plasma was 'off'
    if (vecPower(k) > 2)
        v = vecVoltageLux(k);
        temp = exp( c1(1)*log(v)^3 + c1(2)*log(v)^2 + c1(3)*log(v) + c1(4) );
        lux = [lux temp];
        power = [power vecPower(k)];
    end
end


c1 = polyfit(log(power),log(lux),3)
c_power_to_lux = c1

vecSimLux = [];
for k=1:max(size(power))
    n = power(k);
    vecSimLux(k) = exp( c1(1)*log(n)^3  + c1(2)*log(n)^2 + c1(3)*log(n) + c1(4) );
end


figure(4)
loglog(power,lux,['.','k'],power,vecSimLux,['--','red'])
grid on

title('power versus lux')
xlabel('power (watts)');  ylabel('Lux');
legend('real','simul.');    

savefile = sprintf('dataPowerPlasma_all.mat')
save(savefile, 'power', 'lux','vecSimLux','-v7');

load("data_UC_Berkeley_DCPlasma_IlluminiscencePaper_Set21_2024.mat")

vecCurrent = B(50000:end-500)/10;
vecVolt = A(50000:end-500);
vecPower = 1000*vecVolt.*vecCurrent;
vecU = vecVolt + vecCurrent*120;

figure(5)
subplot(4,1,1)
plot(Tinterval*[1:max(size(vecVolt))],vecU,'g')
ylabel('Volt (kV')
grid
subplot(4,1,2)
plot(Tinterval*[1:max(size(vecVolt))],vecVolt,'b')
ylabel('Volt (kV)')
grid
subplot(4,1,3)
plot(Tinterval*[1:max(size(vecVolt))],vecCurrent,'r'),
ylabel('Current (A)')
grid
subplot(4,1,4)
plot(Tinterval*[1:max(size(vecVolt))],vecPower,'k')
ylabel('Power (W)')
hold off
grid on

savefile = sprintf('dataPowerPlasma_all_Set_2024.mat')
save(savefile, 'vecU','vecVolt','vecCurrent','vecPower','-v7');
