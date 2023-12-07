CREATE TYPE TIPO_ESTADIO AS ENUM('cubierto', 'exterior');
CREATE TYPE CESPED AS ENUM('natural', 'artificial', 'sin cesped');
CREATE TYPE ELEMENTO AS ENUM('bosque', 'montaña', 'aire', 'fuego');
CREATE TYPE TIPO_ENTRENAMIENTO AS ENUM('tiro a puerta', 'vuelta al campo', 'control de balon');
CREATE TYPE TIPO_SUPERTECNICA AS ENUM('portero', 'tiro', 'regate', 'defensa');
CREATE TYPE GENERO AS ENUM ('masculino', 'femenino', 'desconocido');

CREATE TABLE ESTADIO(
  id_estadio SERIAL NOT NULL, 
  nombre VARCHAR(50) NOT NULL,
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
  apellidos VARCHAR(20),
  genero GENERO NOT NULL,
  nacionalidad VARCHAR(20) NOT NULL,
  elemento ELEMENTO NOT NULL,
  posicion VARCHAR(20) NOT NULL,
  id_equipo INTEGER NOT NULL,
  tiro INTEGER NOT NULL,
  regate INTEGER NOT NULL,
  defensa INTEGER NOT NULL,
  control INTEGER NOT NULL,
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

-- Equipos
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

-- Jugadores para el equipo "Raimon"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES 
    ('Mark', 'Evans', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 72, 72, 77, 70, 79, 68),
    ('Jack', 'Wallside', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 62, 68, 66, 62, 54, 49),
    ('Jim', 'Wraith', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 58, 53, 59, 75, 60, 53),
    ('Bobby', 'Shearer', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 76, 61, 76, 72, 72, 60),
    ('Tod', 'Ironside', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 54, 55, 56, 53, 65, 59),
    ('Nathan', 'Swift', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 64, 58, 54, 68, 56, 76),
    ('Steve', 'Grim', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 62, 64, 64, 71, 71, 71),
    ('Tim', 'Saunders', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 63, 76, 60, 61, 58, 55),
    ('Sam', 'Kincaid', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 71, 57, 56, 56, 76, 52),
    ('Jude', 'Sharp', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 63, 79, 79, 79, 68, 76),
    ('Maxwell', 'Carson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 60, 56, 64, 78, 62, 60),
    ('Kevin', 'Dragonfly', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 71, 60, 61, 59, 70, 60),
    ('Axel', 'Blaze', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 79, 66, 64, 76, 60, 72),
    ('William', 'Glass', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Raimon'), 56, 51, 57, 68, 60, 56);

-- Jugadores para el equipo "Royal Academy"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES 
    ('Joe', 'King', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 72, 75, 72, 69, 60, 55),
    ('Bob', 'Carlton', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 58, 55, 54, 63, 70, 45),
    ('Peter', 'Drent', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 71, 54, 64, 67, 62, 44),
    ('Ben', 'Simmons', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 68, 63, 60, 72, 69, 69),
    ('Gus', 'Martin', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 76, 67, 67, 73, 63, 63),
    ('Alan', 'Master', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 64, 64, 69, 72, 66, 64),
    ('John', 'Bloom', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 61, 71, 70, 67, 62, 71),
    ('Derek', 'Swing', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 70, 56, 59, 76, 61, 69),
    ('Herman', 'Waldon', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 76, 64, 79, 72, 69, 70),
    ('Barry', 'Potts', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 53, 52, 56, 54, 44, 52),
    ('Cliff', 'Tomlinson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 53, 60, 61, 52, 53, 54),
    ('Steve', 'Ingham', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 61, 53, 52, 57, 46, 47),
    ('Jim', 'Lawrenson', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 54, 57, 63, 57, 55, 53),
    ('David', 'Samford', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 70, 60, 66, 78, 71, 66),
    ('Daniel', 'Hatch', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Royal Academy'), 75, 69, 68, 68, 64, 78);

-- Jugadores para el equipo "Brain"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Jonathan', 'Seller', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 55, 50, 50, 49, 55, 45),
  ('Neil', 'Turner', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 48, 48, 52, 52, 44, 50),
  ('Clive', 'Mooney', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 53, 49, 54, 50, 55, 53),
  ('Victor', 'Kind', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 49, 53, 48, 51, 48, 53),
  ('Tyron', 'Rock', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 51, 46, 46, 48, 48, 47),
  ('Francis', 'Tell', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 44, 53, 48, 46, 45, 44),
  ('Charles', 'Oughtry', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 55, 52, 45, 45, 46, 44),
  ('Patrick', 'Stiller', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 53, 45, 47, 52, 44, 46),
  ('Harry', 'Leading', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 52, 52, 44, 47, 50, 52),
  ('Samuel', 'Buster', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 55, 46, 52, 49, 48, 50),
  ('Terry', 'Stronger', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 44, 46, 46, 52, 47, 52),
  ('Noel', 'Good', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 44, 44, 48, 55, 44, 48),
  ('Neil', 'Waters', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 52, 48, 51, 52, 45, 54),
  ('Reg', 'Underwood', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 44, 40, 40, 69, 48, 42),
  ('Thomas', 'Feldt', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 75, 69, 68, 76, 75, 78),
  ('Philip', 'Marvel', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Brain'), 44, 53, 52, 48, 49, 50);

-- Jugadores para el equipo "Farm"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Rolf', 'Howells', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 48, 62, 54, 75, 54, 60),
  ('Kent', 'Work', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 44, 57, 54, 70, 54, 65),
  ('Ben', 'Nevis', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 52, 56, 51, 70, 59, 64),
  ('Homer', 'Grower', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 53, 53, 44, 76, 61, 68),
  ('Seward', 'Hayseed', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 42, 56, 52, 77, 58, 68),
  ('Luke', 'Lively', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 47, 57, 44, 73, 56, 63),
  ('Lorne', 'Mower', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 46, 56, 41, 72, 62, 61),
  ('Herb', 'Sherman', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 49, 60, 62, 79, 52, 70),
  ('Albert', 'Green', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 50, 53, 60, 73, 53, 64),
  ('Tom', 'Walters', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 63, 58, 52, 73, 71, 61),
  ('Ike', 'Steiner', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 42, 55, 63, 76, 53, 60),
  ('Stuart', 'Racoonfur', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 56, 62, 62, 74, 66, 63),
  ('Joe', 'Small', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 40, 54, 54, 68, 56, 63),
  ('Mark', 'Hillvalley', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 40, 56, 52, 79, 63, 66),
  ('Daniel', 'Dawson', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 57, 55, 56, 75, 64, 66),
  ('Orville', 'Newman', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Farm'), 71, 70, 46, 72, 62, 66);


-- Jugadores para el equipo "Inazuma Eleven"
-- Jugadores para el equipo "InazumaEleven"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Seymour', 'Hillman', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 70, 68, 64, 71, 68, 75),
  ('Charles', 'Island', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 71, 79, 71, 68, 69, 63),
  ('Garret', 'Hairtown', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 70, 65, 65, 62, 73, 60),
  ('Arthur', 'Sweet', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 62, 75, 78, 68, 68, 67),
  ('Peter', 'Mildred', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 72, 71, 69, 70, 74, 69),
  ('Josh', 'Nathaniel', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 64, 73, 73, 75, 71, 66),
  ('Edward', 'Gladstone', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 68, 66, 68, 60, 72, 63),
  ('Tyler', 'Thomas', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 73, 72, 76, 76, 79, 72),
  ('Joseph', 'Yosemite', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 62, 72, 72, 76, 65, 72),
  ('Ian', 'Suffolk', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 71, 68, 70, 69, 77, 68),
  ('Constant', 'Builder', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 69, 69, 64, 60, 63, 77),
  ('Ted', 'Poe', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 64, 68, 79, 70, 69, 64),
  ('Marshall', 'Heart', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 60, 62, 66, 63, 72, 65),
  ('Dom', 'Foreman', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 76, 72, 64, 64, 68, 72),
  ('Slot', 'MacHines', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 68, 68, 75, 71, 76, 68),
  ('Bill', 'Steakspear', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Eleven'), 62, 75, 78, 68, 68, 67);

-- Jugadores para el equipo "Occult"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Robert', 'Mayer', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 54, 52, 60, 52, 62, 75),
  ('Mick', 'Askley', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 55, 50, 54, 44, 48, 56),
  ('Burt', 'Wolf', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 68, 52, 52, 51, 56, 62),
  ('Alexander', 'Brave', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 57, 65, 60, 52, 71, 56),
  ('Phil', 'Noir', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 52, 45, 48, 52, 52, 58),
  ('Chuck', 'Dollman', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 52, 53, 45, 48, 49, 53),
  ('Ray', 'Mannings', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 55, 62, 60, 52, 56, 61),
  ('Troy', 'Moon', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 61, 70, 77, 52, 79, 69),
  ('Jason', 'Jones', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 52, 54, 57, 57, 60, 54),
  ('Johan', 'Tassman', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 62, 64, 56, 48, 60, 62),
  ('Ken', 'Furan', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 55, 59, 47, 70, 52, 61),
  ('Russell', 'Walk', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 60, 53, 60, 52, 63, 65),
  ('Uxley', 'Allen', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 48, 51, 51, 50, 48, 55),
  ('Nathan', 'Jones', 'masculino', 'japones', 'aire', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 58, 56, 70, 68, 56, 60),
  ('Rob', 'Crombie', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 47, 46, 50, 40, 51, 74),
  ('Jerry', 'Fulton', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Occult'), 52, 58, 56, 61, 56, 79);

-- Jugadores para el equipo "Otaku"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Grant', 'Eldorado', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 49, 63, 61, 69, 43, 28),
  ('Marcus', 'Train', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 61, 60, 53, 56, 52, 41),
  ('Mike', 'Vox', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 48, 55, 57, 51, 44, 50),
  ('Spencer', 'Gates', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 59, 52, 56, 58, 56, 40),
  ('Bill', 'Formby', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 54, 58, 61, 45, 46, 48),
  ('Sam', 'Idol', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 60, 58, 54, 55, 58, 45),
  ('Walter', 'Valiant', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 62, 62, 61, 55, 56, 50),
  ('Ham', 'Signalman', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 54, 56, 55, 52, 53, 48),
  ('Anthony', 'Woodbridge', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 60, 60, 52, 58, 54, 41),
  ('Light', 'Nobel', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 60, 55, 56, 58, 61, 44),
  ('Josh', 'Spear', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 54, 56, 56, 62, 55, 44),
  ('Gaby', 'Farmer', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 58, 62, 52, 61, 54, 47),
  ('Gus', 'Gamer', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 58, 60, 59, 52, 55, 45),
  ('Mark', 'Gambling', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 52, 56, 58, 63, 53, 51),
  ('Theodore', 'Master', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 57, 57, 55, 56, 52, 47),
  ('Ollie', 'Webb', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Otaku'), 44, 62, 54, 48, 44, 51);


-- Jugadores para el equipo "Sally's"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Fayette', 'Riversong', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 40, 50, 50, 48, 40, 42),
  ('Lizzy', 'Squirrel', 'femenino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 43, 44, 50, 45, 47, 45),
  ('Mitch', 'Sandstone', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 54, 58, 41, 48, 45, 46),
  ('Eddie', 'Prentice', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 46, 46, 56, 44, 42, 48),
  ('Dough', 'Baughan', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 45, 41, 46, 48, 40, 51),
  ('Ness', 'Sheldon', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 42, 48, 45, 53, 42, 40),
  ('Suzanne', 'Yuma', 'femenino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 44, 44, 43, 56, 49, 46),
  ('Ian', 'Stager', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 40, 49, 44, 51, 49, 50),
  ('Fred', 'Crumb', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 40, 44, 44, 43, 44, 48),
  ('Louis', 'Hillside', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 60, 52, 51, 41, 41, 48),
  ('Tammy', 'Fielding', 'femenino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 44, 49, 48, 51, 48, 44),
  ('Alex', 'Lovely', 'femenino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 49, 44, 44, 44, 44, 51),
  ('Pip', 'Daltry', 'femenino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 44, 45, 49, 51, 49, 40),
  ('Alf', 'Holmes', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 34, 28, 34, 64, 39, 31),
  ('Kippy', 'Jones', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 48, 51, 47, 51, 43, 42),
  ('Samantha', 'Moonlight', 'femenino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 52, 43, 42, 48, 41, 44),
  ('Eddie', 'Prentice', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Sallys'), 46, 46, 56, 44, 42, 48);

-- Jugadores para el equipo "Shuriken"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Winston', 'Falls', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 56, 56, 52, 63, 64, 55),
  ('Cal', 'Trops', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 58, 61, 69, 55, 59, 57),
  ('Galen', 'Thunderbird', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 63, 60, 63, 62, 54, 57),
  ('Sail', 'Bluesea', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 52, 61, 61, 54, 60, 68),
  ('John', 'Reynolds', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 62, 56, 56, 53, 60, 54),
  ('Sam', 'Samurai', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 60, 60, 60, 60, 56, 60),
  ('Phil', 'Wingate', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 60, 56, 60, 57, 54, 68),
  ('Hank', 'Sullivan', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 60, 55, 59, 44, 60, 60),
  ('Jez', 'Shell', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 53, 63, 59, 56, 47, 65),
  ('Morgan', 'Sanders', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 53, 59, 44, 64, 52, 55),
  ('Kevin', 'Castle', 'masculino', 'japones', 'aire', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 53, 60, 52, 68, 52, 52),
  ('Finn', 'Stoned', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 54, 53, 57, 56, 55, 58),
  ('Newton', 'Flust', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 62, 61, 56, 60, 55, 60),
  ('Dan', 'Hopper', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 52, 58, 62, 62, 55, 61),
  ('Jim', 'Hillfort', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 55, 62, 60, 53, 54, 63),
  ('Jupiter', 'Jumper', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Shuriken'), 56, 61, 53, 56, 69, 68);

-- Jugadores para el equipo "Umbrella"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Greg', 'Bernard', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 49, 55, 63, 51, 51, 56),
  ('Kendall', 'Sefton', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 53, 49, 61, 54, 67, 54),
  ('Paul', 'Caperock', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 54, 50, 46, 45, 58, 48),
  ('Jason', 'Strike', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 48, 50, 64, 47, 56, 51),
  ('Maxwell', 'Claus', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 62, 63, 55, 44, 53, 55),
  ('Norman', 'Porter', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 45, 56, 44, 60, 44, 52),
  ('Julius', 'Molehill', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 53, 48, 68, 48, 55, 49),
  ('Alan', 'Most', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 65, 60, 60, 68, 63, 61),
  ('Bruce', 'Chaney', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 46, 48, 48, 45, 66, 48),
  ('Leroy', 'Rhymes', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 47, 48, 52, 53, 46, 45),
  ('Saul', 'Tunk', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 55, 53, 44, 62, 55, 47),
  ('Cameron', 'Morefield', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 59, 56, 58, 52, 48, 52),
  ('Mildford', 'Scott', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 44, 52, 47, 50, 55, 52),
  ('Peter', 'Banker', 'masculino', 'japones', 'aire', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 50, 45, 51, 63, 50, 45),
  ('Joe', 'Ingram', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 44, 71, 52, 74, 47, 57),
  ('Lou', 'Edmonds', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 68, 45, 51, 44, 54, 71),
  ('Alan', 'Most', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Umbrella'), 65, 60, 60, 68, 63, 61);

-- Jugadores para el equipo "Wild"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Philip', 'Anders', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 52, 51, 48, 52, 52, 51),
  ('Gary', 'Lancaster', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 78, 66, 49, 64, 54, 52),
  ('Adrian', 'Speed', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 63, 47, 69, 55, 79, 42),
  ('Hugo', 'Talgeese', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 44, 52, 56, 46, 64, 67),
  ('Steve', 'Eagle', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 61, 68, 62, 52, 68, 71),
  ('Alan', 'Coe', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 52, 45, 53, 51, 48, 46),
  ('Matt', 'Mouseman', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 42, 50, 52, 44, 79, 54),
  ('Bruce', 'Monkey', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 54, 64, 51, 48, 53, 52),
  ('Cham', 'Lion', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 44, 45, 45, 55, 53, 60),
  ('Rocky', 'Rackham', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 53, 53, 53, 44, 51, 44),
  ('Wilson', 'Fishman', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 52, 64, 51, 51, 51, 62),
  ('Peter', 'Johnson', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 48, 52, 48, 48, 54, 57),
  ('Chad', 'Bullford', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 41, 68, 48, 77, 31, 51),
  ('Charlie', 'Boardfield', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 68, 44, 44, 69, 60, 62),
  ('Harry', 'Snake', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 55, 63, 62, 49, 55, 65),
  ('Leonard', 'O''Shea', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Wild'), 78, 52, 47, 64, 55, 69);

-- Jugadores para el equipo "Zeus"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Lane', 'War', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 71, 79, 70, 72, 56, 57),
  ('Iggy', 'Russ', 'masculino', 'japones', 'aire', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 71, 67, 66, 79, 44, 71),
  ('Apollo', 'Light', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 79, 79, 62, 73, 53, 48),
  ('Jeff', 'Iron', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 60, 64, 78, 69, 70, 64),
  ('Danny', 'Wood', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 62, 68, 66, 79, 50, 53),
  ('Wesley', 'Knox', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 60, 76, 64, 63, 71, 64),
  ('Andy', 'Chronic', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 48, 66, 62, 79, 63, 61),
  ('Artie', 'Mishman', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 62, 66, 76, 67, 44, 45),
  ('Ned', 'Yousef', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 69, 78, 79, 67, 63, 62),
  ('Arion', 'Matlock', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 56, 69, 69, 68, 57, 62),
  ('Jonas', 'Demetrius', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 77, 64, 79, 56, 68, 63),
  ('Gus', 'Heeley', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 78, 69, 61, 50, 65, 60),
  ('Harry', 'Closs', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 63, 60, 66, 79, 69, 71),
  ('Henry', 'House', 'masculino', 'japones', 'fuego', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 48, 68, 60, 67, 64, 70),
  ('Byron', 'Love', 'masculino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 79, 69, 77, 70, 72, 68),
  ('Paul', 'Siddon', 'masculino', 'japones', 'montaña', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Zeus'), 79, 79, 71, 79, 44, 74);

-- Jugadores para el equipo "InazumaKidsFC"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Taylor', 'Higgins', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 44, 43, 50, 48, 40, 48),
  ('Hans', 'Randall', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 64, 40, 40, 51, 48, 56),
  ('Karl', 'Blue', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 46, 48, 47, 44, 51, 46),
  ('Ken', 'Cake', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 49, 40, 40, 40, 51, 49),
  ('Herman', 'Muller', 'masculino', 'japones', 'aire', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 40, 50, 44, 47, 44, 46),
  ('Mitch', 'Grumble', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 48, 48, 43, 48, 40, 46),
  ('Michael', 'Riverside', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 51, 46, 50, 49, 40, 43),
  ('Keth', 'Claus', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 41, 41, 48, 40, 60, 40),
  ('Jamie', 'Cool', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 47, 40, 44, 48, 52, 52),
  ('Izzy', 'Island', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 42, 40, 48, 41, 41, 48),
  ('Theakston', 'Plank', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 48, 50, 42, 45, 58, 41),
  ('Robert', 'Silver', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 46, 41, 51, 44, 41, 48),
  ('Bart', 'Grantham', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 38, 35, 29, 66, 28, 29),
  ('Irwin', 'Hall', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 40, 48, 51, 43, 41, 40),
  ('Sothern', 'Newman', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 45, 44, 48, 60, 43, 49),
  ('Maddie', 'Moonlight', 'femenino', 'japones', 'bosque', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Inazuma Kids FC'), 44, 40, 60, 42, 51, 40);

-- Jugadores para el equipo "Kirkwood"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('John', 'Neville', 'masculino', 'japones', 'fuego', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 78, 62, 54, 79, 48, 51),
  ('York', 'Nashmith', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 52, 62, 57, 61, 54, 52),
  ('Brody', 'Gloom', 'masculino', 'japones', 'montaña', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 54, 46, 48, 53, 45, 52),
  ('Peter', 'Wells', 'masculino', 'japones', 'aire', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 55, 52, 52, 46, 47, 45),
  ('Malcom', 'Night', 'masculino', 'japones', 'fuego', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 63, 76, 68, 78, 67, 64),
  ('Victor', 'Talis', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 55, 52, 52, 46, 47, 45),
  ('Thomas', 'Murdock', 'masculino', 'japones', 'aire', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 68, 70, 65, 60, 64, 62),
  ('Zachary', 'Moore', 'masculino', 'japones', 'bosque', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 52, 60, 60, 52, 63, 53),
  ('Tyler', 'Murdock', 'masculino', 'japones', 'montaña', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 79, 64, 68, 56, 60, 59),
  ('Dan', 'Mirthful', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 59, 70, 49, 65, 46, 51),
  ('Eren', 'Middleton', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 48, 44, 55, 47, 55, 54),
  ('Alfred', 'Meenan', 'masculino', 'japones', 'bosque', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 61, 55, 55, 60, 55, 53),
  ('Simon', 'Calier', 'masculino', 'japones', 'bosque', 'portero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 50, 41, 46, 71, 45, 48),
  ('Ricky', 'Clover', 'masculino', 'japones', 'montaña', 'defensa', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 53, 52, 56, 52, 67, 45),
  ('Marvin', 'Murdock', 'masculino', 'japones', 'fuego', 'delantero', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 68, 61, 61, 66, 60, 60),
  ('Toby', 'Damian', 'masculino', 'japones', 'aire', 'centrocampista', (SELECT id_equipo FROM EQUIPO WHERE nombre = 'Kirkwood'), 54, 56, 55, 56, 57, 56);

-- Posiciones
INSERT INTO PORTERO (id_jugador, paradas)
VALUES 
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Mark' AND apellidos = 'Evans'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Joe' AND apellidos = 'King'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Bob' AND apellidos = 'Carlton'), 0);

INSERT INTO DEFENSA (id_jugador, balones_robados)
VALUES 
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Jack' AND apellidos = 'Wallside'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Jim' AND apellidos = 'Wraith'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Bobby' AND apellidos = 'Shearer'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Tod' AND apellidos = 'Ironside'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Nathan' AND apellidos = 'Swift'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Peter' AND apellidos = 'Drent'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Ben' AND apellidos = 'Simmons'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Gus' AND apellidos = 'Martin'), 0);

INSERT INTO CENTROCAMPISTA (id_jugador, regates_realizados)
VALUES 
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Steve' AND apellidos = 'Grim'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Tim' AND apellidos = 'Saunders'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Sam' AND apellidos = 'Kincaid'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Jude' AND apellidos = 'Sharp'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Alan' AND apellidos = 'Master'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'John' AND apellidos = 'Bloom'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Derek' AND apellidos = 'Swing'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Herman' AND apellidos = 'Waldon'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Barry' AND apellidos = 'Potts'), 0);

INSERT INTO DELANTERO (id_jugador, disparos_a_puerta)
VALUES 
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Maxwell' AND apellidos = 'Carson'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Kevin' AND apellidos = 'Dragonfly'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Axel' AND apellidos = 'Blaze'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'William' AND apellidos = 'Glass'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Cliff' AND apellidos = 'Tomlinson'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Steve' AND apellidos = 'Ingham'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Jim' AND apellidos = 'Lawrenson'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'David' AND apellidos = 'Samford'), 0),
    ((SELECT id_jugador FROM JUGADOR WHERE nombre = 'Daniel' AND apellidos = 'Hatch'), 0);


INSERT INTO ESTADIO (nombre, cesped, tipo) 
VALUES
    ('Estadio Fútbol Frontier', 'natural', 'exterior'),
    ('Ribera del Río', 'natural', 'exterior'),
    ('Campo del Instituto Raimon', 'natural', 'exterior'),
    ('Campo del Instituto Wild', 'artificial', 'exterior'),
    ('Campo del Instituto Brain', 'sin cesped', 'exterior'),
    ('Campo del Instituto Otaku', 'natural', 'exterior'),
    ('Royal Academy', 'sin cesped', 'exterior'),
    ('Estadio Zeus', 'natural', 'cubierto');