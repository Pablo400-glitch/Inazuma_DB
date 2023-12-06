CREATE TYPE TIPO_ESTADIO AS ENUM('cubierto', 'exterior');
CREATE TYPE CESPED AS ENUM('natural', 'artificial', 'sin cesped');
CREATE TYPE ELEMENTO AS ENUM('bosque', 'montaña', 'aire', 'fuego');
CREATE TYPE TIPO_ENTRENAMIENTO AS ENUM('tiro a puerta', 'vuelta al campo', 'control de balon');
CREATE TYPE TIPO_SUPERTECNICA AS ENUM('portero', 'tiro', 'regate', 'defensa');
CREATE TYPE GENERO AS ENUM ('masculino', 'femenino', 'desconocido');

CREATE TABLE ESTADIO(
  id_estadio SERIAL NOT NULL, 
  cesped CESPED NOT NULL, 
  tipo TIPO_ESTADIO NOT NULL,
  PRIMARY KEY(id_estadio)
);

create table PARTIDO(
  id_partido SERIAL NOT NULL,
  id_equipo_local INTEGER not NULL,
  id_equipo_visitante INTEGER NOT NULL,
  id_estadio INTEGER NOT NULL,
  goles_local INTEGER,
  goles_visitante INTEGER,
  fecha TIMESTAMP NOT NULL,
  primary key(id_partido)
);

CREATE TABLE EQUIPO(
  id_equipo SERIAL NOT NULL,
  nombre VARCHAR(20) NOT NULL,
  pais VARCHAR(20) NOT NULL,
  victorias INTEGER NOT NULL,
  goles_a_favor INTEGER NOT NULL,
  goles_en_contra INTEGER NOT NULL,
  PRIMARY key(id_equipo)
);

CREATE TABLE ENTRENAMIENTO(
  fecha TIMESTAMP NOT NULL,
  id_equipo INTEGER NOT NULL,
  lugar VARCHAR(20) NOT NULL,
  tipo TIPO_ENTRENAMIENTO not NULL,
  PRIMARY KEY(fecha, id_equipo)
);

CREATE TABLE SUPERTECNICA(
  id_supertecnica SERIAL NOT NULL,
  nombre VARCHAR(20) NOT NULL,
  elemento ELEMENTO NOT NULL,
  tipo TIPO_SUPERTECNICA NOT NULL,
  cantidad_jugadores_con_supertecnica INTEGER NOT NULL,
  PRIMARY KEY(id_supertecnica)
);

CREATE TABLE JUGADOR(
  id_jugador SERIAL NOT NULL,
  nombre VARCHAR(10) NOT NULL,
  apellidos VARCHAR(10),
  genero GENERO NOT NULL,
  nacionalidad VARCHAR(20) NOT NULL,
  elemento ELEMENTO NOT NULL,
  posicion VARCHAR(20) NOT NULL,
  id_equipo INTEGER NOT NULL,
  tiro INTEGER NOT NULL,
  regate INTEGER NOT NULL,
  defensa INTEGER NOT NULL,
  control INTEGER NOT NULL,
  tecnica INTEGER NOT NULL,
  rapidez INTEGER NOT NULL,
  aguante INTEGER NOT NULL,
  PRIMARY KEY(id_jugador)
);

CREATE TABLE SUPERTECNICA_JUGADOR(
  id_jugador INTEGER NOT NULL,
  id_supertecnica INTEGER NOT NULL,
  PRIMARY KEY(id_jugador, id_supertecnica)
);

CREATE TABLE PORTERO(
  id_jugador INTEGER NOT NULL,
  paradas INTEGER NOT NULL
);

CREATE TABLE DELANTERO(
  id_jugador INTEGER NOT NULL,
  disparos_a_puerta INTEGER NOT NULL
);

CREATE TABLE DEFENSA(
  id_jugador INTEGER NOT NULL,
  balones_robados INTEGER NOT NULL
);

CREATE TABLE CENTROCAMPISTA(
  id_jugador INTEGER NOT NULL,
  regates_realizados INTEGER NOT NULL
);

