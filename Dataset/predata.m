%% Pre - procesamiento de la información
clear all; close all; clc;
load ('predata.mat');

precio = fliplr(precio');
minimo = fliplr(minimo');
maximo = fliplr(maximo');

for i=1:length(precio)
    if mod(precio(i),1)~=0
        precio(i)=precio(i)*1000;
    end
    if mod(minimo(i),1)~=0
        minimo(i)=minimo(i)*1000;
    end
    if mod(maximo(i),1)~=0
        maximo(i)=maximo(i)*1000;
    end
    volumen(i)= vol1(i)*1000 + vol2(i)*10;
end

volumen = fliplr(volumen);

% precioval = precio(1101:length(precio));
% minimoval = minimo(1101:length(precio));
% maximoval = maximo(1101:length(precio));
% volumenval = volumen(1101:length(precio));
% 
% precio = precio(1:1100);
% minimo = minimo(1:1100);
% maximo = maximo(1:1100);
% volumen = volumen(1:1100);






