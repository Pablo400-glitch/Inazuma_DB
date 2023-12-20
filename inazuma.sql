-- Elimina la base de datos si existe
DROP DATABASE IF EXISTS prueba_db;

-- Crea una nueva base de datos
CREATE DATABASE prueba_db;

-- Conéctate a la nueva base de datos
USE prueba_db;


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

CREATE TABLE PARTIDO(
  id_partido SERIAL NOT NULL,
  id_equipo_local INTEGER not NULL,
  id_equipo_visitante INTEGER NOT NULL,
  id_estadio INTEGER NOT NULL,
  goles_local INTEGER DEFAULT 0 NOT NULL,
  goles_visitante INTEGER DEFAULT 0 NOT NULL,
  fecha TIMESTAMP NOT NULL,
  primary key(id_partido)
);

CREATE TABLE EQUIPO(
  id_equipo SERIAL NOT NULL,
  nombre VARCHAR(20) NOT NULL UNIQUE,
  pais VARCHAR(20) NOT NULL,
  victorias INTEGER DEFAULT 0 NOT NULL,
  goles_a_favor INTEGER DEFAULT 0 NOT NULL,
  goles_en_contra INTEGER DEFAULT 0 NOT NULL,
  PRIMARY key(id_equipo)
);

CREATE TABLE ENTRENAMIENTO(
  id_training SERIAL NOT NULL,
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
  cantidad_jugadores_con_supertecnica INTEGER DEFAULT 0 NOT NULL,
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
  paradas INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE DELANTERO(
  id_jugador INTEGER NOT NULL,
  disparos_a_puerta INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE DEFENSA(
  id_jugador INTEGER NOT NULL,
  balones_robados INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE CENTROCAMPISTA(
  id_jugador INTEGER NOT NULL,
  regates_realizados INTEGER DEFAULT 0 NOT NULL
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
ALTER TABLE EQUIPO ADD CONSTRAINT positive_wins_ties_loses CHECK (victorias >= 0);
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

-- Disparador que resta los goles a favor y en contra a los equipos al borrar un registro en la tabla PARTIDO
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
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica + 1 
  WHERE id_supertecnica = NEW.id_supertecnica;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER jugadores_con_supertecnica AFTER INSERT ON SUPERTECNICA_JUGADOR 
FOR EACH ROW EXECUTE PROCEDURE jugadores_con_supertecnica();

-- Disparador que actualiza los usuarios de supertécnicas
CREATE OR REPLACE FUNCTION actualizar_jugadores_con_supertecnica() RETURNS TRIGGER AS $$
BEGIN
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica - 1 
  WHERE id_supertecnica = OLD.id_supertecnica;
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica + 1 
  WHERE id_supertecnica = NEW.id_supertecnica;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_jugadores_con_supertecnica AFTER UPDATE ON SUPERTECNICA_JUGADOR 
FOR EACH ROW EXECUTE PROCEDURE actualizar_jugadores_con_supertecnica();

-- Disparador que actualiza los usuarios de supertécnicas al borrar un registro en la tabla PARTIDO
CREATE OR REPLACE FUNCTION restar_jugadores_con_supertecnica() RETURNS TRIGGER AS $$
BEGIN
  UPDATE SUPERTECNICA SET cantidad_jugadores_con_supertecnica = cantidad_jugadores_con_supertecnica - 1 
  WHERE id_supertecnica = OLD.id_supertecnica;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER restar_jugadores_con_supertecnica BEFORE DELETE ON SUPERTECNICA_JUGADOR 
FOR EACH ROW EXECUTE PROCEDURE restar_jugadores_con_supertecnica();

-- Disparador que valida la hora de inicio en un partido de un equipo
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

CREATE TRIGGER validar_horario_partido_insert BEFORE INSERT ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_horario_partido();
CREATE TRIGGER validar_horario_partido_update BEFORE UPDATE ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_horario_partido();

-- Disparador que valida la hora de inicio en un entrenamiento de un equipo
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

CREATE TRIGGER validar_horario_entrenamiento_insert BEFORE INSERT ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_horario_entrenamiento();
CREATE TRIGGER validar_horario_entrenamiento_update BEFORE UPDATE ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_horario_entrenamiento();

-- Disparador que valida la hora de inicio entre partidos del mismo equipo
CREATE OR REPLACE FUNCTION validar_partidos_mismo_equipo()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM PARTIDO 
    WHERE id_equipo_local = NEW.id_equipo_local AND id_partido != NEW.id_partido
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) OR EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE id_equipo_local = NEW.id_equipo_visitante AND id_partido != NEW.id_partido
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) or EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE id_equipo_visitante = NEW.id_equipo_local AND id_partido != NEW.id_partido
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) OR EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE id_equipo_visitante = NEW.id_equipo_visitante AND id_partido != NEW.id_partido
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar un partido dentro de las 2 horas anteriores o posteriores a otro partido del mismo equipo.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_partidos_mismo_equipo_insert BEFORE INSERT ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_partidos_mismo_equipo();
CREATE TRIGGER validar_partidos_mismo_equipo_update BEFORE UPDATE ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_partidos_mismo_equipo();

-- Disparador que valida la hora de inicio en un entrenamiento
CREATE OR REPLACE FUNCTION validar_entrenamientos_mismo_equipo()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE NEW.id_equipo = id_equipo AND id_training != NEW.id_training
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar un entrenamiento dentro de las 2 horas anteriores o posteriores a un entrenamiento del mismo equipo.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_entrenamientos_mismo_equipo_insert BEFORE INSERT ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_entrenamientos_mismo_equipo();
CREATE TRIGGER validar_entrenamientos_mismo_equipo_update BEFORE UPDATE ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_entrenamientos_mismo_equipo();

-- Disparador que valida el lugar en un partido
CREATE OR REPLACE FUNCTION validar_lugar_partido()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM PARTIDO
    WHERE id_estadio = NEW.id_estadio
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar el partido, el estadio está ocupado las 2 horas anteriores o posteriores.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_lugar_partido_insert BEFORE INSERT ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_lugar_partido();
CREATE TRIGGER validar_lugar_partido_update BEFORE UPDATE ON PARTIDO FOR EACH ROW EXECUTE FUNCTION validar_lugar_partido();

-- Disparador que valida el lugar en un entrenamiento de un equipo
CREATE OR REPLACE FUNCTION validar_lugar_entrenamiento()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE NEW.lugar = lugar
      AND ((fecha >= NEW.fecha AND fecha <= NEW.fecha + INTERVAL '2 hours') OR (fecha <= NEW.fecha AND fecha >= NEW.fecha - INTERVAL '2 hours'))
  ) THEN
    RAISE EXCEPTION 'No se puede programar un entrenamiento, el lugar está ocupado las 2 horas anteriores o posteriores.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_lugar_entrenamiento_insert BEFORE INSERT ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_lugar_entrenamiento();
