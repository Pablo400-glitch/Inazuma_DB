CREATE TYPE TIPO_ESTADIO AS ENUM('Cubierto', 'Exterior');
CREATE TYPE CESPED AS ENUM('Natural', 'Artificial', 'Sin cesped');
CREATE TYPE ELEMENTO AS ENUM('Bosque', 'Montaña', 'Aire', 'Fuego');
CREATE TYPE TIPO_ENTRENAMIENTO AS ENUM('Tiro a puerta', 'Vuelta al campo', 'Control de balon');
CREATE TYPE TIPO_SUPERTECNICA AS ENUM('Atajo', 'Tiro', 'Regate', 'Bloqueo');
CREATE TYPE GENERO AS ENUM ('Masculino', 'Femenino', 'desconocido');
CREATE TYPE POSICION AS ENUM('Portero', 'Defensa', 'Centrocampista', 'Delantero');



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
  victorias INTEGER,
  goles_a_favor INTEGER,
  goles_en_contra INTEGER,
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
  nombre VARCHAR(30) NOT NULL,
  elemento ELEMENTO NOT NULL,
  tipo TIPO_SUPERTECNICA NOT NULL,
  cantidad_jugadores_con_supertecnica INTEGER,
  PRIMARY KEY(id_supertecnica)
);

CREATE TABLE JUGADOR(
  id_jugador SERIAL NOT NULL,
  nombre VARCHAR(10) NOT NULL,
  apellidos VARCHAR(20),
  genero GENERO NOT NULL,
  nacionalidad VARCHAR(20) NOT NULL,
  elemento ELEMENTO NOT NULL,
  posicion POSICION NOT NULL,
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

ALTER TABLE PARTIDO ADD CONSTRAINT not_equal_teams CHECK (id_equipo_local <> id_equipo_visitante);
ALTER TABLE JUGADOR ADD CONSTRAINT positive_stats CHECK (tiro > 0 AND regate > 0 AND defensa > 0 AND control > 0 AND rapidez > 0 AND aguante > 0);
ALTER TABLE PARTIDO ADD CONSTRAINT positive_goals CHECK (goles_local >= 0 AND goles_visitante >= 0);
ALTER TABLE EQUIPO ADD CONSTRAINT positive_wins CHECK (victorias >= 0);
ALTER TABLE EQUIPO ADD CONSTRAINT positive_goals CHECK (goles_a_favor >= 0 AND goles_en_contra >= 0);
ALTER TABLE PORTERO ADD CONSTRAINT positive_saves CHECK (paradas >= 0);
ALTER TABLE DELANTERO ADD CONSTRAINT positive_shots CHECK (disparos_a_puerta >= 0);
ALTER TABLE DEFENSA ADD CONSTRAINT positive_stolen_balls CHECK (balones_robados >= 0);
ALTER TABLE CENTROCAMPISTA ADD CONSTRAINT positive_dribbles CHECK (regates_realizados >= 0);





-- Disparador que sume victorias a un equipo cuando gana un partido
CREATE OR REPLACE FUNCTION sumar_victorias() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.goles_local > NEW.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias + 1 WHERE id_equipo = NEW.id_equipo_local;
  ELSIF NEW.goles_local < NEW.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias + 1 WHERE id_equipo = NEW.id_equipo_visitante;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sumar_victorias AFTER INSERT ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE sumar_victorias();

-- Disparador que actualiza las victorias al modificar un registro en la tabla PARTIDO
CREATE OR REPLACE FUNCTION actualizar_victorias() RETURNS TRIGGER AS $$
BEGIN
  IF OLD.goles_local > OLD.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias - 1 WHERE id_equipo = OLD.id_equipo_local;
  ELSIF OLD.goles_local < OLD.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias - 1 WHERE id_equipo = OLD.id_equipo_visitante;
  END IF;

  IF NEW.goles_local > NEW.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias + 1 WHERE id_equipo = NEW.id_equipo_local;
  ELSIF NEW.goles_local < NEW.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias + 1 WHERE id_equipo = NEW.id_equipo_visitante;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_victorias AFTER UPDATE ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE actualizar_victorias();

-- Disparador que actualiza las victorias al borrar un registro en la tabla PARTIDO
CREATE OR REPLACE FUNCTION restar_victorias() RETURNS TRIGGER AS $$
BEGIN
  IF OLD.goles_local > OLD.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias - 1 WHERE id_equipo = OLD.id_equipo_local;
  ELSIF OLD.goles_local < OLD.goles_visitante THEN
    UPDATE EQUIPO SET victorias = victorias - 1 WHERE id_equipo = OLD.id_equipo_visitante;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER restar_victorias BEFORE DELETE ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE restar_victorias();

-- Disparador que sume goles a favor y en contra a los equipos
CREATE OR REPLACE FUNCTION sumar_goles() RETURNS TRIGGER AS $$
BEGIN
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor + NEW.goles_local WHERE id_equipo = NEW.id_equipo_local;
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor + NEW.goles_visitante WHERE id_equipo = NEW.id_equipo_visitante;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra + NEW.goles_visitante WHERE id_equipo = NEW.id_equipo_local;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra + NEW.goles_local WHERE id_equipo = NEW.id_equipo_visitante;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sumar_goles AFTER INSERT ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE sumar_goles();

-- Disparador que actualiza los goles a favor y en contra a los equipos
CREATE OR REPLACE FUNCTION actualizar_goles() RETURNS TRIGGER AS $$
BEGIN
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor - OLD.goles_local WHERE id_equipo = OLD.id_equipo_local;
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor - OLD.goles_visitante WHERE id_equipo = OLD.id_equipo_visitante;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra - OLD.goles_visitante WHERE id_equipo = OLD.id_equipo_local;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra - OLD.goles_local WHERE id_equipo = OLD.id_equipo_visitante;

  UPDATE EQUIPO SET goles_a_favor = goles_a_favor + NEW.goles_local WHERE id_equipo = NEW.id_equipo_local;
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor + NEW.goles_visitante WHERE id_equipo = NEW.id_equipo_visitante;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra + NEW.goles_visitante WHERE id_equipo = NEW.id_equipo_local;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra + NEW.goles_local WHERE id_equipo = NEW.id_equipo_visitante;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_goles AFTER UPDATE ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE actualizar_goles();

-- Disparador que actualiza los goles a favor y en contra a los equipos al borrar un registro en la tabla PARTIDO
CREATE OR REPLACE FUNCTION restar_goles() RETURNS TRIGGER AS $$
BEGIN
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor - OLD.goles_local WHERE id_equipo = OLD.id_equipo_local;
  UPDATE EQUIPO SET goles_a_favor = goles_a_favor - OLD.goles_visitante WHERE id_equipo = OLD.id_equipo_visitante;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra - OLD.goles_visitante WHERE id_equipo = OLD.id_equipo_local;
  UPDATE EQUIPO SET goles_en_contra = goles_en_contra - OLD.goles_local WHERE id_equipo = OLD.id_equipo_visitante;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER restar_goles BEFORE DELETE ON PARTIDO FOR EACH ROW EXECUTE PROCEDURE restar_goles();

-- Disparador que sume usuarios de supertécnicas al añadir a la tabla jugador-supertécnicas
CREATE OR REPLACE FUNCTION jugadores_con_supertecnica() RETURNS TRIGGER AS $$
BEGIN
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica + 1 WHERE id_supertecnica = NEW.id_supertecnica;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER jugadores_con_supertecnica AFTER INSERT ON SUPERTECNICA_JUGADOR FOR EACH ROW EXECUTE PROCEDURE jugadores_con_supertecnica();

-- Disparador que actualiza los usuarios de supertécnicas
CREATE OR REPLACE FUNCTION actualizar_jugadores_con_supertecnica() RETURNS TRIGGER AS $$
BEGIN
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica - 1 WHERE id_supertecnica = OLD.id_supertecnica;
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica + 1 WHERE id_supertecnica = NEW.id_supertecnica;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_jugadores_con_supertecnica AFTER UPDATE ON SUPERTECNICA_JUGADOR FOR EACH ROW EXECUTE PROCEDURE actualizar_jugadores_con_supertecnica();

-- Disparador que actualiza los usuarios de supertécnicas al borrar un registro en la tabla PARTIDO
CREATE OR REPLACE FUNCTION restar_jugadores_con_supertecnica() RETURNS TRIGGER AS $$
BEGIN
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica - 1 WHERE id_supertecnica = OLD.id_supertecnica;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER restar_jugadores_con_supertecnica BEFORE DELETE ON SUPERTECNICA_JUGADOR FOR EACH ROW EXECUTE PROCEDURE restar_jugadores_con_supertecnica();

-- Disparador que valida la hora de inicio en un partido
CREATE OR REPLACE FUNCTION validar_horario_partido()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE id_equipo = NEW.id_equipo_local
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) OR EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE id_equipo = NEW.id_equipo_visitante
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar un partido dentro de las 2 horas anteriores o posteriores a un entrenamiento.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_horario_partido_trigger BEFORE INSERT ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_horario_partido();

