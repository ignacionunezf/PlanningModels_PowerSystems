 
########### MODELO PLANIFICACION - IGNACIO NUNEZ FUENTES, 24 JULIO 2019 ########################

#################################################################### INDICES ################################################################################

set TECNOLOGIAS;														# Tecnologias de generacion 
set YEAR;																# Year a estudiar
set YEAR_1;																# Year a estudiar
set YEAR_TOTALES;														# Todos los years posibles
set ESCENARIOS;															# Escenarios a estudiar
set ESCENARIOS_TOTALES;													# Todos los escenarios posibles
set NODOS;																# Nodos a estudiar
set NODOS_TOTALES;														# Todos los nodos del sistema

#################################################################### PARAMETROS #############################################################################

param ITERACIONES default 0;											# Iteraciones

param tasa{YEAR_TOTALES};												# Tasa acumulada de crecimiento de la demanda

param td{YEAR_TOTALES};													# Tasa descuento

#################################################################### PARAMETROS SISTEMA #############################################################################

param N; 																# Numero de bloques (horas)

param lmax{NODOS_TOTALES,NODOS_TOTALES} default 100000;					# Capacidad maxima de linea l

param Ke {TECNOLOGIAS,YEAR_TOTALES,NODOS_TOTALES}>=0; 							# capacidad existente por tecnologia

param D{1..N,NODOS_TOTALES};											# Demanda segun hora y barra

param factorviento{1..N,NODOS_TOTALES};									# Factor de planta centrales eolicas

param factorsol{1..N,NODOS_TOTALES};									# Factor de planta centrales solares

param factor_hidro{1..N,NODOS_TOTALES};									# Factor de planta centrales hidro pasada

param hidrologia{ESCENARIOS_TOTALES} default 0.3;						# Factor de planta hidro embalse

param minimo{ESCENARIOS_TOTALES} default 0.3;							# Factor de planta hidro embalse

param Tasa_Regas{1..N,YEAR_TOTALES,NODOS_TOTALES,ESCENARIOS} default 1000000;	# Tasa maxima de regasificacion

param prob{ESCENARIOS_TOTALES} default 0;								# Factor de planta hidro embalse

param REQPU{NODOS_TOTALES};												# Requerimiento de reserva primaria

param REQPD{NODOS_TOTALES};												# Requerimiento de reserva primaria

param REQSU{NODOS_TOTALES};												# Requerimiento de reserva en giro subida

param REQSD{NODOS_TOTALES};												# Requerimiento de reserva en giro bajada

param REQT{NODOS_TOTALES};												# Requerimiento de reserva terciaria

param USORP;															# Uso esperado de reserva primaria

param USORS;															# Uso esperado de reserva secundaria

param USORT;															# Uso esperado de reserva terciaria

#################################################################### COSTOS ###################################################################################

param cvnc{TECNOLOGIAS};												# costos varables no combutibles

param cv{TECNOLOGIAS} default 0;										# costo variable centrales - calculado por el modelo

param comb{TECNOLOGIAS};												# costos de combutible 

param cpol{TECNOLOGIAS};												# costo de contaminacion para centrales existente

param cf{TECNOLOGIAS};													# costo fijo anual

#################################################################### PARAMETROS CENTRALES ###################################################################################

param consumo{TECNOLOGIAS};												# consumo especifico de combutible 

param BETA_P{TECNOLOGIAS};												# 

param BETA_S{TECNOLOGIAS};												# 

param BETA_T{TECNOLOGIAS};												# 

param salida{TECNOLOGIAS};												# factor por salida forzada y mantenimiento

#################################################################### VARIABLES AUXILIARES ###################################################################################

param MODO default 1;																							# Modo modelo