CREATE TRIGGER validar_lugar_entrenamiento_update BEFORE UPDATE ON ENTRENAMIENTO FOR EACH ROW EXECUTE FUNCTION validar_lugar_entrenamiento();

-- Disparador que añade jugadores a las respectivas tablas de las posiciones
CREATE OR REPLACE FUNCTION insertar_jugador()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.posicion = 'Portero' THEN
    INSERT INTO PORTERO(id_jugador, paradas) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Defensa' THEN
    INSERT INTO DEFENSA(id_jugador, balones_robados) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Centrocampista' THEN
    INSERT INTO CENTROCAMPISTA(id_jugador, regates_realizados) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Delantero' THEN
    INSERT INTO DELANTERO(id_jugador, disparos_a_puerta) VALUES (NEW.id_jugador, 0);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insertar_jugador AFTER INSERT ON JUGADOR FOR EACH ROW EXECUTE FUNCTION insertar_jugador();

-- Disparador que elimina jugadores a las respectivas tablas de las posiciones
CREATE OR REPLACE FUNCTION eliminar_jugador()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.posicion = 'Portero' THEN
    DELETE FROM PORTERO WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Defensa' THEN
    DELETE FROM DEFENSA WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Centrocampista' THEN
    DELETE FROM CENTROCAMPISTA WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Delantero' THEN
    DELETE FROM DELANTERO WHERE id_jugador = OLD.id_jugador;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER eliminar_jugador AFTER DELETE ON JUGADOR FOR EACH ROW EXECUTE FUNCTION eliminar_jugador();

-- Disparador que actualiza jugadores a las respectivas tablas de las posiciones
CREATE OR REPLACE FUNCTION actualizar_jugador()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.posicion = 'Portero' THEN
    DELETE FROM PORTERO WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Defensa' THEN
    DELETE FROM DEFENSA WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Centrocampista' THEN
    DELETE FROM CENTROCAMPISTA WHERE id_jugador = OLD.id_jugador;
  ELSIF OLD.posicion = 'Delantero' THEN
    DELETE FROM DELANTERO WHERE id_jugador = OLD.id_jugador;
  END IF;

  IF NEW.posicion = 'Portero' THEN
    INSERT INTO PORTERO(id_jugador, paradas) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Defensa' THEN
    INSERT INTO DEFENSA(id_jugador, balones_robados) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Centrocampista' THEN
    INSERT INTO CENTROCAMPISTA(id_jugador, regates_realizados) VALUES (NEW.id_jugador, 0);
  ELSIF NEW.posicion = 'Delantero' THEN
    INSERT INTO DELANTERO(id_jugador, disparos_a_puerta) VALUES (NEW.id_jugador, 0);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_jugador AFTER DELETE ON JUGADOR FOR EACH ROW EXECUTE FUNCTION actualizar_jugador();

-- Disparador que comprueba la inclusividad (es necesario un entrenamiento para jugar un partido)
CREATE OR REPLACE FUNCTION inclusividad_equipo()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE NEW.id_equipo_local = id_equipo AND (fecha < NEW.fecha)
  )  THEN
    RAISE EXCEPTION 'No se puede programar un partido mientras el equipo local no haya hecho entrenamientos.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM ENTRENAMIENTO
    WHERE NEW.id_equipo_VISITANTE = id_equipo AND (fecha < NEW.fecha)
  ) THEN
    RAISE EXCEPTION 'No se puede programar un partido mientras el equipo visitante no haya hecho entrenamientos.';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inclusividad_equipo BEFORE INSERT ON PARTIDO FOR EACH ROW EXECUTE FUNCTION inclusividad_equipo();




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
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES 
  ('Mark', 'Evans', 'Masculino', 'Japones', 'Montaña', 'Portero', 1, 72, 72, 77, 70, 79, 68),
  ('Jack', 'Wallside', 'Masculino', 'Japones', 'Montaña', 'Defensa', 1, 62, 68, 66, 62, 54, 49),
  ('Jim', 'Wraith', 'Masculino', 'Japones', 'Bosque', 'Defensa', 1, 58, 53, 59, 75, 60, 53),
  ('Bobby', 'Shearer', 'Masculino', 'estadounidense', 'Bosque', 'Defensa', 1, 76, 61, 76, 72, 72, 60),
  ('Tod', 'Ironside', 'Masculino', 'Japones', 'Fuego', 'Defensa', 1, 54, 55, 56, 53, 65, 59),
  ('Nathan', 'Swift', 'Masculino', 'Japones', 'Aire', 'Defensa', 1, 64, 58, 54, 68, 56, 76),
  ('Steve', 'Grim', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 1, 62, 64, 64, 71, 71, 71),
  ('Tim', 'Saunders', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 1, 63, 76, 60, 61, 58, 55),
  ('Sam', 'Kincaid', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 1, 71, 57, 56, 56, 76, 52),
  ('Jude', 'Sharp', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 1, 63, 79, 79, 79, 68, 76),
  ('Maxwell', 'Carson', 'Masculino', 'Japones', 'Aire', 'Delantero', 1, 60, 56, 64, 78, 62, 60),
  ('Kevin', 'Dragonfly', 'Masculino', 'Japones', 'Bosque', 'Delantero', 1, 71, 60, 61, 59, 70, 60),
  ('Axel', 'Blaze', 'Masculino', 'Japones', 'Fuego', 'Delantero', 1, 79, 66, 64, 76, 60, 72),
  ('William', 'Glass', 'Masculino', 'Japones', 'Bosque', 'Delantero', 1, 56, 51, 57, 68, 60, 56),
  ('Erik', 'Eagle', 'Masculino', 'estadounidense', 'Bosque', 'Centrocampista', 1, 53, 59, 52, 64, 69, 51);

