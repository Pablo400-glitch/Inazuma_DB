--
-- PostgreSQL database dump
--

-- Dumped from database version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 14.2

-- Started on 2022-12-14 17:34:59

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myhome;
--
-- TOC entry 2943 (class 1262 OID 19359)
-- Name: myhome; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myhome WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE myhome OWNER TO postgres;

\connect myhome

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 2944 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 203 (class 1259 OID 19362)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 19360)
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rooms_id_seq OWNER TO postgres;

--
-- TOC entry 2945 (class 0 OID 0)
-- Dependencies: 202
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- TOC entry 205 (class 1259 OID 19389)
-- Name: temperatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.temperatures (
    id integer NOT NULL,
    room_id integer,
    temperature real,
    date timestamp without time zone
);


ALTER TABLE public.temperatures OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 19387)
-- Name: temperatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.temperatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temperatures_id_seq OWNER TO postgres;

--
-- TOC entry 2946 (class 0 OID 0)
-- Dependencies: 204
-- Name: temperatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.temperatures_id_seq OWNED BY public.temperatures.id;


--
-- TOC entry 2801 (class 2604 OID 19365)
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- TOC entry 2802 (class 2604 OID 19392)
-- Name: temperatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temperatures ALTER COLUMN id SET DEFAULT nextval('public.temperatures_id_seq'::regclass);


--
-- TOC entry 2935 (class 0 OID 19362)
-- Dependencies: 203
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rooms VALUES (1, 'Habitación 1');
INSERT INTO public.rooms VALUES (2, 'Habitación 2');
INSERT INTO public.rooms VALUES (3, 'Habitación 3');
INSERT INTO public.rooms VALUES (4, 'Habitación 4');
INSERT INTO public.rooms VALUES (5, 'Habitación 5');
INSERT INTO public.rooms VALUES (6, 'Habitación 6');
INSERT INTO public.rooms VALUES (7, 'Habitación 7');
INSERT INTO public.rooms VALUES (8, 'Habitación 8');
INSERT INTO public.rooms VALUES (9, 'Habitación 9');
INSERT INTO public.rooms VALUES (10, 'Habitación 100');
INSERT INTO public.rooms VALUES (11, 'Habitación 101');
INSERT INTO public.rooms VALUES (12, 'Habitación 200');


--
-- TOC entry 2937 (class 0 OID 19389)
-- Dependencies: 205
-- Data for Name: temperatures; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.temperatures VALUES (1, 1, 20, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (2, 1, 21, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (3, 1, 18, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (4, 1, 22, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (5, 2, 20, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (6, 2, 21, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (7, 2, 20, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (8, 2, 22, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (9, 3, 18, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (10, 3, 22, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (11, 3, 18, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (12, 3, 22, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (13, 3, 21, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (14, 3, 20, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (15, 4, 23, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (16, 4, 20, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (17, 4, 24, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (18, 4, 26, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (19, 4, 20, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (20, 5, 23, '2022-12-31 00:00:00');
INSERT INTO public.temperatures VALUES (21, 5, 23, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (22, 5, 18, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (23, 6, 23, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (24, 6, 23, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (25, 7, 18, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (26, 7, 26, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (27, 7, 18, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (28, 7, 26, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (29, 8, 18, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (30, 8, 26, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (31, 9, 20, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (32, 9, 26, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (33, 8, 18, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (34, 10, 26, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (35, 10, 20, '2021-05-05 00:00:00');
INSERT INTO public.temperatures VALUES (36, 11, 22, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (37, 11, 26, '2022-12-01 00:00:00');
INSERT INTO public.temperatures VALUES (38, 12, 23, '2022-07-26 00:00:00');
INSERT INTO public.temperatures VALUES (39, 12, 24, '2022-09-13 00:00:00');
INSERT INTO public.temperatures VALUES (40, 12, 22, '2021-05-05 00:00:00');


--
-- TOC entry 2947 (class 0 OID 0)
-- Dependencies: 202
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 12, true);


--
-- TOC entry 2948 (class 0 OID 0)
-- Dependencies: 204
-- Name: temperatures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.temperatures_id_seq', 40, true);


--
-- TOC entry 2804 (class 2606 OID 19370)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 2806 (class 2606 OID 19394)
-- Name: temperatures temperatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temperatures
    ADD CONSTRAINT temperatures_pkey PRIMARY KEY (id);


--
-- TOC entry 2807 (class 2606 OID 19395)
-- Name: temperatures temperatures_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temperatures
    ADD CONSTRAINT temperatures_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


-- Completed on 2022-12-14 17:34:59

--
-- PostgreSQL database dump complete
--