ALTER TABLE PARTIDO ADD CONSTRAINT fk_equipo_local FOREIGN KEY (id_equipo_local) REFERENCES EQUIPO(id_equipo) ON DELETE CASCADE;
ALTER TABLE PARTIDO ADD CONSTRAINT fk_equipo_visitante FOREIGN KEY (id_equipo_visitante) REFERENCES EQUIPO(id_equipo) ON DELETE CASCADE;
ALTER TABLE PARTIDO ADD CONSTRAINT fk_estadio FOREIGN KEY (id_estadio) REFERENCES ESTADIO(id_estadio) ON DELETE CASCADE;
ALTER TABLE ENTRENAMIENTO ADD CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES EQUIPO(id_equipo) ON DELETE CASCADE;
ALTER TABLE JUGADOR ADD CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES EQUIPO(id_equipo) ON DELETE CASCADE;
ALTER TABLE SUPERTECNICA_JUGADOR ADD CONSTRAINT fk_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador) ON DELETE CASCADE;
ALTER TABLE SUPERTECNICA_JUGADOR ADD CONSTRAINT fk_supertecnica FOREIGN KEY (id_supertecnica) REFERENCES SUPERTECNICA(id_supertecnica) ON DELETE CASCADE;
ALTER TABLE PORTERO ADD CONSTRAINT fk_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador) ON DELETE CASCADE;
ALTER TABLE DELANTERO ADD CONSTRAINT fk_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador) ON DELETE CASCADE;
ALTER TABLE DEFENSA ADD CONSTRAINT fk_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador) ON DELETE CASCADE;
ALTER TABLE CENTROCAMPISTA ADD CONSTRAINT fk_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador) ON DELETE CASCADE;

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Raimon', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Royal Academy', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Occult', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Wild', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Brain', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Otaku', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Shuriken', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Farm', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Kirkwood', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Zeus', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Inazuma Eleven', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Sallys', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Inazuma Kids FC', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES ('Umbrella', 'Japón', 0, 0, 0);

INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, tecnica, rapidez, aguante)
VALUES 
    ('Mark', 'Evans', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 72, 72, 77, 70, 79, 68, 69),
    ('Jack', 'Wallside', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 62, 68, 66, 62, 54, 49, 54),
    ('Jim', 'Wraith', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 58, 53, 59, 75, 60, 53, 62),
    ('Bobby', 'Shearer', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 76, 61, 76, 72, 72, 60, 72),
    ('Tod', 'Ironside', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 54, 55, 56, 53, 65, 59, 56),
    ('Nathan', 'Swift', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 64, 58, 54, 68, 56, 76, 58),
    ('Steve', 'Grim', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 62, 64, 64, 71, 71, 71, 71),
    ('Tim', 'Saunders', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 63, 76, 60, 61, 58, 55, 48),
    ('Sam', 'Kincaid', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 71, 57, 56, 56, 76, 52, 56),
    ('Jude', 'Sharp', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 63, 79, 79, 79, 68, 76, 76),
    ('Maxwell', 'Carson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 60, 56, 64, 78, 62, 60, 56),
    ('Kevin', 'Dragonfly', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 71, 60, 61, 59, 70, 60, 64),
    ('Axel', 'Blaze', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 79, 66, 64, 76, 60, 72, 68),
    ('William', 'Glass', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 56, 51, 57, 68, 60, 56, 53);

INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, tecnica, rapidez, aguante)
VALUES 
    ('Joe', 'King', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 72, 75, 72, 69, 60, 55, 74),
    ('Bob', 'Carlton', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 58, 55, 54, 63, 70, 45, 62),
    ('Peter', 'Drent', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 71, 54, 64, 67, 62, 44, 59),
    ('Ben', 'Simmons', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 68, 63, 60, 72, 69, 69, 70),
    ('Gus', 'Martin', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 76, 67, 67, 73, 63, 63, 66),
    ('Alan', 'Master', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 64, 64, 69, 72, 66, 64, 62),
    ('John', 'Bloom', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 61, 71, 70, 67, 62, 71, 54),
    ('Derek', 'Swing', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 70, 56, 59, 76, 61, 69, 60),
    ('Herman', 'Waldon', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 76, 64, 79, 72, 69, 70, 57),
    ('Barry', 'Potts', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 53, 52, 56, 54, 44, 52, 60),
    ('Cliff', 'Tomlinson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 53, 60, 61, 52, 53, 54, 52),
    ('Steve', 'Ingham', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 61, 53, 52, 57, 46, 47, 54),
    ('Jim', 'Lawrenson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 54, 57, 63, 57, 55, 53, 56),
    ('David', 'Samford', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 70, 60, 66, 78, 71, 66, 67),
    ('Daniel', 'Hatch', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 75, 69, 68, 68, 64, 78, 61);