-- Jugadores para el equipo "Royal Academy"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES 
  ('Joe', 'King', 'Masculino', 'Japones', 'Fuego', 'Portero', 2, 72, 75, 72, 69, 60, 55),
  ('Bob', 'Carlton', 'Masculino', 'Japones', 'Bosque', 'Portero', 2, 58, 55, 54, 63, 70, 45),
  ('Peter', 'Drent', 'Masculino', 'Japones', 'Montaña', 'Defensa', 2, 71, 54, 64, 67, 62, 44),
  ('Ben', 'Simmons', 'Masculino', 'Japones', 'Bosque', 'Defensa', 2, 68, 63, 60, 72, 69, 69),
  ('Gus', 'Martin', 'Masculino', 'Japones', 'Bosque', 'Defensa', 2, 76, 67, 67, 73, 63, 63),
  ('Alan', 'Master', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 64, 64, 69, 72, 66, 64),
  ('John', 'Bloom', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 2, 61, 71, 70, 67, 62, 71),
  ('Derek', 'Swing', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 70, 56, 59, 76, 61, 69),
  ('Herman', 'Waldon', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 76, 64, 79, 72, 69, 70),
  ('Barry', 'Potts', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 2, 53, 52, 56, 54, 44, 52),
  ('Cliff', 'Tomlinson', 'Masculino', 'Japones', 'Aire', 'Delantero', 2, 53, 60, 61, 52, 53, 54),
  ('Steve', 'Ingham', 'Masculino', 'Japones', 'Montaña', 'Delantero', 2, 61, 53, 52, 57, 46, 47),
  ('Jim', 'Lawrenson', 'Masculino', 'Japones', 'Aire', 'Delantero', 2, 54, 57, 63, 57, 55, 53),
  ('David', 'Samford', 'Masculino', 'Japones', 'Bosque', 'Delantero', 2, 70, 60, 66, 78, 71, 66),
  ('Daniel', 'Hatch', 'Masculino', 'Japones', 'Bosque', 'Delantero', 2, 75, 69, 68, 68, 64, 78);

-- Jugadores para el equipo "Brain"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, Regate, defensa, control, rapidez, aguante)
VALUES
  ('Jonathan', 'Seller', 'Masculino', 'Japones', 'Aire', 'Delantero', 5, 55, 50, 50, 49, 55, 45),
  ('Neil', 'Turner', 'Masculino', 'Japones', 'Fuego', 'Delantero', 5, 48, 48, 52, 52, 44, 50),
  ('Clive', 'Mooney', 'Masculino', 'Japones', 'Fuego', 'Delantero', 5, 53, 49, 54, 50, 55, 53),
  ('Victor', 'Kind', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 5, 49, 53, 48, 51, 48, 53),
  ('Tyron', 'Rock', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 5, 51, 46, 46, 48, 48, 47),
  ('Francis', 'Tell', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 5, 44, 53, 48, 46, 45, 44),
  ('Charles', 'Oughtry', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 5, 55, 52, 45, 45, 46, 44),
  ('Patrick', 'Stiller', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 5, 53, 45, 47, 52, 44, 46),
  ('Harry', 'Leading', 'Masculino', 'Japones', 'Aire', 'Defensa', 5, 52, 52, 44, 47, 50, 52),
  ('Samuel', 'Buster', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 5, 55, 46, 52, 49, 48, 50),
  ('Terry', 'Stronger', 'Masculino', 'Japones', 'Fuego', 'Defensa', 5, 44, 46, 46, 52, 47, 52),
  ('Noel', 'Good', 'Masculino', 'Japones', 'Bosque', 'Defensa', 5, 44, 44, 48, 55, 44, 48),
  ('Neil', 'Waters', 'Masculino', 'Japones', 'Bosque', 'Defensa', 5, 52, 48, 51, 52, 45, 54),
  ('Reg', 'Underwood', 'Masculino', 'Japones', 'Bosque', 'Portero', 5, 44, 40, 40, 69, 48, 42),
  ('Thomas', 'Feldt', 'Masculino', 'Japones', 'Bosque', 'Portero', 5, 75, 69, 68, 76, 75, 78),
  ('Philip', 'Marvel', 'Masculino', 'Japones', 'Montaña', 'Defensa', 5, 44, 53, 52, 48, 49, 50);

-- Jugadores para el equipo "Farm"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Rolf', 'Howells', 'Masculino', 'Japones', 'Aire', 'Defensa', 8, 48, 62, 54, 75, 54, 60),
  ('Kent', 'Work', 'Masculino', 'Japones', 'Bosque', 'Defensa', 8, 44, 57, 54, 70, 54, 65),
  ('Ben', 'Nevis', 'Masculino', 'Japones', 'Aire', 'Defensa', 8, 52, 56, 51, 70, 59, 64),
  ('Homer', 'Grower', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 53, 53, 44, 76, 61, 68),
  ('Seward', 'Hayseed', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 42, 56, 52, 77, 58, 68),
  ('Luke', 'Lively', 'Masculino', 'Japones', 'Bosque', 'Defensa', 8, 47, 57, 44, 73, 56, 63),
  ('Lorne', 'Mower', 'Masculino', 'Japones', 'Montaña', 'Portero', 8, 46, 56, 41, 72, 62, 61),
  ('Herb', 'Sherman', 'Masculino', 'Japones', 'Fuego', 'Defensa', 8, 49, 60, 62, 79, 52, 70),
  ('Albert', 'Green', 'Masculino', 'Japones', 'Fuego', 'Portero', 8, 50, 53, 60, 73, 53, 64),
  ('Tom', 'Walters', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 8, 63, 58, 52, 73, 71, 61),
  ('Ike', 'Steiner', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 8, 42, 55, 63, 76, 53, 60),
  ('Stuart', 'Racoonfur', 'Masculino', 'Japones', 'Bosque', 'Delantero', 8, 56, 62, 62, 74, 66, 63),
  ('Joe', 'Small', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 8, 40, 54, 54, 68, 56, 63),
  ('Mark', 'Hillvalley', 'Masculino', 'Japones', 'Montaña', 'Defensa', 8, 40, 56, 52, 79, 63, 66),
  ('Daniel', 'Dawson', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 8, 57, 55, 56, 75, 64, 66),
  ('Orville', 'Newman', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 8, 71, 70, 46, 72, 62, 66);

