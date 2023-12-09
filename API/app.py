import os
import psycopg2
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host='10.6.129.72',
        database="pruebasdb",
		user="postgres",
        password="postgres")
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/players/')
def Players():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT J.*, E.nombre AS nombre_equipo '
                'FROM JUGADOR J JOIN EQUIPO E ON J.id_equipo = E.id_equipo')
    players = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('players.html', players=players)

@app.route('/teams/')
def Teams():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT E.nombre AS equipo,'
                'E.pais AS pais,'
                'E.victorias AS victorias,'
                'E.goles_a_favor AS goles_a_favor,'
                'E.goles_en_contra AS goles_en_contra,'
                'STRING_AGG(CONCAT(J.nombre, \' \', J.apellidos), \', \') AS jugadores '
                'FROM EQUIPO E JOIN JUGADOR J ON E.id_equipo = J.id_equipo '
                'GROUP BY E.nombre, E.pais, E.victorias, E.goles_a_favor, E.goles_en_contra '
                'ORDER BY E.nombre;')
    teams = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('teams.html', teams=teams)

@app.route('/stadiums/')
def Stadiums():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM estadio;')
    stadiums = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('stadium.html', stadiums=stadiums)

@app.route('/Special_Moves/')
def Special_Moves():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM supertecnica;')
    special_moves = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('special_moves.html', special_moves=special_moves)