param PRICES{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;							# marginal cost

param PRICES_RPU{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;						# marginal cost primary reserves

param PRICES_RPD{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;						# marginal cost primary reserves

param PRICES_RSU{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;						# marginal cost secondary reserves reg up

param PRICES_RSD{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;						# marginal cost secondary reserves reg down

param PRICES_RGT{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;						# marginal cost tertiary reserves

param PRICE_C default 0;																							# precio potencia

param PRICES2{1..ITERACIONES, 1..N,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;							# prices with cap
	
param PROFITS{1..ITERACIONES,j in TECNOLOGIAS, n in NODOS} default 0;											# profits

param PROFITS2{1..ITERACIONES,j in TECNOLOGIAS, n in NODOS} default 0;											# profits with cap

param POTF {1..ITERACIONES,j in TECNOLOGIAS, n in NODOS} default 0; 											# potencia firme

param K0 {1..ITERACIONES,j in TECNOLOGIAS,y in YEAR} default 0; 												# capacidad por tecnologia

param AVPRICE{1..ITERACIONES,y in YEAR, n in NODOS, s in ESCENARIOS} default 0;									# average price

param POTF_R default 0;																							# potencia firma renovables

param M default 100000;																							# Numero mayor que cualquier potencia instalada o generacion

#################################################################### VARIABLES ###################################################################################

var K {j in TECNOLOGIAS,y in YEAR, n in NODOS}>=0; 												# capacidad por tecnologia

var Y {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# generacion por tecnologia

var L{NODOS_TOTALES,NODOS_TOTALES,t in 1..N,y in YEAR, s in ESCENARIOS};						# transmision entre sistemas

var Gas {y in YEAR, n in NODOS, s in ESCENARIOS}>=0;											# gas contratado

var RPU {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# reservas primaria subida

var RPD {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# reservas primaria bajada

var RSU {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# reserva en giro subida

var RSD {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# reserva en giro bajada

var RGT {j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS, s in ESCENARIOS}>=0;					# reserva terciaria

############################################################## FUNCION OBJETIVO #########################################################################################

minimize Costo_Total:  sum{y in YEAR, n in NODOS}((1/(1+td[y]))*(sum{j in TECNOLOGIAS,t in 1..N, s in ESCENARIOS:j<>'gasCC'&&j<>'gasCA'}(prob[s]*((cv[j]+cpol[j]+cvnc[j])*Y[j,t,y,n,s]+cv[j]*USORP*(RPU[j,t,y,n,s]-RPD[j,t,y,n,s])+cv[j]*USORS*(RSU[j,t,y,n,s]-RSD[j,t,y,n,s])+cv[j]*USORT*RGT[j,t,y,n,s]))+sum{j in TECNOLOGIAS, t in 1..N,s in ESCENARIOS:j='gasCC'||j='gasCA'}(prob[s]*(cpol[j]+cvnc[j])*Y[j,t,y,n,s])+sum{s in ESCENARIOS}(prob[s]*Gas[y,n,s]*comb['gasCC'])+sum{j in TECNOLOGIAS}((K[j,y,n]+Ke[j,y,n])*cf[j]*1000*N/8760)));

############################################################## RESTRICCIONES BALANCE #########################################################################################

subject to Inversiones {j in TECNOLOGIAS,y in YEAR_1, n in NODOS}: K[j,y,n]>=K[j,y-1,n];

############################################################## RESTRICCIONES BALANCE #########################################################################################

subject to Balance_energia {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(Y[j,t,y,n,s])+sum{n2 in NODOS}(L[n,n2,t,y,s])>= D[t,n]*(1+tasa[y]);

subject to Balance_RPU {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(RPU[j,t,y,n,s]) >= REQPU[n];

subject to Balance_RPD {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(RPD[j,t,y,n,s]) = REQPD[n];

subject to Balance_RSU {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(RSU[j,t,y,n,s]) >= REQSU[n];

subject to Balance_RSD {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(RSD[j,t,y,n,s]) = REQSD[n];

subject to Balance_RGT {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: sum{j in TECNOLOGIAS}(RGT[j,t,y,n,s]) >= REQT[n];

############################################################## RESTRICCIONES LINEAS #########################################################################################

subject to Lineas0 {t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: L[n,n,t,y,s] = 0;

subject to Lineas1 {t in 1..N,y in YEAR, n in NODOS,n2 in NODOS,s in ESCENARIOS}: L[n,n2,t,y,s] <= lmax[n,n2];

subject to Lineas2 {t in 1..N,y in YEAR, n in NODOS,n2 in NODOS,s in ESCENARIOS}: L[n,n2,t,y,s] >= -lmax[n,n2];

subject to Lineas3 {t in 1..N,y in YEAR, n in NODOS,n2 in NODOS,s in ESCENARIOS}: L[n,n2,t,y,s] = -L[n2,n,t,y,s];

############################################################## RESTRICCIONES ENERGIA Y RESERVAS #########################################################################################

subject to Rsolar{t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: Y['solar',t,y,n,s]+RPU['solar',t,y,n,s]+RSU['solar',t,y,n,s]+RGT['solar',t,y,n,s]<=(K['solar',y,n]+Ke['solar',y,n])*factorsol[t,n]*salida['solar'];

subject to Reolica{t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: Y['eolica',t,y,n,s]+RPU['eolica',t,y,n,s]+RSU['eolica',t,y,n,s]+RGT['eolica',t,y,n,s]<=(K['eolica',y,n]+Ke['eolica',y,n])*factorviento[t,n]*salida['eolica'];

subject to Rhidrop{t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}: Y['hidrop',t,y,n,s]+RPU['hidrop',t,y,n,s]+RSU['hidrop',t,y,n,s]+RGT['hidrop',t,y,n,s]<=(K['hidrop',y,n]+Ke['hidrop',y,n])*factor_hidro[t,n]*hidrologia[s]*salida['hidrop'];

subject to Convencional1{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS:j<>'solar'&&j<>'eolica'}:Y[j,t,y,n,s]+RPU[j,t,y,n,s]+RSU[j,t,y,n,s]+RGT[j,t,y,n,s]<=(K[j,y,n]+Ke[j,y,n])*salida[j];

subject to Tecnologias_RB{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:Y[j,t,y,n,s]>=RPD[j,t,y,n,s]+RSD[j,t,y,n,s];

#subject to Embalse{t in 1..N, y in YEAR, n in NODOS,s in ESCENARIOS}:Y['hidro',t,y,n,s]<=(K['hidro',y,n]+Ke['hidro',y,n])*0.8;

subject to Embalse2{t in 1..N, y in YEAR, n in NODOS,s in ESCENARIOS}:Y['hidro',t,y,n,s]>=(K['hidro',y,n]+Ke['hidro',y,n])*0.08;

subject to Embalse3{y in YEAR, n in NODOS,s in ESCENARIOS}:sum{t in 1..N}(Y['hidro',t,y,n,s]+USORP*(RPU['hidro',t,y,n,s]-RPD['hidro',t,y,n,s])+USORS*(RSU['hidro',t,y,n,s]-RSD['hidro',t,y,n,s])+USORT*RGT['hidro',t,y,n,s])<=(K['hidro',y,n]+Ke['hidro',y,n])*sum{t2 in 1..N}(factor_hidro[t2,n])*hidrologia[s]*0.9;

subject to GasCC1{y in YEAR,t in 1..(N-1), n in NODOS,s in ESCENARIOS}:Y['gasCC',t+1,y,n,s]-Y['gasCC',t,y,n,s]>=-(K['gasCC',y,n]+Ke['gasCC',y,n])*0.15;

subject to GasCC2{y in YEAR,t in 1..(N-1), n in NODOS,s in ESCENARIOS}:Y['gasCC',t+1,y,n,s]-Y['gasCC',t,y,n,s]<=(K['gasCC',y,n]+Ke['gasCC',y,n])*0.15;

subject to Gas3_Usogas{y in YEAR, n in NODOS,s in ESCENARIOS}:sum{t in 1..N}(Y['gasCC',t,y,n,s]+USORP*(RPU['gasCC',t,y,n,s]-RPD['gasCC',t,y,n,s])+USORS*(RSU['gasCC',t,y,n,s]-RSD['gasCC',t,y,n,s])+USORT*RGT['gasCC',t,y,n,s])*consumo['gasCC']+sum{t in 1..N}(Y['gasCA',t,y,n,s]+USORP*(RPU['gasCA',t,y,n,s]-RPD['gasCA',t,y,n,s])+USORS*(RSU['gasCA',t,y,n,s]-RSD['gasCA',t,y,n,s])+USORT*RGT['gasCA',t,y,n,s])*consumo['gasCA']<=Gas[y,n,s];

subject to Gas4_Inflex{y in YEAR, n in NODOS,s in ESCENARIOS, s2 in ESCENARIOS}:Gas[y,n,s]=Gas[y,n,s2];

subject to Gas5_Tasa{t in 1..N, y in YEAR, n in NODOS,s in ESCENARIOS}:(Y['gasCC',t,y,n,s]+USORP*(RPU['gasCC',t,y,n,s]-RPD['gasCC',t,y,n,s])+USORS*(RSU['gasCC',t,y,n,s]-RSD['gasCC',t,y,n,s])+USORT*RGT['gasCC',t,y,n,s])*consumo['gasCC']+(Y['gasCA',t,y,n,s]+USORP*(RPU['gasCA',t,y,n,s]-RPD['gasCA',t,y,n,s])+USORS*(RSU['gasCA',t,y,n,s]-RSD['gasCA',t,y,n,s])+USORT*RGT['gasCA',t,y,n,s])*consumo['gasCA']<=Tasa_Regas[t,y,n,s];

subject to Carbon1{y in YEAR,t in 1..N, n in NODOS,s in ESCENARIOS}:Y['carbon',t,y,n,s]>=(K['carbon',y,n]+Ke['carbon',y,n])*minimo[s];

subject to Carbon2{y in YEAR,t in 1..(N-1), n in NODOS,s in ESCENARIOS}:Y['carbon',t+1,y,n,s]-Y['carbon',t,y,n,s]>=-(K['carbon',y,n]+Ke['carbon',y,n])*0.15;

subject to Carbon3{y in YEAR,t in 1..(N-1), n in NODOS,s in ESCENARIOS}:Y['carbon',t+1,y,n,s]-Y['carbon',t,y,n,s]<=(K['carbon',y,n]+Ke['carbon',y,n])*0.15;

############################################################## RESTRICCIONES RAMPA #########################################################################################

subject to Rprimaria1{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:RPU[j,t,y,n,s]<=BETA_P[j]*(K[j,y,n]+Ke[j,y,n])*salida[j];

subject to Rprimaria2{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:RPD[j,t,y,n,s]<=BETA_P[j]*(K[j,y,n]+Ke[j,y,n])*salida[j];

subject to Rsecundaria1{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:RSU[j,t,y,n,s]<=BETA_S[j]*(K[j,y,n]+Ke[j,y,n])*salida[j];

subject to Rsecundaria2{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:RSD[j,t,y,n,s]<=BETA_S[j]*(K[j,y,n]+Ke[j,y,n])*salida[j];

subject to Rterciaria{j in TECNOLOGIAS,t in 1..N,y in YEAR, n in NODOS,s in ESCENARIOS}:RGT[j,t,y,n,s]<=BETA_T[j]*(K[j,y,n]+Ke[j,y,n])*salida[j];

#####################################################################	FIN	####################################################################################