-- Jugadores para el equipo "InazumaEleven"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Seymour', 'Hillman', 'Masculino', 'Japones', 'Montaña', 'Portero', 11, 70, 68, 64, 71, 68, 75),
  ('Charles', 'Island', 'Masculino', 'Japones', 'Bosque', 'Defensa', 11, 71, 79, 71, 68, 69, 63),
  ('Garret', 'Hairtown', 'Masculino', 'Japones', 'Aire', 'Defensa', 11, 70, 65, 65, 62, 73, 60),
  ('Arthur', 'Sweet', 'Masculino', 'Japones', 'Montaña', 'Defensa', 11, 62, 75, 78, 68, 68, 67),
  ('Peter', 'Mildred', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 11, 72, 71, 69, 70, 74, 69),
  ('Josh', 'Nathaniel', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 11, 64, 73, 73, 75, 71, 66),
  ('Edward', 'Gladstone', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 11, 68, 66, 68, 60, 72, 63),
  ('Tyler', 'Thomas', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 11, 73, 72, 76, 76, 79, 72),
  ('Joseph', 'Yosemite', 'Masculino', 'Japones', 'Aire', 'Delantero', 11, 62, 72, 72, 76, 65, 72),
  ('Ian', 'Suffolk', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 11, 71, 68, 70, 69, 77, 68),
  ('Constant', 'Builder', 'Masculino', 'Japones', 'Fuego', 'Delantero', 11, 69, 69, 64, 60, 63, 77),
  ('Ted', 'Poe', 'Masculino', 'Japones', 'Bosque', 'Delantero', 11, 64, 68, 79, 70, 69, 64),
  ('Marshall', 'Heart', 'Masculino', 'Japones', 'Aire', 'Delantero', 11, 60, 62, 66, 63, 72, 65),
  ('Dom', 'Foreman', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 11, 76, 72, 64, 64, 68, 72),
  ('Slot', 'MacHines', 'Masculino', 'Japones', 'Fuego', 'Defensa', 11, 68, 68, 75, 71, 76, 68),
  ('Bill', 'Steakspear', 'Masculino', 'Japones', 'Montaña', 'Defensa', 11, 62, 75, 78, 68, 68, 67);

-- Jugadores para el equipo "Occult"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Robert', 'Mayer', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 3, 54, 52, 60, 52, 62, 75),
  ('Mick', 'Askley', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 3, 55, 50, 54, 44, 48, 56),
  ('Burt', 'Wolf', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 3, 68, 52, 52, 51, 56, 62),
  ('Alexander', 'Brave', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 3, 57, 65, 60, 52, 71, 56),
  ('Phil', 'Noir', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 52, 45, 48, 52, 52, 58),
  ('Chuck', 'Dollman', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 52, 53, 45, 48, 49, 53),
  ('Ray', 'Mannings', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 3, 55, 62, 60, 52, 56, 61),
  ('Troy', 'Moon', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 3, 61, 70, 77, 52, 79, 69),
  ('Jason', 'Jones', 'Masculino', 'Japones', 'Aire', 'Defensa', 3, 52, 54, 57, 57, 60, 54),
  ('Johan', 'Tassman', 'Masculino', 'Japones', 'Bosque', 'Delantero', 3, 62, 64, 56, 48, 60, 62),
  ('Ken', 'Furan', 'Masculino', 'Japones', 'Montaña', 'Defensa', 3, 55, 59, 47, 70, 52, 61),
  ('Russell', 'Walk', 'Masculino', 'Japones', 'Bosque', 'Defensa', 3, 60, 53, 60, 52, 63, 65),
  ('Uxley', 'Allen', 'Masculino', 'Japones', 'Aire', 'Delantero', 3, 48, 51, 51, 50, 48, 55),
  ('Nathan', 'Jones', 'Masculino', 'Japones', 'Aire', 'Portero', 3, 58, 56, 70, 68, 56, 60),
  ('Rob', 'Crombie', 'Masculino', 'Japones', 'Montaña', 'Portero', 3, 47, 46, 50, 40, 51, 74),
  ('Jerry', 'Fulton', 'Masculino', 'Japones', 'Fuego', 'Defensa', 3, 52, 58, 56, 61, 56, 79);