-- Disparador que valida la hora de inicio en un entrenamiento
CREATE OR REPLACE FUNCTION validar_horario_entrenamiento()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE NEW.id_equipo = id_equipo_local
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) OR EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE NEW.id_equipo = id_equipo_visitante
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar un entrenamiento dentro de las 2 horas anteriores o posteriores a un partido.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_horario_entrenamiento_trigger BEFORE INSERT ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_horario_entrenamiento();


-- Equipos
INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (1,'Raimon', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (2,'Royal Academy', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (3,'Occult', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (4,'Wild', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (5,'Brain', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (6,'Otaku', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (7,'Shuriken', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (8,'Farm', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (9,'Kirkwood', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (10,'Zeus', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (11,'Inazuma Eleven', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (12,'Sallys', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (13,'Inazuma Kids FC', 'Japón', 0, 0, 0);

INSERT INTO EQUIPO (id_equipo, nombre, pais, victorias, goles_a_favor, goles_en_contra)
VALUES (14,'Umbrella', 'Japón', 0, 0, 0);

-- Jugadores para el equipo "Raimon"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES 
    (1, 'Mark', 'Evans', 'Masculino', 'Japones', 'Montaña', 'Portero', 1, 72, 72, 77, 70, 79, 68),
    (2, 'Jack', 'Wallside', 'Masculino', 'Japones', 'Montaña', 'Defensa', 1, 62, 68, 66, 62, 54, 49),
    (3, 'Jim', 'Wraith', 'Masculino', 'Japones', 'Bosque', 'Defensa', 1, 58, 53, 59, 75, 60, 53),
    (4, 'Bobby', 'Shearer', 'Masculino', 'estadounidense', 'Bosque', 'Defensa', 1, 76, 61, 76, 72, 72, 60),
    (5, 'Tod', 'Ironside', 'Masculino', 'Japones', 'Fuego', 'Defensa', 1, 54, 55, 56, 53, 65, 59),
    (6, 'Nathan', 'Swift', 'Masculino', 'Japones', 'Aire', 'Defensa', 1, 64, 58, 54, 68, 56, 76),
    (7, 'Steve', 'Grim', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 1, 62, 64, 64, 71, 71, 71),
    (8, 'Tim', 'Saunders', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 1, 63, 76, 60, 61, 58, 55),
    (9, 'Sam', 'Kincaid', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 1, 71, 57, 56, 56, 76, 52),
    (10, 'Jude', 'Sharp', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 1, 63, 79, 79, 79, 68, 76),
    (11, 'Maxwell', 'Carson', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 60, 56, 64, 78, 62, 60),
    (12, 'Kevin', 'Dragonfly', 'Masculino', 'Japones', 'Bosque', 'Delantero', 1, 71, 60, 61, 59, 70, 60),
    (13, 'Axel', 'Blaze', 'Masculino', 'Japones', 'Fuego', 'Delantero', 1, 79, 66, 64, 76, 60, 72),
    (14, 'William', 'Glass', 'Masculino', 'Japones', 'Bosque', 'Delantero', 1, 56, 51, 57, 68, 60, 56),
    (15, 'Erik', 'Eagle', 'Masculino', 'estadounidense', 'Bosque', 'Centrocampista', 1, 53, 59, 52, 64, 69, 51);

-- Jugadores para el equipo "Royal Academy"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES 
    (16, 'Joe', 'King', 'Masculino', 'Japones', 'Fuego', 'Portero', 2, 72, 75, 72, 69, 60, 55),
    (17, 'Bob', 'Carlton', 'Masculino', 'Japones', 'Bosque', 'Portero', 2, 58, 55, 54, 63, 70, 45),
    (18, 'Peter', 'Drent', 'Masculino', 'Japones', 'Montaña', 'Defensa', 2, 71, 54, 64, 67, 62, 44),
    (19, 'Ben', 'Simmons', 'Masculino', 'Japones', 'Bosque', 'Defensa', 2, 68, 63, 60, 72, 69, 69),
    (20, 'Gus', 'Martin', 'Masculino', 'Japones', 'Bosque', 'Defensa', 2, 76, 67, 67, 73, 63, 63),
    (21, 'Alan', 'Master', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 64, 64, 69, 72, 66, 64),
    (22, 'John', 'Bloom', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 2, 61, 71, 70, 67, 62, 71),
    (23, 'Derek', 'Swing', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 70, 56, 59, 76, 61, 69),
    (24, 'Herman', 'Waldon', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 76, 64, 79, 72, 69, 70),
    (25, 'Barry', 'Potts', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 53, 52, 56, 54, 44, 52),
    (26, 'Cliff', 'Tomlinson', 'Masculino', 'Japones', 'Aire', 'Delantero', 2, 53, 60, 61, 52, 53, 54),
    (27, 'Steve', 'Ingham', 'Masculino', 'Japones', 'Montaña', 'Delantero', 2, 61, 53, 52, 57, 46, 47),
    (28, 'Jim', 'Lawrenson', 'Masculino', 'Japones', 'Aire', 'Delantero', 2, 54, 57, 63, 57, 55, 53),
    (29, 'David', 'Samford', 'Masculino', 'Japones', 'Bosque', 'Delantero', 2, 70, 60, 66, 78, 71, 66),
    (30, 'Daniel', 'Hatch', 'Masculino', 'Japones', 'Bosque', 'Delantero', 2, 75, 69, 68, 68, 64, 78);

-- Jugadores para el equipo "Brain"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES
  (31, 'Jonathan', 'Seller', 'Masculino', 'Japones', 'Aire', 'Delantero', 5, 55, 50, 50, 49, 55, 45),
  (32, 'Neil', 'Turner', 'Masculino', 'Japones', 'Fuego', 'Delantero', 5, 48, 48, 52, 52, 44, 50),
  (33, 'Clive', 'Mooney', 'Masculino', 'Japones', 'Fuego', 'Delantero', 5, 53, 49, 54, 50, 55, 53),
  (34, 'Victor', 'Kind', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 5, 49, 53, 48, 51, 48, 53),
  (35, 'Tyron', 'Rock', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 5, 51, 46, 46, 48, 48, 47),
  (36, 'Francis', 'Tell', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 5, 44, 53, 48, 46, 45, 44),
  (37, 'Charles', 'Oughtry', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 5, 55, 52, 45, 45, 46, 44),
  (38, 'Patrick', 'Stiller', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 5, 53, 45, 47, 52, 44, 46),
  (39, 'Harry', 'Leading', 'Masculino', 'Japones', 'Aire', 'Defensa', 5, 52, 52, 44, 47, 50, 52),
  (40, 'Samuel', 'Buster', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 5, 55, 46, 52, 49, 48, 50),
  (41, 'Terry', 'Stronger', 'Masculino', 'Japones', 'Fuego', 'Defensa', 5, 44, 46, 46, 52, 47, 52),
  (42, 'Noel', 'Good', 'Masculino', 'Japones', 'Bosque', 'Defensa', 5, 44, 44, 48, 55, 44, 48),
  (43, 'Neil', 'Waters', 'Masculino', 'Japones', 'Bosque', 'Defensa', 5, 52, 48, 51, 52, 45, 54),
  (44, 'Reg', 'Underwood', 'Masculino', 'Japones', 'Bosque', 'Portero', 5, 44, 40, 40, 69, 48, 42),
  (45, 'Thomas', 'Feldt', 'Masculino', 'Japones', 'Bosque', 'Portero', 5, 75, 69, 68, 76, 75, 78),
  (46, 'Philip', 'Marvel', 'Masculino', 'Japones', 'Montaña', 'Defensa', 5, 44, 53, 52, 48, 49, 50);

-- Jugadores para el equipo "Farm"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (47, 'Rolf', 'Howells', 'Masculino', 'Japones', 'Aire', 'Defensa', 8, 48, 62, 54, 75, 54, 60),
  (48, 'Kent', 'Work', 'Masculino', 'Japones', 'Bosque', 'Defensa', 8, 44, 57, 54, 70, 54, 65),
  (49, 'Ben', 'Nevis', 'Masculino', 'Japones', 'Aire', 'Defensa', 8, 52, 56, 51, 70, 59, 64),
  (50, 'Homer', 'Grower', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 53, 53, 44, 76, 61, 68),
  (51, 'Seward', 'Hayseed', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 42, 56, 52, 77, 58, 68),
  (52, 'Luke', 'Lively', 'Masculino', 'Japones', 'Bosque', 'Defensa', 8, 47, 57, 44, 73, 56, 63),
  (53, 'Lorne', 'Mower', 'Masculino', 'Japones', 'Montaña', 'Portero', 8, 46, 56, 41, 72, 62, 61),
  (54, 'Herb', 'Sherman', 'Masculino', 'Japones', 'Fuego', 'Defensa', 8, 49, 60, 62, 79, 52, 70),
  (55, 'Albert', 'Green', 'Masculino', 'Japones', 'Fuego', 'Portero', 8, 50, 53, 60, 73, 53, 64),
  (56, 'Tom', 'Walters', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 8, 63, 58, 52, 73, 71, 61),
  (57, 'Ike', 'Steiner', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 8, 42, 55, 63, 76, 53, 60),
  (58, 'Stuart', 'Racoonfur', 'Masculino', 'Japones', 'Bosque', 'Delantero', 8, 56, 62, 62, 74, 66, 63),
  (59, 'Joe', 'Small', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 8, 40, 54, 54, 68, 56, 63),
  (60, 'Mark', 'Hillvalley', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 40, 56, 52, 79, 63, 66),
  (61, 'Daniel', 'Dawson', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 8, 57, 55, 56, 75, 64, 66),
  (62, 'Orville', 'Newman', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 8, 71, 70, 46, 72, 62, 66);

-- Jugadores para el equipo "InazumaEleven"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (63, 'Seymour', 'Hillman', 'Masculino', 'Japones', 'Montaña', 'Portero', 11, 70, 68, 64, 71, 68, 75),
  (64, 'Charles', 'Island', 'Masculino', 'Japones', 'Bosque', 'Defensa', 11, 71, 79, 71, 68, 69, 63),
  (65, 'Garret', 'Hairtown', 'Masculino', 'Japones', 'Aire', 'Defensa', 11, 70, 65, 65, 62, 73, 60),
  (66, 'Arthur', 'Sweet', 'Masculino', 'Japones', 'Montaña', 'Defensa', 11, 62, 75, 78, 68, 68, 67),
  (67, 'Peter', 'Mildred', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 11, 72, 71, 69, 70, 74, 69),
  (68, 'Josh', 'Nathaniel', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 11, 64, 73, 73, 75, 71, 66),
  (69, 'Edward', 'Gladstone', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 11, 68, 66, 68, 60, 72, 63),
  (70, 'Tyler', 'Thomas', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 11, 73, 72, 76, 76, 79, 72),
  (71, 'Joseph', 'Yosemite', 'Masculino', 'Japones', 'Aire', 'Delantero', 11, 62, 72, 72, 76, 65, 72),
  (72, 'Ian', 'Suffolk', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 11, 71, 68, 70, 69, 77, 68),
  (73, 'Constant', 'Builder', 'Masculino', 'Japones', 'Fuego', 'Delantero', 11, 69, 69, 64, 60, 63, 77),
  (74, 'Ted', 'Poe', 'Masculino', 'Japones', 'Bosque', 'Delantero', 11, 64, 68, 79, 70, 69, 64),
  (75, 'Marshall', 'Heart', 'Masculino', 'Japones', 'Aire', 'Delantero', 11, 60, 62, 66, 63, 72, 65),
  (76, 'Dom', 'Foreman', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 11, 76, 72, 64, 64, 68, 72),
  (77, 'Slot', 'MacHines', 'Masculino', 'Japones', 'Fuego', 'Defensa', 11, 68, 68, 75, 71, 76, 68),
  (78, 'Bill', 'Steakspear', 'Masculino', 'Japones', 'Montaña', 'Defensa', 11, 62, 75, 78, 68, 68, 67);

-- Jugadores para el equipo "Occult"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (79, 'Robert', 'Mayer', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 3, 54, 52, 60, 52, 62, 75),
  (80, 'Mick', 'Askley', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 3, 55, 50, 54, 44, 48, 56),
  (81, 'Burt', 'Wolf', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 3, 68, 52, 52, 51, 56, 62),
  (82, 'Alexander', 'Brave', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 3, 57, 65, 60, 52, 71, 56),
  (83, 'Phil', 'Noir', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 52, 45, 48, 52, 52, 58),
  (84, 'Chuck', 'Dollman', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 52, 53, 45, 48, 49, 53),
  (85, 'Ray', 'Mannings', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 3, 55, 62, 60, 52, 56, 61),
  (86, 'Troy', 'Moon', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 3, 61, 70, 77, 52, 79, 69),
  (87, 'Jason', 'Jones', 'Masculino', 'Japones', 'Aire', 'Defensa', 3, 52, 54, 57, 57, 60, 54),
  (88, 'Johan', 'Tassman', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 62, 64, 56, 48, 60, 62),
  (89, 'Ken', 'Furan', 'Masculino', 'Japones', 'Montaña', 'Defensa', 3, 55, 59, 47, 70, 52, 61),
  (90, 'Russell', 'Walk', 'Masculino', 'Japones', 'Bosque', 'Defensa', 3, 60, 53, 60, 52, 63, 65),
  (91, 'Uxley', 'Allen', 'Masculino', 'Japones', 'Aire', 'Delantero', 3, 48, 51, 51, 50, 48, 55),
  (92, 'Nathan', 'Jones', 'Masculino', 'Japones', 'Aire', 'Portero', 3, 58, 56, 70, 68, 56, 60),
  (93, 'Rob', 'Crombie', 'Masculino', 'Japones', 'Montaña', 'Portero', 3, 47, 46, 50, 40, 51, 74),
  (94, 'Jerry', 'Fulton', 'Masculino', 'Japones', 'Fuego', 'Defensa', 3, 52, 58, 56, 61, 56, 79);

-- Jugadores para el equipo "Otaku"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (95, 'Grant', 'Eldorado', 'Masculino', 'Japones', 'Fuego', 'Portero', 6, 49, 63, 61, 69, 43, 28),
  (96, 'Marcus', 'Train', 'Masculino', 'Japones', 'Fuego', 'Defensa', 6, 61, 60, 53, 56, 52, 41),
  (97, 'Mike', 'Vox', 'Masculino', 'Japones', 'Aire', 'Defensa', 6, 48, 55, 57, 51, 44, 50),
  (98, 'Spencer', 'Gates', 'Masculino', 'Japones', 'Montaña', 'Defensa', 6, 59, 52, 56, 58, 56, 40),
  (99, 'Bill', 'Formby', 'Masculino', 'Japones', 'Montaña', 'Defensa', 6, 54, 58, 61, 45, 46, 48),
  (100, 'Sam', 'Idol', 'Masculino', 'Japones', 'Montaña', 'Portero', 6, 60, 58, 54, 55, 58, 45),
  (101, 'Walter', 'Valiant', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 6, 62, 62, 61, 55, 56, 50),
  (102, 'Ham', 'Signalman', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 6, 54, 56, 55, 52, 53, 48),
  (103, 'Anthony', 'Woodbridge', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 6, 60, 60, 52, 58, 54, 41),
  (104, 'Light', 'Nobel', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 6, 60, 55, 56, 58, 61, 44),
  (105, 'Josh', 'Spear', 'Masculino', 'Japones', 'Bosque', 'Delantero', 6, 54, 56, 56, 62, 55, 44),
  (106, 'Gaby', 'Farmer', 'Masculino', 'Japones', 'Aire', 'Delantero', 6, 58, 62, 52, 61, 54, 47),
  (107, 'Gus', 'Gamer', 'Masculino', 'Japones', 'Fuego', 'Delantero', 6, 58, 60, 59, 52, 55, 45),
  (108, 'Mark', 'Gambling', 'Masculino', 'Japones', 'Aire', 'Delantero', 6, 52, 56, 58, 63, 53, 51),
  (109, 'Theodore', 'Master', 'Masculino', 'Japones', 'Bosque', 'Delantero', 6, 57, 57, 55, 56, 52, 47),
  (110, 'Ollie', 'Webb', 'Masculino', 'Japones', 'Bosque', 'Defensa', 6, 44, 62, 54, 48, 44, 51);


-- Jugadores para el equipo "Sally's"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (111, 'Fayette', 'Riversong', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 12, 40, 50, 50, 48, 40, 42),
  (112, 'Lizzy', 'Squirrel', 'Femenino', 'Japones', 'Aire', 'Centrocampista', 12, 43, 44, 50, 45, 47, 45),
  (113, 'Mitch', 'Sandstone', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 12, 54, 58, 41, 48, 45, 46),
  (114, 'Eddie', 'Prentice', 'Masculino', 'Japones', 'Montaña', 'Delantero', 12, 46, 46, 56, 44, 42, 48),
  (115, 'Dough', 'Baughan', 'Masculino', 'Japones', 'Aire', 'Delantero', 12, 45, 41, 46, 48, 40, 51),
  (116, 'Ness', 'Sheldon', 'Masculino', 'Japones', 'Montaña', 'Defensa', 12, 42, 48, 45, 53, 42, 40),
  (117, 'Suzanne', 'Yuma', 'Femenino', 'Japones', 'Montaña', 'Portero', 12, 44, 44, 43, 56, 49, 46),
  (118, 'Ian', 'Stager', 'Masculino', 'Japones', 'Bosque', 'Defensa', 12, 40, 49, 44, 51, 49, 50),
  (119, 'Fred', 'Crumb', 'Masculino', 'Japones', 'Montaña', 'Defensa', 12, 40, 44, 44, 43, 44, 48),
  (120, 'Louis', 'Hillside', 'Masculino', 'Japones', 'Fuego', 'Defensa', 12, 60, 52, 51, 41, 41, 48),
  (121, 'Tammy', 'Fielding', 'Femenino', 'Japones', 'Bosque', 'Defensa', 12, 44, 49, 48, 51, 48, 44),
  (122, 'Alex', 'Lovely', 'Femenino', 'Japones', 'Aire', 'Defensa', 12, 49, 44, 44, 44, 44, 51),
  (123, 'Pip', 'Daltry', 'Femenino', 'Japones', 'Bosque', 'Defensa', 12, 44, 45, 49, 51, 49, 40),
  (124, 'Alf', 'Holmes', 'Masculino', 'Japones', 'Bosque', 'Portero', 12, 34, 28, 34, 64, 39, 31),
  (125, 'Kippy', 'Jones', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 12, 48, 51, 47, 51, 43, 42),
  (126, 'Samantha', 'Moonlight', 'Femenino', 'Japones', 'Aire', 'Delantero', 12, 52, 43, 42, 48, 41, 44),
  (127, 'Eddie', 'Prentice', 'Masculino', 'Japones', 'Bosque', 'Delantero', 12, 46, 46, 56, 44, 42, 48);

-- Jugadores para el equipo "Shuriken"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (128, 'Winston', 'Falls', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 56, 56, 52, 63, 64, 55),
  (129, 'Cal', 'Trops', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 7, 58, 61, 69, 55, 59, 57),
  (130, 'Galen', 'Thunderbird', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 63, 60, 63, 62, 54, 57),
  (131, 'Sail', 'Bluesea', 'Masculino', 'Japones', 'Fuego', 'Delantero', 7, 52, 61, 61, 54, 60, 68),
  (132, 'John', 'Reynolds', 'Masculino', 'Japones', 'Aire', 'Delantero', 7, 62, 56, 56, 53, 60, 54),
  (133, 'Sam', 'Samurai', 'Masculino', 'Japones', 'Bosque', 'Delantero', 7, 60, 60, 60, 60, 56, 60),
  (134, 'Phil', 'Wingate', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 7, 60, 56, 60, 57, 54, 68),
  (135, 'Hank', 'Sullivan', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 7, 60, 55, 59, 44, 60, 60),
  (136, 'Jez', 'Shell', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 53, 63, 59, 56, 47, 65),
  (137, 'Morgan', 'Sanders', 'Masculino', 'Japones', 'Bosque', 'Portero', 7, 53, 59, 44, 64, 52, 55),
  (138, 'Kevin', 'Castle', 'Masculino', 'Japones', 'Aire', 'Portero', 7, 53, 60, 52, 68, 52, 52),
  (139, 'Finn', 'Stoned', 'Masculino', 'Japones', 'Fuego', 'Defensa', 7, 54, 53, 57, 56, 55, 58),
  (140, 'Newton', 'Flust', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 62, 61, 56, 60, 55, 60),
  (141, 'Dan', 'Hopper', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 52, 58, 62, 62, 55, 61),
  (142, 'Jim', 'Hillfort', 'Masculino', 'Japones', 'Aire', 'Defensa', 7, 55, 62, 60, 53, 54, 63),
  (143, 'Jupiter', 'Jumper', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 56, 61, 53, 56, 69, 68);

-- Jugadores para el equipo "Umbrella"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (144, 'Greg', 'Bernard', 'Masculino', 'Japones', 'Bosque', 'Delantero', 14, 49, 55, 63, 51, 51, 56),
  (145, 'Kendall', 'Sefton', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 53, 49, 61, 54, 67, 54),
  (146, 'Paul', 'Caperock', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 54, 50, 46, 45, 58, 48),
  (147, 'Jason', 'Strike', 'Masculino', 'Japones', 'Fuego', 'Defensa', 14, 48, 50, 64, 47, 56, 51),
  (148, 'Maxwell', 'Claus', 'Masculino', 'Japones', 'Bosque', 'Defensa', 14, 62, 63, 55, 44, 53, 55),
  (149, 'Norman', 'Porter', 'Masculino', 'Japones', 'Montaña', 'Defensa', 14, 45, 56, 44, 60, 44, 52),
  (150, 'Julius', 'Molehill', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 53, 48, 68, 48, 55, 49),
  (151, 'Alan', 'Most', 'Masculino', 'Japones', 'Montaña', 'Defensa', 14, 65, 60, 60, 68, 63, 61),
  (152, 'Bruce', 'Chaney', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 14, 46, 48, 48, 45, 66, 48),
  (153, 'Leroy', 'Rhymes', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 14, 47, 48, 52, 53, 46, 45),
  (154, 'Saul', 'Tunk', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 14, 55, 53, 44, 62, 55, 47),
  (155, 'Cameron', 'Morefield', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 14, 59, 56, 58, 52, 48, 52),
  (156, 'Mildford', 'Scott', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 14, 44, 52, 47, 50, 55, 52),
  (157, 'Peter', 'Banker', 'Masculino', 'Japones', 'Aire', 'Portero', 14, 50, 45, 51, 63, 50, 45),
  (158, 'Joe', 'Ingram', 'Masculino', 'Japones', 'Fuego', 'Portero', 14, 44, 71, 52, 74, 47, 57),
  (159, 'Lou', 'Edmonds', 'Masculino', 'Japones', 'Fuego', 'Delantero', 14, 68, 45, 51, 44, 54, 71),
  (160, 'Alan', 'Most', 'Masculino', 'Japones', 'Fuego', 'Defensa', 14, 65, 60, 60, 68, 63, 61);

-- Jugadores para el equipo "Wild"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (161, 'Philip', 'Anders', 'Masculino', 'Japones', 'Fuego', 'Delantero', 4, 52, 51, 48, 52, 52, 51),
  (162, 'Gary', 'Lancaster', 'Masculino', 'Japones', 'Montaña', 'Delantero', 4, 78, 66, 49, 64, 54, 52),
  (163, 'Adrian', 'Speed', 'Masculino', 'Japones', 'Aire', 'Delantero', 4, 63, 47, 69, 55, 79, 42),
  (164, 'Hugo', 'Talgeese', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 4, 44, 52, 56, 46, 64, 67),
  (165, 'Steve', 'Eagle', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 61, 68, 62, 52, 68, 71),
  (166, 'Alan', 'Coe', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 4, 52, 45, 53, 51, 48, 46),
  (167, 'Matt', 'Mouseman', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 4, 42, 50, 52, 44, 79, 54),
  (168, 'Bruce', 'Monkey', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 54, 64, 51, 48, 53, 52),
  (169, 'Cham', 'Lion', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 44, 45, 45, 55, 53, 60),
  (170, 'Rocky', 'Rackham', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 53, 53, 53, 44, 51, 44),
  (171, 'Wilson', 'Fishman', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 52, 64, 51, 51, 51, 62),
  (172, 'Peter', 'Johnson', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 48, 52, 48, 48, 54, 57),
  (173, 'Chad', 'Bullford', 'Masculino', 'Japones', 'Fuego', 'Portero', 4, 41, 68, 48, 77, 31, 51),
  (174, 'Charlie', 'Boardfield', 'Masculino', 'Japones', 'Fuego', 'Portero', 4, 68, 44, 44, 69, 60, 62),
  (175, 'Harry', 'Snake', 'Masculino', 'Japones', 'Bosque', 'Delantero', 4, 55, 63, 62, 49, 55, 65),
  (176, 'Leonard', 'O`Shea', 'Masculino', 'Japones', 'Montaña', 'Defensa', 4, 78, 52, 47, 64, 55, 69);

-- Jugadores para el equipo "Zeus"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (177, 'Lane', 'War', 'Masculino', 'Japones', 'Montaña', 'Defensa', 10, 71, 79, 70, 72, 56, 57),
  (178, 'Iggy', 'Russ', 'Masculino', 'Japones', 'Aire', 'Portero', 10, 71, 67, 66, 79, 44, 71),
  (179, 'Apollo', 'Light', 'Masculino', 'Japones', 'Bosque', 'Defensa', 10, 79, 79, 62, 73, 53, 48),
  (180, 'Jeff', 'Iron', 'Masculino', 'Japones', 'Fuego', 'Defensa', 10, 60, 64, 78, 69, 70, 64),
  (181, 'Danny', 'Wood', 'Masculino', 'Japones', 'Aire', 'Defensa', 10, 62, 68, 66, 79, 50, 53),
  (182, 'Wesley', 'Knox', 'Masculino', 'Japones', 'Bosque', 'Delantero', 10, 60, 76, 64, 63, 71, 64),
  (183, 'Andy', 'Chronic', 'Masculino', 'Japones', 'Bosque', 'Defensa', 10, 48, 66, 62, 79, 63, 61),
  (184, 'Artie', 'Mishman', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 10, 62, 66, 76, 67, 44, 45),
  (185, 'Ned', 'Yousef', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 10, 69, 78, 79, 67, 63, 62),
  (186, 'Arion', 'Matlock', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 10, 56, 69, 69, 68, 57, 62),
  (187, 'Jonas', 'Demetrius', 'Masculino', 'Japones', 'Fuego', 'Delantero', 10, 77, 64, 79, 56, 68, 63),
  (188, 'Gus', 'Heeley', 'Masculino', 'Japones', 'Montaña', 'Delantero', 10, 78, 69, 61, 50, 65, 60),
  (189, 'Harry', 'Closs', 'Masculino', 'Japones', 'Fuego', 'Defensa', 10, 63, 60, 66, 79, 69, 71),
  (190, 'Henry', 'House', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 10, 48, 68, 60, 67, 64, 70),
  (191, 'Byron', 'Love', 'Masculino', 'coreano', 'Bosque', 'Delantero', 10, 79, 69, 77, 70, 72, 68),
  (192, 'Paul', 'Siddon', 'Masculino', 'Japones', 'Montaña', 'Portero', 10, 79, 79, 71, 79, 44, 74);

-- Jugadores para el equipo "InazumaKidsFC"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (193, 'Taylor', 'Higgins', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 44, 43, 50, 48, 40, 48),
  (194, 'Hans', 'Randall', 'Masculino', 'Japones', 'Fuego', 'Delantero', 13, 64, 40, 40, 51, 48, 56),
  (195, 'Karl', 'Blue', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 13, 46, 48, 47, 44, 51, 46),
  (196, 'Ken', 'Cake', 'Masculino', 'Japones', 'Montaña', 'Delantero', 13, 49, 40, 40, 40, 51, 49),
  (197, 'Herman', 'Muller', 'Masculino', 'Japones', 'Aire', 'Portero', 13, 40, 50, 44, 47, 44, 46),
  (198, 'Mitch', 'Grumble', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 48, 48, 43, 48, 40, 46),
  (199, 'Michael', 'Riverside', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 13, 51, 46, 50, 49, 40, 43),
  (200, 'Keth', 'Claus', 'Masculino', 'Japones', 'Aire', 'Defensa', 13, 41, 41, 48, 40, 60, 40),
  (201, 'Jamie', 'Cool', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 47, 40, 44, 48, 52, 52),
  (202, 'Izzy', 'Island', 'Masculino', 'Japones', 'Bosque', 'Defensa', 13, 42, 40, 48, 41, 41, 48),
  (203, 'Theakston', 'Plank', 'Masculino', 'Japones', 'Aire', 'Delantero', 13, 48, 50, 42, 45, 58, 41),
  (204, 'Robert', 'Silver', 'Masculino', 'Japones', 'Aire', 'Defensa', 13, 46, 41, 51, 44, 41, 48),
  (205, 'Bart', 'Grantham', 'Masculino', 'Japones', 'Bosque', 'Portero', 13, 38, 35, 29, 66, 28, 29),
  (206, 'Irwin', 'Hall', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 13, 40, 48, 51, 43, 41, 40),
  (207, 'Sothern', 'Newman', 'Masculino', 'Japones', 'Montaña', 'Defensa', 13, 45, 44, 48, 60, 43, 49),
  (208, 'Maddie', 'Moonlight', 'Femenino', 'Japones', 'Bosque', 'Delantero', 13, 44, 40, 60, 42, 51, 40);

-- Jugadores para el equipo "Kirkwood"
INSERT INTO JUGADOR (id_jugador, nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  (209, 'John', 'Neville', 'Masculino', 'Japones', 'Fuego', 'Portero', 9, 78, 62, 54, 79, 48, 51),
  (210, 'York', 'Nashmith', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 52, 62, 57, 61, 54, 52),
  (211, 'Brody', 'Gloom', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 9, 54, 46, 48, 53, 45, 52),
  (212, 'Peter', 'Wells', 'Masculino', 'Japones', 'Aire', 'Defensa', 9, 55, 52, 52, 46, 47, 45),
  (213, 'Malcom', 'Night', 'Masculino', 'Japones', 'Fuego', 'Defensa', 9, 63, 76, 68, 78, 67, 64),
  (214, 'Victor', 'Talis', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 55, 52, 52, 46, 47, 45),
  (215, 'Thomas', 'Murdock', 'Masculino', 'Japones', 'Aire', 'Delantero', 9, 68, 70, 65, 60, 64, 62),
  (216, 'Zachary', 'Moore', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 52, 60, 60, 52, 63, 53),
  (217, 'Tyler', 'Murdock', 'Masculino', 'Japones', 'Montaña', 'Delantero', 9, 79, 64, 68, 56, 60, 59),
  (218, 'Dan', 'Mirthful', 'Masculino', 'Japones', 'Bosque', 'Defensa', 9, 59, 70, 49, 65, 46, 51),
  (219, 'Eren', 'Middleton', 'Masculino', 'Japones', 'Montaña', 'Defensa', 9, 48, 44, 55, 47, 55, 54),
  (220, 'Alfred', 'Meenan', 'Masculino', 'Japones', 'Bosque', 'Defensa', 9, 61, 55, 55, 60, 55, 53),
  (221, 'Simon', 'Calier', 'Masculino', 'Japones', 'Bosque', 'Portero', 9, 50, 41, 46, 71, 45, 48),
  (222, 'Ricky', 'Clover', 'Masculino', 'Japones', 'Montaña', 'Defensa', 9, 53, 52, 56, 52, 67, 45),
  (223, 'Marvin', 'Murdock', 'Masculino', 'Japones', 'Fuego', 'Delantero', 9, 68, 61, 61, 66, 60, 60),
  (224, 'Toby', 'Damian', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 9, 54, 56, 55, 56, 57, 56);

-- Posiciones POSIBLE TRANSFORMACIÓN A DISPARADOR
INSERT INTO PORTERO (id_jugador, paradas)
VALUES 
    (1, 0),
    (16, 0),
    (17, 0),
    (44, 0),
    (45, 0),
    (53, 0),
    (55, 0),
    (63, 0),
    (92, 0),
    (93, 0),
    (95, 0),
    (100, 0),
    (117, 0),
    (124, 0),
    (137, 0),
    (138, 0),
    (157, 0),
    (158, 0),
    (173, 0),
    (174, 0),
    (178, 0),
    (192, 0),
    (197, 0),
    (205, 0),
    (209, 0),
    (221, 0);

INSERT INTO DEFENSA (id_jugador, balones_robados)
VALUES 
    (2, 0),
    (3, 0),
    (4, 0),
    (5, 0),
    (6, 0),
    (18, 0),
    (19, 0),
    (20, 0),
    (39, 0),
    (41, 0),
    (42, 0),
    (43, 0),
    (46, 0),
    (47, 0),
    (48, 0),
    (49, 0),
    (50, 0),
    (51, 0),
    (52, 0),
    (54, 0),
    (60, 0),
    (64, 0),
    (65, 0),
    (66, 0),
    (77, 0),
    (78, 0),
    (87, 0),
    (89, 0),
    (90, 0),
    (94, 0),
    (96, 0),
    (97, 0),
    (98, 0),
    (99, 0),
    (110, 0),
    (116, 0),
    (118, 0),
    (119, 0),
    (120, 0),
    (121, 0),
    (122, 0),
    (123, 0),
    (130, 0),
    (139, 0),
    (140, 0),
    (141, 0),
    (142, 0),
    (145, 0),
    (146, 0),
    (147, 0),
    (148, 0),
    (149, 0),
    (150, 0),
    (151, 0),
    (160, 0),
    (170, 0),
    (171, 0),
    (172, 0),
    (176, 0),
    (177, 0),
    (179, 0),
    (180, 0),
    (181, 0),
    (183, 0),
    (189, 0),
    (200, 0),
    (202, 0),
    (204, 0),
    (207, 0),
    (212, 0),
    (213, 0),
    (218, 0),
    (219, 0),
    (220, 0),
    (222, 0);

INSERT INTO CENTROCAMPISTA (id_jugador, Regates_realizados)
VALUES 
    (7, 0),
    (8, 0),
    (9, 0),
    (10, 0),
    (15, 0),
    (21, 0),
    (22, 0),
    (23, 0),
    (24, 0),
    (25, 0),
    (34, 0),
    (35, 0),
    (36, 0),
    (37, 0),
    (38, 0),
    (40, 0),
    (56, 0),
    (57, 0),
    (59, 0),
    (61, 0),
    (62, 0),
    (67, 0),
    (68, 0),
    (69, 0),
    (70, 0),
    (72, 0),
    (76, 0),
    (79, 0),
    (80, 0),
    (81, 0),
    (82, 0),
    (85, 0),
    (86, 0),
    (101, 0),
    (102, 0),
    (103, 0),
    (104, 0),
    (111, 0),
    (112, 0),
    (113, 0),
    (125, 0),
    (128, 0),
    (134, 0),
    (135, 0),
    (136, 0),
    (143, 0),
    (152, 0),
    (153, 0),
    (154, 0),
    (155, 0),
    (156, 0),
    (164, 0),
    (165, 0),
    (166, 0),
    (167, 0),
    (168, 0),
    (169, 0),
    (184, 0),
    (185, 0),
    (186, 0),
    (190, 0),
    (193, 0),
    (195, 0),
    (198, 0),
    (199, 0),
    (201, 0),
    (206, 0),
    (210, 0),
    (211, 0),
    (214, 0),
    (216, 0),
    (224, 0);

INSERT INTO DELANTERO (id_jugador, disparos_a_puerta)
VALUES 
    (11, 0),
    (12, 0),
    (13, 0),
    (14, 0),
    (26, 0),
    (27, 0),
    (28, 0),
    (29, 0),
    (30, 0),
    (31, 0),
    (32, 0),
    (33, 0),
    (58, 0),
    (71, 0),
    (73, 0),
    (74, 0),
    (75, 0),
    (83, 0),
    (84, 0),
    (88, 0),
    (91, 0),
    (105, 0),
    (106, 0),
    (107, 0),
    (108, 0),
    (109, 0),
    (114, 0),
    (115, 0),
    (126, 0),
    (127, 0),
    (131, 0),
    (132, 0),
    (133, 0),
    (144, 0),
    (159, 0),
    (161, 0),
    (162, 0),
    (163, 0),
    (175, 0),
    (182, 0),
    (187, 0),
    (188, 0),
    (191, 0),
    (194, 0),
    (196, 0),
    (203, 0),
    (208, 0),
    (215, 0),
    (217, 0),
    (223, 0);

INSERT INTO SUPERTECNICA (id_supertecnica, nombre, elemento, tipo, cantidad_jugadores_con_supertecnica) 
VALUES
    (1, 'Triángulo Letal', 'Bosque', 'Tiro', 0),
    (2, 'Ciclón', 'Aire', 'Bloqueo', 0),
    (3, 'Chut de los 100 Toques', 'Bosque', 'Tiro', 0),
    (4, 'Mano Celestial', 'Montaña', 'Atajo', 0),
    (5, 'Tornado de Fuego', 'Fuego', 'Tiro', 0),
    (6, 'Remate Dragon', 'Bosque', 'Tiro', 0),
    (7, 'Tiro Fantasma', 'Bosque', 'Tiro', 0),
    (8, 'Espiral de Distorsión', 'Bosque', 'Atajo', 0),
    (9, 'Despeje de Fuego', 'Fuego', 'Atajo', 0),
    (10, 'Tornado Dragon', 'Fuego', 'Tiro', 0),
    (11, 'Superaceleración', 'Montaña', 'Regate', 0),
    (12, 'Ataque del Cóndor', 'Aire', 'Tiro', 0),
    (13, 'Remate Tarzán', 'Montaña', 'Tiro', 0),
    (14, 'Superarmadillo', 'Montaña', 'Bloqueo', 0),
    (15, 'Barrido Defensivo', 'Bosque', 'Bloqueo', 0),
    (16, 'Giro del Mono', 'Montaña', 'Regate', 0),
    (17, 'Remate Serpiente', 'Montaña', 'Tiro', 0),
    (18, 'Trampolín Relámpago', 'Aire', 'Tiro', 0),
    (19, 'Campo de Fuerza Defensivo', 'Bosque', 'Atajo', 0),
    (20, 'Despeje Cohete', 'Fuego', 'Atajo', 0),
    (21, 'Remate Misil', 'Fuego', 'Tiro', 0),
    (22, 'Super Relámpago', 'Aire', 'Tiro', 0),
    (23, 'Bola Falsa', 'Bosque', 'Regate', 0),
    (24, 'Bateo Total', 'Fuego', 'Tiro', 0),
    (25, 'Confusión', 'Montaña', 'Bloqueo', 0),
    (26, 'Deslizamiento de Porteria', 'Montaña', 'Atajo', 0),
    (27, 'Remate Glass', 'Montaña', 'Tiro', 0),
    (28, 'Chut Granada', 'Fuego', 'Tiro', 0),
    (29, 'Disparo Rodante', 'Bosque', 'Tiro', 0),
    (30, 'Escudo de Fuerza', 'Fuego', 'Atajo', 0),
    (31, 'Pingüino Emperador Nº2', 'Bosque', 'Tiro', 0),
    (32, 'Remate Combinado', 'Fuego', 'Tiro', 0),
    (33, 'Despeje Explosivo', 'Fuego', 'Atajo', 0),
    (34, 'Entrada Huracán', 'Aire', 'Regate', 0),
    (35, 'Torbellino Dragón', 'Aire', 'Regate', 0),
    (36, 'Escudo de Fuerza Total', 'Fuego', 'Atajo', 0),
    (37, 'Supertrampolín Relámpago', 'Aire', 'Tiro', 0),
    (38, 'Pase Cruzado', 'Aire', 'Tiro', 0),
    (39, 'Pájaro de Fuego', 'Fuego', 'Tiro', 0),
    (40, 'Espejismo', 'Bosque', 'Regate', 0),
    (41, 'Pisotón de Sumo', 'Montaña', 'Bloqueo', 0),
    (42, 'Torbellino', 'Aire', 'Atajo', 0),
    (43, 'Regate Múltiple', 'Bosque', 'Regate', 0),
    (44, 'Telaraña', 'Bosque', 'Bloqueo', 0),
    (45, 'Ataque de las Sombras', 'Bosque', 'Bloqueo', 0),
    (46, 'Bola de Fango', 'Montaña', 'Tiro', 0),
    (47, 'Remate Múltiple', 'Bosque', 'Regate', 0),
    (48, 'El Muro', 'Montaña', 'Bloqueo', 0),
    (49, 'Cabezazo Kung-fu', 'Bosque', 'Tiro', 0),
    (50, 'Regate Topo', 'Montaña', 'Regate', 0),
    (51, 'Superbalón Rodante', 'Bosque', 'Tiro', 0),
    (52, 'Tiro Cegador', 'Fuego', 'Tiro', 0),
    (53, 'Despeje de Leñador', 'Montaña', 'Atajo', 0),
    (54, 'Trama Trama', 'Montaña', 'Bloqueo', 0),
    (55, 'Muralla Infinita', 'Montaña', 'Atajo', 0),
    (56, 'Ruptura Relámpago', 'Aire', 'Tiro', 0),
    (57, 'Tiro Giratorio', 'Aire', 'Tiro', 0),
    (58, 'Tri-Pegaso', 'Aire', 'Tiro', 0),
    (59, 'Tornado Inverso', 'Aire', 'Tiro', 0),
    (60, 'Triángulo Z', 'Fuego', 'Tiro', 0),
    (61, 'Corte Giratorio', 'Aire', 'Bloqueo', 0),
    (62, 'Bloque Dureza', 'Montaña', 'Atajo', 0),
    (63, 'Flecha Huracán', 'Aire', 'Bloqueo', 0),
    (64, 'Fénix', 'Fuego', 'Tiro', 0),
    (65, 'Hora Celestial', 'Aire', 'Regate', 0),
    (66, 'Sabiduría Divina', 'Aire', 'Tiro', 0),
    (67, 'Muralla Tsunami', 'Aire', 'Atajo', 0),
    (68, 'Muralla Gigante', 'Montaña', 'Atajo', 0),
    (69, 'Entrada Tormenta', 'Aire', 'Regate', 0),
    (70, 'Disparo con Rebotes', 'Montaña', 'Tiro', 0),
    (71, 'Flecha Divina', 'Aire', 'Tiro', 0),
    (72, 'Mega Terremoto', 'Montaña', 'Bloqueo', 0),
    (73, 'Giro Bobina', 'Aire', 'Bloqueo', 0),
    (74, 'Mano Mágica', 'Montaña', 'Atajo', 0);

INSERT INTO SUPERTECNICA_JUGADOR(id_jugador, id_supertecnica)
VALUES 
    (23, 1),
    (29, 1),
    (30, 1),
    (19, 2),
    (30, 3),
    (1, 4),
    (63, 4),
    (13, 5),
    (32, 5),
    (12, 6),
    (86, 7),
    (88, 7),
    (92, 8),
    (1, 9),
    (12, 10),
    (13, 10),
    (5, 11),
    (163, 11),
    (165, 12),
    (162, 13),
    (176, 14),
    (4, 15),
    (21, 15),
    (168, 16),
    (175, 17),
    (2, 18),
    (13, 18),
    (45, 19),
    (45, 20),
    (32, 21),
    (1, 22),
    (13, 22),
    (101, 23),
    (107, 24),
    (108, 24),
    (96, 25),
    (98, 25),
    (101, 25),
    (103, 25),
    (107, 25),
    (108, 25),
    (109, 25),
    (100, 26),
    (12, 27),
    (14, 27),
    (9, 28),
    (7, 29),
    (16, 30),
    (10, 31),
    (12, 31),
    (13, 31),
    (15, 31),
    (29, 31),
    (30, 31),
    (10, 32),
    (15, 32),
    (29, 32),
    (1, 33),
    (6, 34),
    (8, 35),
    (16, 36),
    (1, 37),
    (2, 37),
    (13, 37),
    (11, 38),
    (71, 38),
    (6, 39),
    (13, 39),
    (64, 39),
    (73, 39),
    (131, 40),
    (135, 40),
    (130, 41),
    (139, 41),
    (137, 42),
    (135, 43),
    (134, 44),
    (142, 45),
    (131, 46),
    (133, 47),
    (2, 48),
    (8, 49),
    (57, 50),
    (56, 51),
    (58, 52),
    (55, 53),
    (48, 54),
    (51, 54),
    (59, 54),
    (54, 55),
    (55, 55),
    (60, 55),
    (1, 56),
    (10, 56),
    (13, 56),
    (15, 57),
    (1, 58),
    (4, 58),
    (15, 58),
    (213, 58),
    (215, 59),
    (217, 59),
    (223, 59),
    (215, 60),
    (217, 60),
    (223, 60),
    (5, 61),
    (213, 61),
    (209, 62),
    (218, 63),
    (220, 63),
    (222, 63),
    (1, 64),
    (4, 64),
    (15, 64),
    (213, 64),
    (191, 65),
    (191, 66),
    (192, 67),
    (192, 68),
    (187, 69),
    (187, 70),
    (190, 71),
    (181, 72),
    (3, 73),
    (1, 74);

INSERT INTO ESTADIO (nombre, cesped, tipo) 
VALUES
    ('Estadio Fútbol Frontier', 'Natural', 'Exterior'),
    ('Ribera del Río', 'Natural', 'Exterior'),
    ('Campo del Instituto Raimon', 'Natural', 'Exterior'),
    ('Campo del Instituto Wild', 'Artificial', 'Exterior'),
    ('Campo del Instituto Brain', 'Sin cesped', 'Exterior'),
    ('Campo del Instituto Otaku', 'Natural', 'Exterior'),
    ('Royal Academy', 'Sin cesped', 'Exterior'),
    ('Estadio Zeus', 'Natural', 'Cubierto');


INSERT INTO PARTIDO(id_partido, id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES
(1, 1, 2, 3, 1, 20, '2008-10-12 10:00:00'),
(2, 1, 3, 3, 4, 3, '2008-10-19 09:30:00'),
(3, 4, 1, 4, 0, 1, '2008-10-26 09:30:00'),
(4, 5, 1, 5, 1, 2, '2008-11-23 10:00:00'),
(5, 6, 1, 6, 1, 2, '2008-11-30 10:00:00'),
(6, 2, 1, 7, 1, 2, '2008-12-21 10:00:00'),
(7, 1, 11, 2, 3, 3, '2009-01-04 10:00:00'),
(8, 1, 7, 1, 2, 1, '2009-01-18 10:00:00'),
(9, 1, 8, 1, 2, 1, '2009-02-01 10:00:00'),
(10, 1, 9, 1, 3, 2, '2009-02-15 10:00:00'),
(11, 1, 10, 1, 4, 3, '2009-03-08 10:00:00');

INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo)
VALUES
('2008-10-05 17:00:00', 1, 'Instituto Raimon', 'Vuelta al campo'),
('2008-10-06 17:00:00', 1, 'Instituto Raimon', 'Tiro a puerta'),
('2008-10-07 17:00:00', 1, 'Ribera del río', 'Control de balon'),
('2008-10-08 17:00:00', 2, 'Instituto Royal', 'Control de balon'),
('2008-10-08 17:00:00', 3, 'Instituto Occult', 'Tiro a puerta'),
('2008-10-08 17:00:00', 4, 'Instituto Wild', 'Control de balon'),
('2008-10-09 17:00:00', 5, 'Instituto Brain', 'Vuelta al campo'),
('2008-10-12 11:00:00', 6, 'Instituto Otaku', 'Tiro a puerta');

-- Debería fallar
INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo)
VALUES('2008-10-12 11:00:00', 1, 'Instituto Raimon', 'Vuelta al campo');

INSERT INTO PARTIDO(id_partido, id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES(12, 1, 2, 3, 1, 20, '2008-10-05 16:00:00');