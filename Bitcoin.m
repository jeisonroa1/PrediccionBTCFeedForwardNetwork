%% Entrenamiento y validaci�n de arquitecturas (MLP) para la predicci�n BTC
%% Jeison Ivan Roa Mora - Diego Barragan

clear all; close all; clc;
load ('data.mat');
T1 = 8;                                                % Periodo R�pido
T11 = 15;                                              % Periodos MACD Lento
T2 = 40;                                               % Periodo Lento
%% Reducci�n del Batch (Nota: Cambiar para efectos de una normalizaci�n adecuada)
n = 60;    % Default: 1  
m = 1050; % Default: 1604 Usando 100% de los datos
precio = precio(n:m);
minimo = minimo(n:m);
maximo = maximo(n:m);
volumen = volumen(n:m);
%% Se�al de Volumen (Elimina valores erroneos)

for i =1:length(volumen)
    if isnan(volumen(i))== 1
        volumen(i)= 0;
    end
end
%% Se�ales Osciladores Estoc�sticos
% Oscilador Rapido T1
for i = 1:(length(precio)-T1)
OscEr(i+T1) = (precio(i+T1)- min(precio(i:i+T1)))/(max(precio(i:i+T1))-min(precio(i:i+T1)));
end
% Oscilador Lento T2

for i = 1:(length(precio)-T2)
OscEl(i+T2) = (precio(i+T2)- min(precio(i:i+T2)))/(max(precio(i:i+T2))-min(precio(i:i+T2)));
end

for i =1:length(OscEl)
    if isnan(OscEl(i))== 1
        OscEl(i)= 0;
    end
    if isnan(OscEr(i))== 1
        OscEr(i)= 0;
    end
end

%% Se�ales MACD
% Se�al MACD Rapido
EMA11 = tsmovavg(precio,'e',T1);
EMA12 = tsmovavg(precio,'e',T2);
dif1 = EMA11-EMA12;
MACDr = tsmovavg(dif1(40:length(dif1)),'e',9);
MACDr = [zeros(1,39) MACDr];
% Se�al MACD lento

EMA21 = tsmovavg(precio,'e',T11);
EMA22 = tsmovavg(precio,'e',T2);
dif2 = EMA21-EMA22;
MACDl = tsmovavg(dif2(40:length(dif2)),'e',9);
MACDl = [zeros(1,39) MACDl];

for i =1:length(MACDl)
    if isnan(MACDl(i))== 1
        MACDl(i)= 0;
    end
    if isnan(MACDr(i))== 1
        MACDr(i)= 0;
    end
end

%% Se�al Indicador RSI
for i = 1:length(precio)-1
    
    if precio(i+1) > precio(i)
        u(i+1) = precio(i+1)-precio(i);
        d(i+1) = 0;
    else
        u(i+1) = 0;
        d(i+1) = precio(i)-precio(i+1);
        if precio(i+1) == precio(i)
            u(i+1) = 0;
            d(i+1) = 0;
        end
    end

end
RS =  tsmovavg(u,'e',T1)./tsmovavg(d,'e',T1);
RSI = 100 - 100.*(1./(1+RS));
for i =1:length(RSI)
    if isinf(RSI(i))== 1
        RSI(i)= 100;
    end
    if isnan(RSI(i))== 1
        RSI(i)= 0;
    end
end

%% Se�al A/D Oscilator

for i = 1:length(precio)
ADosc(i) = (((precio(i)-minimo(i))-(maximo(i)-precio(i)))/((maximo(i)-precio(i))))*volumen(i);
end
for i =1:length(ADosc)
    if isinf(ADosc(i))== 1
        ADosc(i)= 260;
    end
    if isnan(ADosc(i))== 1
        ADosc(i)= 0;
    end
end

%% Se�al ROC

for i = 1:length(precio)-T1
ROC(i+T1) = ((precio(i+T1)-precio(i))/precio(i))*100;
end
for i =1:length(ROC)
    if isinf(ROC(i))== 1
        ROC(i)= 100;
    end
    if isnan(ROC(i))== 1
        ROC(i)= 0;
    end
end

%% Normalizaci�n de las entradas