-- Jugadores para el equipo "Otaku"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Grant', 'Eldorado', 'Masculino', 'Japones', 'Fuego', 'Portero', 6, 49, 63, 61, 69, 43, 28),
  ('Marcus', 'Train', 'Masculino', 'Japones', 'Fuego', 'Defensa', 6, 61, 60, 53, 56, 52, 41),
  ('Mike', 'Vox', 'Masculino', 'Japones', 'Aire', 'Defensa', 6, 48, 55, 57, 51, 44, 50),
  ('Spencer', 'Gates', 'Masculino', 'Japones', 'Montaña', 'Defensa', 6, 59, 52, 56, 58, 56, 40),
  ('Bill', 'Formby', 'Masculino', 'Japones', 'Montaña', 'Defensa', 6, 54, 58, 61, 45, 46, 48),
  ('Sam', 'Idol', 'Masculino', 'Japones', 'Montaña', 'Portero', 6, 60, 58, 54, 55, 58, 45),
  ('Walter', 'Valiant', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 6, 62, 62, 61, 55, 56, 50),
  ('Ham', 'Signalman', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 6, 54, 56, 55, 52, 53, 48),
  ('Anthony', 'Woodbridge', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 6, 60, 60, 52, 58, 54, 41),
  ('Light', 'Nobel', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 6, 60, 55, 56, 58, 61, 44),
  ('Josh', 'Spear', 'Masculino', 'Japones', 'Bosque', 'Delantero', 6, 54, 56, 56, 62, 55, 44),
  ('Gaby', 'Farmer', 'Masculino', 'Japones', 'Aire', 'Delantero', 6, 58, 62, 52, 61, 54, 47),
  ('Gus', 'Gamer', 'Masculino', 'Japones', 'Fuego', 'Delantero', 6, 58, 60, 59, 52, 55, 45),
  ('Mark', 'Gambling', 'Masculino', 'Japones', 'Aire', 'Delantero', 6, 52, 56, 58, 63, 53, 51),
  ('Theodore', 'Master', 'Masculino', 'Japones', 'Bosque', 'Delantero', 6, 57, 57, 55, 56, 52, 47),
  ('Ollie', 'Webb', 'Masculino', 'Japones', 'Bosque', 'Defensa', 6, 44, 62, 54, 48, 44, 51);


-- Jugadores para el equipo "Sally's"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Fayette', 'Riversong', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 12, 40, 50, 50, 48, 40, 42),
  ('Lizzy', 'Squirrel', 'Femenino', 'Japones', 'Aire', 'Centrocampista', 12, 43, 44, 50, 45, 47, 45),
  ('Mitch', 'Sandstone', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 12, 54, 58, 41, 48, 45, 46),
  ('Eddie', 'Prentice', 'Masculino', 'Japones', 'Montaña', 'Delantero', 12, 46, 46, 56, 44, 42, 48),
  ('Dough', 'Baughan', 'Masculino', 'Japones', 'Aire', 'Delantero', 12, 45, 41, 46, 48, 40, 51),
  ('Ness', 'Sheldon', 'Masculino', 'Japones', 'Montaña', 'Defensa', 12, 42, 48, 45, 53, 42, 40),
  ('Suzanne', 'Yuma', 'Femenino', 'Japones', 'Montaña', 'Portero', 12, 44, 44, 43, 56, 49, 46),
  ('Ian', 'Stager', 'Masculino', 'Japones', 'Bosque', 'Defensa', 12, 40, 49, 44, 51, 49, 50),
  ('Fred', 'Crumb', 'Masculino', 'Japones', 'Montaña', 'Defensa', 12, 40, 44, 44, 43, 44, 48),
  ('Louis', 'Hillside', 'Masculino', 'Japones', 'Fuego', 'Defensa', 12, 60, 52, 51, 41, 41, 48),
  ('Tammy', 'Fielding', 'Femenino', 'Japones', 'Bosque', 'Defensa', 12, 44, 49, 48, 51, 48, 44),
  ('Alex', 'Lovely', 'Femenino', 'Japones', 'Aire', 'Defensa', 12, 49, 44, 44, 44, 44, 51),
  ('Pip', 'Daltry', 'Femenino', 'Japones', 'Bosque', 'Defensa', 12, 44, 45, 49, 51, 49, 40),
  ('Alf', 'Holmes', 'Masculino', 'Japones', 'Bosque', 'Portero', 12, 34, 28, 34, 64, 39, 31),
  ('Kippy', 'Jones', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 12, 48, 51, 47, 51, 43, 42),
  ('Samantha', 'Moonlight', 'Femenino', 'Japones', 'Aire', 'Delantero', 12, 52, 43, 42, 48, 41, 44),
  ('Eddie', 'Prentice', 'Masculino', 'Japones', 'Bosque', 'Delantero', 12, 46, 46, 56, 44, 42, 48);

-- Jugadores para el equipo "Shuriken"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Winston', 'Falls', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 56, 56, 52, 63, 64, 55),
  ('Cal', 'Trops', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 7, 58, 61, 69, 55, 59, 57),
  ('Galen', 'Thunderbird', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 63, 60, 63, 62, 54, 57),
  ('Sail', 'Bluesea', 'Masculino', 'Japones', 'Fuego', 'Delantero', 7, 52, 61, 61, 54, 60, 68),
  ('John', 'Reynolds', 'Masculino', 'Japones', 'Aire', 'Delantero', 7, 62, 56, 56, 53, 60, 54),
  ('Sam', 'Samurai', 'Masculino', 'Japones', 'Bosque', 'Delantero', 7, 60, 60, 60, 60, 56, 60),
  ('Phil', 'Wingate', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 7, 60, 56, 60, 57, 54, 68),
  ('Hank', 'Sullivan', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 7, 60, 55, 59, 44, 60, 60),
  ('Jez', 'Shell', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 53, 63, 59, 56, 47, 65),
  ('Morgan', 'Sanders', 'Masculino', 'Japones', 'Bosque', 'Portero', 7, 53, 59, 44, 64, 52, 55),
  ('Kevin', 'Castle', 'Masculino', 'Japones', 'Aire', 'Portero', 7, 53, 60, 52, 68, 52, 52),
  ('Finn', 'Stoned', 'Masculino', 'Japones', 'Fuego', 'Defensa', 7, 54, 53, 57, 56, 55, 58),
  ('Newton', 'Flust', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 62, 61, 56, 60, 55, 60),
  ('Dan', 'Hopper', 'Masculino', 'Japones', 'Montaña', 'Defensa', 7, 52, 58, 62, 62, 55, 61),
  ('Jim', 'Hillfort', 'Masculino', 'Japones', 'Aire', 'Defensa', 7, 55, 62, 60, 53, 54, 63),
  ('Jupiter', 'Jumper', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 7, 56, 61, 53, 56, 69, 68);

