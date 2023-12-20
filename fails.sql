-- Debería fallar
INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo) 
VALUES('2008-10-12 11:00:00', 1, 'Instituto Raimon', 'Vuelta al campo'); --Entrenamiento cerca de partido

INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo) 
VALUES('2008-10-05 16:00:00', 1, 'Instituto Raimon', 'Vuelta al campo'); --Entrenamiento cerca de entrenamiento

INSERT INTO PARTIDO(id_partido, id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES(12, 1, 2, 3, 1, 20, '2008-10-05 16:00:00'); --Partido cerca de entrenamiento

INSERT INTO PARTIDO(id_partido, id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES(12, 1, 2, 3, 1, 20, '2008-10-12 11:00:00'); --Partido cerca de partido

INSERT INTO PARTIDO(id_partido, id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES(13, 1, 1, 3, 1, 20, '2010-10-10'); --Partido entre mismos equipos

INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
(225, 'Jugador', 'Prueba', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, -1, 1, 1, 1, 1, 1), --Valor negativo
(226, 'Jugador2', 'Prueba2', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, -1, 1, 1, 1, 1),
(227, 'Jugador3', 'Prueba3', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, 1, -1, 1, 1, 1),
(228, 'Jugador4', 'Prueba4', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, 1, 1, -1, 1, 1),
(229, 'Jugador5', 'Prueba5', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, 1, 1, 1, -1, 1),
(230, 'Jugador6', 'Prueba6', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, 1, 1, 1, 1, -1);

INSERT INTO EQUIPO (id_equipo, nombre, victorias, goles_a_favor, goles_en_contra)
VALUES
(99,'Test', 'Japón', 0, -1, 0), --Valor negativo
(100,'Test2', 'Japón', 0, 0, -1); --Valor negativo

INSERT INTO EQUIPO (id_equipo, nombre, victorias, goles_a_favor, goles_en_contra)
VALUES(101, 'Test3', 'Japón', -1, 0, 0, 0, 0); --Valor negativo

INSERT INTO JUGADOR(id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
(999, 'Test', 'Test', 'Masculino', 'Japones', 'Aire', 'Portero', 1, 1, 1, 1, 1, 1, 1),
(998, 'Test', 'Test', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 1, 1, 1, 1, 1, 1),
(997, 'Test', 'Test', 'Masculino', 'Japones', 'Aire', 'Defensa', 1, 1, 1, 1, 1, 1, 1),
(996, 'Test', 'Test', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 1, 1, 1, 1, 1, 1, 1),

INSERT INTO PORTERO (id_jugador, paradas)
VALUES (999, -1); --Valor negativo

INSERT INTO DELANTERO (id_jugador, disparos_a_puerta)
VALUES (998, -1); --Valor negativo

INSERT INTO DEFENSA (id_jugador, balones_robados)
VALUES (997, -1); --Valor negativo

INSERT INTO CENTROCAMPISTA (id_jugador, regates_realizados)
VALUES (996, -1); --Valor negativo


DELETE FROM JUGADOR WHERE id_jugador = 999 OR id_jugador = 998 OR id_jugador = 997 OR id_jugador = 996;



-- Comprobación de excepciones de triggers 

INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo) --Entrenamiento cerca de partido
VALUES ('2008-10-12 09:00:00', 1, 'Instituto Raimon', 'Vuelta al campo');

INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo)  --Entrenamiento cerca de entrenamiento
VALUES ('2008-10-05 16:00:00', 1, 'Instituto Raimon', 'Vuelta al campo');

INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES (1, 2, 3, 1, 20, '2008-10-12 11:00:00'); --partido cerca de partido

INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES (1, 2, 3, 1, 20, '2008-10-05 18:00:00'); --partido cerca de entrenamiento

INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo)
VALUES ('2008-10-05 17:00:00', 2, 'Instituto Raimon', 'Vuelta al campo'); --Entrenamiento mismo lugar

INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES (3, 4, 3, 1, 1, '2008-10-12 10:00:00'); --partido mismo lugar

INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES (3, 4, 2, 12, 13, '2008-10-12 07:00:00'); --necesidad de entrenamiento para partido