precioN = (precio - min(precio))/(max(precio)-min(precio));
preciopasadoN = [0 precioN(1:length(precioN)-1)];
volumenN = (volumen - min(volumen))/(max(volumen)-min(volumen));
MACDrN = (MACDr - min(MACDr))/(max(MACDr)-min(MACDr));
MACDlN = (MACDl - min(MACDl))/(max(MACDl)-min(MACDl));
ROCN = (ROC - min(ROC))/(max(ROC)-min(ROC));
RSIN = (RSI - min(RSI))/(max(RSI)-min(RSI));
OscErN = OscEr;
OscElN = OscEl;
ADoscN = (ADosc - min(ADosc))/(max(ADosc)-min(ADosc));
minimoN = (minimo - min(minimo))/(max(minimo)-min(minimo));
maximoN = (maximo - min(maximo))/(max(maximo)-min(maximo));

%% Generaci�n matriz de entrenamiento  y validaci�n
% a = inicio de datos de entrenamiento. b+1 = inicio datos de validaci�n.
% Verificar Linea 9. Debe tener coherencia con el tama�o del batch (m-n).
p = round((m-n)*0.7);
a = 1;     % Default: 1
b = p;     % Default: 1200  si en la linea 9 se aprovecha el 100%
a = a+40;  % Se descartan los primeros 40 datos dado que son cero (MACD)
%Entrenamiento
entradas = [precioN(a:b) ; preciopasadoN(a:b) ; volumenN(a:b) ; MACDrN(a:b) ; MACDlN(a:b); ROCN(a:b); RSIN(a:b); OscErN(a:b); OscElN(a:b) ; ADoscN(a:b) ; minimoN(a:b) ; maximoN(a:b)];
salidas = [precioN(a+1:b) precioN(b)];

%Validaci�n
entradasVal = [precioN(b+1:length(precioN)) ; preciopasadoN(b+1:length(precioN)) ; volumenN(b+1:length(precioN)) ; MACDrN(b+1:length(precioN)) ; MACDlN(b+1:length(precioN)); ROCN(b+1:length(precioN)); RSIN(b+1:length(precioN)); OscErN(b+1:length(precioN)); OscElN(b+1:length(precioN)) ; ADoscN(b+1:length(precioN)) ; minimoN(b+1:length(precioN)) ; maximoN(b+1:length(precioN))];
salidasVal = [precioN(b+2:length(precioN)) precioN(length(precioN))];

%% Busqueda de arquitecturas
%Creaci�n y Entrenamiento de la red
PR = [0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1]; %Universos de entradas
ARC = [10 5 1]; 
net=newff(PR,ARC,{'logsig' 'logsig' 'logsig'},'trainlm','learngdm','mse');% Se genera la red neuronal a entrenar y se asignan los parametros de la misma
[net,tr] = train(net,entradas,salidas); % se realiza el entrenamiento de la red neuronal con base en los datos

%% Validaci�n
[Y] = sim(net,entradasVal);   % Cambiar por entradas para validar con datos Ent.
acumulado = 0 ;
for i=1:length(Y)
    acumulado = acumulado + (salidasVal(i)-Y(i))^2;
end
RMSE = acumulado / length(Y)

% Calcula probabilidad de acierto de tendencia.
aciertos=0;
for i=1:length(Y)-1
    if entradasVal(1,i+1)> entradasVal(1,i)
        if Y(i)> entradasVal(1,i)
            aciertos = aciertos+1;
        end
    else
        if Y(i)< entradasVal(1,i)
            aciertos = aciertos+1;
        end
    end
end
ProbTendencia = (aciertos/(length(Y)-1))*100

%% Figuras (Se�ales Ent+val+Predicci�n )
figure;
plot (precioN(a:length(precioN)));
hold on;
plot ([zeros(1,length(entradas(1,:))) entradasVal(1,:) ],'r');
hold on;
plot ([zeros(1,length(entradas(1,:))) Y ],'g');
set (gca,'fontsize',12); 
title ('Se�ales de Normalizadas (Entrenamiento + Validaci�n + Predicci�n)');
xlabel ('Dias');
ylabel ('Precio');
legend('Entrenamiento', 'Validaci�n', 'Predicci�n')

%% Zoom Validaci�n
figure
plot(salidasVal,'r');   % Cambiar por salidas para validar con datos Ent
hold on;                % Si se grafica salidas, ignorar figura 1.
plot (Y)
set (gca,'fontsize',12); 
title ('Se�al de Validaci�n Vs Predicci�n');
xlabel ('Dias');
ylabel ('Precio');
legend('Validaci�n','Predicci�n')