-- Jugadores para el equipo "Umbrella"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Greg', 'Bernard', 'Masculino', 'Japones', 'Bosque', 'Delantero', 14, 49, 55, 63, 51, 51, 56),
  ('Kendall', 'Sefton', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 53, 49, 61, 54, 67, 54),
  ('Paul', 'Caperock', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 54, 50, 46, 45, 58, 48),
  ('Jason', 'Strike', 'Masculino', 'Japones', 'Fuego', 'Defensa', 14, 48, 50, 64, 47, 56, 51),
  ('Maxwell', 'Claus', 'Masculino', 'Japones', 'Bosque', 'Defensa', 14, 62, 63, 55, 44, 53, 55),
  ('Norman', 'Porter', 'Masculino', 'Japones', 'Montaña', 'Defensa', 14, 45, 56, 44, 60, 44, 52),
  ('Julius', 'Molehill', 'Masculino', 'Japones', 'Aire', 'Defensa', 14, 53, 48, 68, 48, 55, 49),
  ('Alan', 'Most', 'Masculino', 'Japones', 'Montaña', 'Defensa', 14, 65, 60, 60, 68, 63, 61),
  ('Bruce', 'Chaney', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 14, 46, 48, 48, 45, 66, 48),
  ('Leroy', 'Rhymes', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 14, 47, 48, 52, 53, 46, 45),
  ('Saul', 'Tunk', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 14, 55, 53, 44, 62, 55, 47),
  ('Cameron', 'Morefield', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 14, 59, 56, 58, 52, 48, 52),
  ('Mildford', 'Scott', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 14, 44, 52, 47, 50, 55, 52),
  ('Peter', 'Banker', 'Masculino', 'Japones', 'Aire', 'Portero', 14, 50, 45, 51, 63, 50, 45),
  ('Joe', 'Ingram', 'Masculino', 'Japones', 'Fuego', 'Portero', 14, 44, 71, 52, 74, 47, 57),
  ('Lou', 'Edmonds', 'Masculino', 'Japones', 'Fuego', 'Delantero', 14, 68, 45, 51, 44, 54, 71),
  ('Alan', 'Most', 'Masculino', 'Japones', 'Fuego', 'Defensa', 14, 65, 60, 60, 68, 63, 61);

-- Jugadores para el equipo "Wild"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Philip', 'Anders', 'Masculino', 'Japones', 'Fuego', 'Delantero', 4, 52, 51, 48, 52, 52, 51),
  ('Gary', 'Lancaster', 'Masculino', 'Japones', 'Montaña', 'Delantero', 4, 78, 66, 49, 64, 54, 52),
  ('Adrian', 'Speed', 'Masculino', 'Japones', 'Aire', 'Delantero', 4, 63, 47, 69, 55, 79, 42),
  ('Hugo', 'Talgeese', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 4, 44, 52, 56, 46, 64, 67),
  ('Steve', 'Eagle', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 61, 68, 62, 52, 68, 71),
  ('Alan', 'Coe', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 4, 52, 45, 53, 51, 48, 46),
  ('Matt', 'Mouseman', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 4, 42, 50, 52, 44, 79, 54),
  ('Bruce', 'Monkey', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 54, 64, 51, 48, 53, 52),
  ('Cham', 'Lion', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 4, 44, 45, 45, 55, 53, 60),
  ('Rocky', 'Rackham', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 53, 53, 53, 44, 51, 44),
  ('Wilson', 'Fishman', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 52, 64, 51, 51, 51, 62),
  ('Peter', 'Johnson', 'Masculino', 'Japones', 'Bosque', 'Defensa', 4, 48, 52, 48, 48, 54, 57),
  ('Chad', 'Bullford', 'Masculino', 'Japones', 'Fuego', 'Portero', 4, 41, 68, 48, 77, 31, 51),
  ('Charlie', 'Boardfield', 'Masculino', 'Japones', 'Fuego', 'Portero', 4, 68, 44, 44, 69, 60, 62),
  ('Harry', 'Snake', 'Masculino', 'Japones', 'Bosque', 'Delantero', 4, 55, 63, 62, 49, 55, 65),
  ('Leonard', 'O`Shea', 'Masculino', 'Japones', 'Montaña', 'Defensa', 4, 78, 52, 47, 64, 55, 69);

-- Jugadores para el equipo "Zeus"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Lane', 'War', 'Masculino', 'Japones', 'Montaña', 'Defensa', 10, 71, 79, 70, 72, 56, 57),
  ('Iggy', 'Russ', 'Masculino', 'Japones', 'Aire', 'Portero', 10, 71, 67, 66, 79, 44, 71),
  ('Apollo', 'Light', 'Masculino', 'Japones', 'Bosque', 'Defensa', 10, 79, 79, 62, 73, 53, 48),
  ('Jeff', 'Iron', 'Masculino', 'Japones', 'Fuego', 'Defensa', 10, 60, 64, 78, 69, 70, 64),
  ('Danny', 'Wood', 'Masculino', 'Japones', 'Aire', 'Defensa', 10, 62, 68, 66, 79, 50, 53),
  ('Wesley', 'Knox', 'Masculino', 'Japones', 'Bosque', 'Delantero', 10, 60, 76, 64, 63, 71, 64),
  ('Andy', 'Chronic', 'Masculino', 'Japones', 'Bosque', 'Defensa', 10, 48, 66, 62, 79, 63, 61),
  ('Artie', 'Mishman', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 10, 62, 66, 76, 67, 44, 45),
  ('Ned', 'Yousef', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 10, 69, 78, 79, 67, 63, 62),
  ('Arion', 'Matlock', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 10, 56, 69, 69, 68, 57, 62),
  ('Jonas', 'Demetrius', 'Masculino', 'Japones', 'Fuego', 'Delantero', 10, 77, 64, 79, 56, 68, 63),
  ('Gus', 'Heeley', 'Masculino', 'Japones', 'Montaña', 'Delantero', 10, 78, 69, 61, 50, 65, 60),
  ('Harry', 'Closs', 'Masculino', 'Japones', 'Fuego', 'Defensa', 10, 63, 60, 66, 79, 69, 71),
  ('Henry', 'House', 'Masculino', 'Japones', 'Fuego', 'Centrocampista', 10, 48, 68, 60, 67, 64, 70),
  ('Byron', 'Love', 'Masculino', 'coreano', 'Bosque', 'Delantero', 10, 79, 69, 77, 70, 72, 68),
  ('Paul', 'Siddon', 'Masculino', 'Japones', 'Montaña', 'Portero', 10, 79, 79, 71, 79, 44, 74);

