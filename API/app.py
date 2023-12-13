import os
import psycopg2
from flask import Flask, render_template, jsonify

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

    players_json = []
    for player in players:
        player_dict = {
            'Nombre': player[1],
            'Apellidos': player[2],
            'Edad': player[3],
            'Posicion': player[4],
            'Nacionalidad': player[5],
            'Nombre_equipo': player[14],
            'Atributos': {
                'Fuerza': player[6],
                'Velocidad': player[7],
                'Resistencia': player[8],
                'Tecnica': player[9],
                'Porteria': player[10],
                'Regate': player[11],
                'Tiro': player[12],
                'Aguante': player[13]
            }
        }
        players_json.append(player_dict)

    return jsonify(players_json)

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
    
    teams_json = []
    for team in teams:
        team_dict = {
            'Nombre': team[0],
            'Pais': team[1],
            'Victorias': team[2],
            'Goles a favor': team[3],
            'Goles en contra': team[4],
            'Jugadores': team[5]
        }
        teams_json.append(team_dict)

    return jsonify(teams_json)

@app.route('/stadiums/')
def Stadiums():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM estadio;')
    stadiums = cur.fetchall()
    cur.close()
    conn.close()
    
    stadiums_json = []
    for stadium in stadiums:
        stadium_dict = {
            'Nombre': stadium[1],
            'Tipo de Cesped': stadium[2],
            'Tipo de Estadio': stadium[3]
        }
        stadiums_json.append(stadium_dict)

    return jsonify(stadiums_json)

@app.route('/Special_Moves/')
def Special_Moves():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM supertecnica;')
    special_moves = cur.fetchall()
    cur.close()
    conn.close()
    
    special_moves_json = []
    for special_move in special_moves:
        special_move_dict = {
            'Nombre': special_move[1],
            'Elemento': special_move[2],
            'Tipo': special_move[3],
            'Numero de Jugadores con supertecnica': special_move[4]
        }
        special_moves_json.append(special_move_dict)
    
    return jsonify(special_moves_json)

@app.route('/Matches/')
def Matches():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT P.id_partido, E1.nombre AS equipo_local, '
                'E2.nombre AS equipo_visitante, '
                'ES.nombre AS nombre_estadio, '
                'P.goles_local, P.goles_visitante, P.fecha '
                'FROM PARTIDO P '
                'JOIN EQUIPO E1 ON P.id_equipo_local = E1.id_equipo '
                'JOIN EQUIPO E2 ON P.id_equipo_visitante = E2.id_equipo '
                'JOIN ESTADIO ES ON P.id_estadio = ES.id_estadio;')
    matches = cur.fetchall()
    cur.close()
    conn.close()
    
    matches_json = []
    for match in matches:
        match_dict = {
            'Equipo Local': match[1],
            'Equipo Visitante': match[2],
            'Nombre Estadio': match[3],
            'Goles Equipo Local': match[4],
            'Goles Equipo Visitante': match[5]
        }
        matches_json.append(match_dict)
    
    return jsonify(matches_json)
    
@app.route('/Trainings/')
def Trainings():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT EN.fecha,'
                'E.nombre AS nombre_equipo, '
                'EN.lugar,EN.tipo '
                'FROM ENTRENAMIENTO EN '
                'JOIN EQUIPO E ON EN.id_equipo = E.id_equipo;')
    trainings = cur.fetchall()
    cur.close()
    conn.close()
    
    trainings_json = []
    for training in trainings:
        training_dict = {
            'Fecha': training[0],
            'Nombre Equipo': training[1],
            'Lugar': training[2],
            'Tipo': training[3]
        }
        trainings_json.append(training_dict)
    
    return jsonify(trainings_json)