-- Jugadores para el equipo "InazumaKidsFC"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('Taylor', 'Higgins', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 44, 43, 50, 48, 40, 48),
  ('Hans', 'Randall', 'Masculino', 'Japones', 'Fuego', 'Delantero', 13, 64, 40, 40, 51, 48, 56),
  ('Karl', 'Blue', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 13, 46, 48, 47, 44, 51, 46),
  ('Ken', 'Cake', 'Masculino', 'Japones', 'Montaña', 'Delantero', 13, 49, 40, 40, 40, 51, 49),
  ('Herman', 'Muller', 'Masculino', 'Japones', 'Aire', 'Portero', 13, 40, 50, 44, 47, 44, 46),
  ('Mitch', 'Grumble', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 48, 48, 43, 48, 40, 46),
  ('Michael', 'Riverside', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 13, 51, 46, 50, 49, 40, 43),
  ('Keth', 'Claus', 'Masculino', 'Japones', 'Aire', 'Defensa', 13, 41, 41, 48, 40, 60, 40),
  ('Jamie', 'Cool', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 13, 47, 40, 44, 48, 52, 52),
  ('Izzy', 'Island', 'Masculino', 'Japones', 'Bosque', 'Defensa', 13, 42, 40, 48, 41, 41, 48),
  ('Theakston', 'Plank', 'Masculino', 'Japones', 'Aire', 'Delantero', 13, 48, 50, 42, 45, 58, 41),
  ('Robert', 'Silver', 'Masculino', 'Japones', 'Aire', 'Defensa', 13, 46, 41, 51, 44, 41, 48),
  ('Bart', 'Grantham', 'Masculino', 'Japones', 'Bosque', 'Portero', 13, 38, 35, 29, 66, 28, 29),
  ('Irwin', 'Hall', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 13, 40, 48, 51, 43, 41, 40),
  ('Sothern', 'Newman', 'Masculino', 'Japones', 'Montaña', 'Defensa', 13, 45, 44, 48, 60, 43, 49),
  ('Maddie', 'Moonlight', 'Femenino', 'Japones', 'Bosque', 'Delantero', 13, 44, 40, 60, 42, 51, 40);

-- Jugadores para el equipo "Kirkwood"
INSERT INTO JUGADOR (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante)
VALUES
  ('John', 'Neville', 'Masculino', 'Japones', 'Fuego', 'Portero', 9, 78, 62, 54, 79, 48, 51),
  ('York', 'Nashmith', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 52, 62, 57, 61, 54, 52),
  ('Brody', 'Gloom', 'Masculino', 'Japones', 'Montaña', 'Centrocampista', 9, 54, 46, 48, 53, 45, 52),
  ('Peter', 'Wells', 'Masculino', 'Japones', 'Aire', 'Defensa', 9, 55, 52, 52, 46, 47, 45),
  ('Malcom', 'Night', 'Masculino', 'Japones', 'Fuego', 'Defensa', 9, 63, 76, 68, 78, 67, 64),
  ('Victor', 'Talis', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 55, 52, 52, 46, 47, 45),
  ('Thomas', 'Murdock', 'Masculino', 'Japones', 'Aire', 'Delantero', 9, 68, 70, 65, 60, 64, 62),
  ('Zachary', 'Moore', 'Masculino', 'Japones', 'Bosque', 'Centrocampista', 9, 52, 60, 60, 52, 63, 53),
  ('Tyler', 'Murdock', 'Masculino', 'Japones', 'Montaña', 'Delantero', 9, 79, 64, 68, 56, 60, 59),
  ('Dan', 'Mirthful', 'Masculino', 'Japones', 'Bosque', 'Defensa', 9, 59, 70, 49, 65, 46, 51),
  ('Eren', 'Middleton', 'Masculino', 'Japones', 'Montaña', 'Defensa', 9, 48, 44, 55, 47, 55, 54),
  ('Alfred', 'Meenan', 'Masculino', 'Japones', 'Bosque', 'Defensa', 9, 61, 55, 55, 60, 55, 53),
  ('Simon', 'Calier', 'Masculino', 'Japones', 'Bosque', 'Portero', 9, 50, 41, 46, 71, 45, 48),
  ('Ricky', 'Clover', 'Masculino', 'Japones', 'Montaña', 'Defensa', 9, 53, 52, 56, 52, 67, 45),
  ('Marvin', 'Murdock', 'Masculino', 'Japones', 'Fuego', 'Delantero', 9, 68, 61, 61, 66, 60, 60),
  ('Toby', 'Damian', 'Masculino', 'Japones', 'Aire', 'Centrocampista', 9, 54, 56, 55, 56, 57, 56);

INSERT INTO SUPERTECNICA (nombre, elemento, tipo, cantidad_jugadores_con_supertecnica) 
VALUES
    ('Triángulo Letal', 'Bosque', 'Tiro', 0),
    ('Ciclón', 'Aire', 'Bloqueo', 0),
    ('Chut de los 100 Toques', 'Bosque', 'Tiro', 0),
    ('Mano Celestial', 'Montaña', 'Atajo', 0),
    ('Tornado de Fuego', 'Fuego', 'Tiro', 0),
    ('Remate Dragon', 'Bosque', 'Tiro', 0),
    ('Tiro Fantasma', 'Bosque', 'Tiro', 0),
    ('Espiral de Distorsión', 'Bosque', 'Atajo', 0),
    ('Despeje de Fuego', 'Fuego', 'Atajo', 0),
    ('Tornado Dragon', 'Fuego', 'Tiro', 0),
    ('Superaceleración', 'Montaña', 'Regate', 0),
    ('Ataque del Cóndor', 'Aire', 'Tiro', 0),
    ('Remate Tarzán', 'Montaña', 'Tiro', 0),
    ('Superarmadillo', 'Montaña', 'Bloqueo', 0),
    ('Barrido Defensivo', 'Bosque', 'Bloqueo', 0),
    ('Giro del Mono', 'Montaña', 'Regate', 0),
    ('Remate Serpiente', 'Montaña', 'Tiro', 0),
    ('Trampolín Relámpago', 'Aire', 'Tiro', 0),
    ('Campo de Fuerza Defensivo', 'Bosque', 'Atajo', 0),
    ('Despeje Cohete', 'Fuego', 'Atajo', 0),
    ('Remate Misil', 'Fuego', 'Tiro', 0),
    ('Super Relámpago', 'Aire', 'Tiro', 0),
    ('Bola Falsa', 'Bosque', 'Regate', 0),
    ('Bateo Total', 'Fuego', 'Tiro', 0),
    ('Confusión', 'Montaña', 'Bloqueo', 0),
    ('Deslizamiento de Porteria', 'Montaña', 'Atajo', 0),
    ('Remate Glass', 'Montaña', 'Tiro', 0),
    ('Chut Granada', 'Fuego', 'Tiro', 0),
    ('Disparo Rodante', 'Bosque', 'Tiro', 0),
    ('Escudo de Fuerza', 'Fuego', 'Atajo', 0),
    ('Pingüino Emperador Nº2', 'Bosque', 'Tiro', 0),
    ('Remate Combinado', 'Fuego', 'Tiro', 0),
    ('Despeje Explosivo', 'Fuego', 'Atajo', 0),
    ('Entrada Huracán', 'Aire', 'Regate', 0),
    ('Torbellino Dragón', 'Aire', 'Regate', 0),
    ('Escudo de Fuerza Total', 'Fuego', 'Atajo', 0),
    ('Supertrampolín Relámpago', 'Aire', 'Tiro', 0),
    ('Pase Cruzado', 'Aire', 'Tiro', 0),
    ('Pájaro de Fuego', 'Fuego', 'Tiro', 0),
    ('Espejismo', 'Bosque', 'Regate', 0),
    ('Pisotón de Sumo', 'Montaña', 'Bloqueo', 0),
    ('Torbellino', 'Aire', 'Atajo', 0),
    ('Regate Múltiple', 'Bosque', 'Regate', 0),
    ('Telaraña', 'Bosque', 'Bloqueo', 0),
    ('Ataque de las Sombras', 'Bosque', 'Bloqueo', 0),
    ('Bola de Fango', 'Montaña', 'Tiro', 0),
    ('Remate Múltiple', 'Bosque', 'Regate', 0),
    ('El Muro', 'Montaña', 'Bloqueo', 0),
    ('Cabezazo Kung-fu', 'Bosque', 'Tiro', 0),
    ('Regate Topo', 'Montaña', 'Regate', 0),
    ('Superbalón Rodante', 'Bosque', 'Tiro', 0),
    ('Tiro Cegador', 'Fuego', 'Tiro', 0),
    ('Despeje de Leñador', 'Montaña', 'Atajo', 0),
    ('Trama Trama', 'Montaña', 'Bloqueo', 0),
    ('Muralla Infinita', 'Montaña', 'Atajo', 0),
    ('Ruptura Relámpago', 'Aire', 'Tiro', 0),
    ('Tiro Giratorio', 'Aire', 'Tiro', 0),
    ('Tri-Pegaso', 'Aire', 'Tiro', 0),
    ('Tornado Inverso', 'Aire', 'Tiro', 0),
    ('Triángulo Z', 'Fuego', 'Tiro', 0),
    ('Corte Giratorio', 'Aire', 'Bloqueo', 0),
    ('Bloque Dureza', 'Montaña', 'Atajo', 0),
    ('Flecha Huracán', 'Aire', 'Bloqueo', 0),
    ('Fénix', 'Fuego', 'Tiro', 0),
    ('Hora Celestial', 'Aire', 'Regate', 0),
    ('Sabiduría Divina', 'Aire', 'Tiro', 0),
    ('Muralla Tsunami', 'Aire', 'Atajo', 0),
    ('Muralla Gigante', 'Montaña', 'Atajo', 0),
    ('Entrada Tormenta', 'Aire', 'Regate', 0),
    ('Disparo con Rebotes', 'Montaña', 'Tiro', 0),
    ('Flecha Divina', 'Aire', 'Tiro', 0),
    ('Mega Terremoto', 'Montaña', 'Bloqueo', 0),
    ('Giro Bobina', 'Aire', 'Bloqueo', 0),
    ('Mano Mágica', 'Montaña', 'Atajo', 0);

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
('2008-10-12 11:00:00', 7, 'Ribera del río', 'Tiro a puerta');
('2008-10-12 11:00:00', 8, 'Ribera del río', 'Tiro a puerta');
('2008-10-12 11:00:00', 9, 'Instituto Raimon', 'Tiro a puerta');
('2008-10-12 11:00:00', 10, 'Instituto Zeus', 'Tiro a puerta');
('2008-10-12 11:00:00', 11, 'Ribera del río', 'Tiro a puerta');

INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)
VALUES
(1, 2, 3, 1, 20, '2008-10-12 10:00:00'),
(1, 3, 3, 4, 3, '2008-10-19 09:30:00'),
(4, 1, 4, 0, 1, '2008-10-26 09:30:00'),
(5, 1, 5, 1, 2, '2008-11-23 10:00:00'),
(6, 1, 6, 1, 2, '2008-11-30 10:00:00'),
(2, 1, 7, 1, 2, '2008-12-21 10:00:00'),
(1, 11, 2, 3, 3, '2009-01-04 10:00:00'),
(1, 7, 1, 2, 1, '2009-01-18 10:00:00'),
(1, 8, 1, 2, 1, '2009-02-01 10:00:00'),
(1, 9, 1, 3, 2, '2009-02-15 10:00:00'),
(1, 10, 1, 4, 3, '2009-03-08 10:00:00');

