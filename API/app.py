import os
import psycopg2
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host='10.6.129.72',
        database="inazumadb",
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
            'ID': player[0],
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

@app.route('/players/<int:id_player>', methods=['DELETE'])
def delete_player(id_player):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar el jugador con el ID proporcionado
        cur.execute('DELETE FROM jugador WHERE id_jugador = %s;', (id_player,))
        conn.commit()

        # Verifica si se eliminó algún jugador
        if cur.rowcount == 0:
            # No se encontró ningún jugador con el ID proporcionado
            raise Exception(f'No se encontro un jugador con el ID {id_player}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Player deleted successfully'})
    
    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404

@app.route('/players/', methods=['POST'])
def add_player():
    try:
        # Obtiene los datos del jugador del cuerpo de la petición
        player_data = request.get_json()

        # Valida que los datos del jugador no estén vacíos
        if not player_data:
            raise Exception('No se proporcionaron datos para el jugador')
        
        for field in player_data:
            if not player_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el jugador en la base de
        cur.execute('INSERT INTO jugador (nombre, apellidos, genero, nacionalidad, elemento, posicion, id_equipo, tiro, regate, defensa, control, rapidez, aguante) '
                    'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s ,%s, %s, %s, %s);', 
                    (player_data.get('nombre'), 
                     player_data.get('apellidos'), 
                     player_data.get('genero'), 
                     player_data.get('nacionalidad'), 
                     player_data.get('elemento'), 
                     player_data.get('posicion'), 
                     player_data.get('id_equipo'), 
                     player_data.get('tiro'), 
                     player_data.get('regate'), 
                     player_data.get('defensa'), 
                     player_data.get('control'), 
                     player_data.get('rapidez'), 
                     player_data.get('aguante')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Player added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400
    
@app.route('/players/<int:id_player>', methods=['PUT'])
def update_player(id_player):
    try:
        # Obtiene los datos del jugador del cuerpo de la petición
        player_data = request.get_json()

        # Valida que los datos del jugador no estén vacíos
        if not player_data:
            raise Exception('No se proporcionaron datos para el jugador')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ['nombre', 'apellidos', 'genero', 'nacionalidad', 'elemento', 'posicion', 'id_equipo', 'tiro', 'regate', 'defensa', 'control', 'rapidez', 'aguante']:
            if field in player_data and player_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(player_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del jugador al final de los valores a actualizar
        values_to_update.append(id_player)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE jugador SET {", ".join(fields_to_update)} WHERE id_jugador = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Player updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400       

@app.route('/teams/')
def Teams():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM EQUIPO')
    teams = cur.fetchall()
    cur.close()
    conn.close()
    
    teams_json = []
    for team in teams:
        team_dict = {
            'ID': team[0],
            'Nombre': team[1],
            'Pais': team[2],
            'Victorias': team[3],
            'Goles a favor': team[4],
            'Goles en contra': team[5]
        }
        teams_json.append(team_dict)

    return jsonify(teams_json)

@app.route('/teams/<int:id_team>', methods=['DELETE'])
def delete_team(id_team):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar el equipo con el ID proporcionado
        cur.execute('DELETE FROM equipo WHERE id_equipo = %s;', (id_team,))
        conn.commit()

        # Verifica si se eliminó algún equipo
        if cur.rowcount == 0:
            # No se encontró ningún equipo con el ID proporcionado
            raise Exception(f'No se encontro un equipo con el ID {id_team}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Team deleted successfully'})
    
    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404
    
@app.route('/teams/', methods=['POST'])
def add_team():
    try:
        # Obtiene los datos del equipo del cuerpo de la petición
        team_data = request.get_json()

        # Valida que los datos del equipo no estén vacíos
        if not team_data:
            raise Exception('No se proporcionaron datos para el equipo')
        
        for field in team_data:
            if not team_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO equipo (nombre, pais) '
                    'VALUES (%s, %s);', 
                    (team_data.get('nombre'), 
                     team_data.get('pais')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Team added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400
    
@app.route('/teams/<int:id_team>', methods=['PUT'])
def update_team(id_team):
    try:
        # Obtiene los datos del equipo del cuerpo de la petición
        team_data = request.get_json()

        # Valida que los datos del equipo no estén vacíos
        if not team_data:
            raise Exception('No se proporcionaron datos para el equipo')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ['nombre', 'pais']:
            if field in team_data and team_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(team_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del equipo al final de los valores a actualizar
        values_to_update.append(id_team)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE equipo SET {", ".join(fields_to_update)} WHERE id_equipo = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Team updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400

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
            'ID': stadium[0],
            'Nombre': stadium[1],
            'Tipo de Cesped': stadium[2],
            'Tipo de Estadio': stadium[3]
        }
        stadiums_json.append(stadium_dict)

    return jsonify(stadiums_json)

@app.route('/stadiums/<int:id_stadium>', methods=['DELETE'])
def delete_stadium(id_stadium):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar el estadio con el ID proporcionado
        cur.execute('DELETE FROM estadio WHERE id_estadio = %s;', (id_stadium,))
        conn.commit()

        # Verifica si se eliminó algún estadio
        if cur.rowcount == 0:
            # No se encontró ningún estadio con el ID proporcionado
            raise Exception(f'No se encontro un estadio con el ID {id_stadium}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Stadium deleted successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404  # Puedes cambiar el código de estado según sea necesario

@app.route('/stadiums/', methods=['POST'])
def add_stadium():
    try:
        # Obtiene los datos del estadio del cuerpo de la petición
        stadium_data = request.get_json()

        # Valida que los datos del estadio no estén vacíos
        if not stadium_data:
            raise Exception('No se proporcionaron datos para el estadio')
        
        for field in stadium_data:
            if not stadium_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO ESTADIO (nombre, cesped, tipo)'
                    'VALUES (%s, %s, %s);', 
                    (stadium_data.get('nombre'), 
                     stadium_data.get('cesped'),
                     stadium_data.get('tipo')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Stadium added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400

@app.route('/stadiums/<int:id_stadium>', methods=['PUT'])
def update_stadium(id_stadium):
    try:
        # Obtiene los datos del estadio del cuerpo de la petición
        stadium_data = request.get_json()

        # Valida que los datos del estadio no estén vacíos
        if not stadium_data:
            raise Exception('No se proporcionaron datos para el estadio')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ["nombre", "cesped", "tipo"]:
            if field in stadium_data and stadium_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(stadium_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del estadio al final de los valores a actualizar
        values_to_update.append(id_stadium)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE ESTADIO SET {", ".join(fields_to_update)} WHERE id_estadio = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Stadium updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400 

@app.route('/special_moves/')
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
            "ID": special_move[0],
            'Nombre': special_move[1],
            'Elemento': special_move[2],
            'Tipo': special_move[3],
            'Numero de Jugadores con supertecnica': special_move[4]
        }
        special_moves_json.append(special_move_dict)
    
    return jsonify(special_moves_json)

@app.route('/special_moves/<int:id_special_move>', methods=['DELETE'])
def delete_special_move(id_special_move):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar la supertecnica con el ID proporcionado
        cur.execute('DELETE FROM supertecnica WHERE id_supertecnica = %s;', (id_special_move,))
        conn.commit()

        # Verifica si se eliminó alguna supertecnica
        if cur.rowcount == 0:
            # No se encontró ninguna supertecnica con el ID proporcionado
            raise Exception(f'No se encontro una supertecnica con el ID {id_special_move}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move deleted successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404

@app.route('/special_moves/', methods=['POST'])
def add_special_move():
    try:
        # Obtiene los datos de la supertécnica del cuerpo de la petición
        special_move_data = request.get_json()

        # Valida que los datos de la supertécnica no estén vacíos
        if not special_move_data:
            raise Exception('No se proporcionaron datos para la supertécnica')
        
        for field in special_move_data:
            if not special_move_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO SUPERTECNICA (nombre, elemento, tipo)'
                    'VALUES (%s, %s, %s);', 
                    (special_move_data.get('nombre'), 
                     special_move_data.get('elemento'),
                     special_move_data.get('tipo')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400

@app.route('/special_moves/<int:id_special_move>', methods=['PUT'])
def update_special_move(id_special_move):
    try:
        # Obtiene los datos de la supertécnica del cuerpo de la petición
        special_move_data = request.get_json()

        # Valida que los datos de la supertécnica no estén vacíos
        if not special_move_data:
            raise Exception('No se proporcionaron datos para la supertécnica')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ["nombre", "elemento", "tipo"]:
            if field in special_move_data and special_move_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(special_move_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del supertecnica al final de los valores a actualizar
        values_to_update.append(id_special_move)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE SUPERTECNICA SET {", ".join(fields_to_update)} WHERE id_supertecnica = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400 

@app.route('/matches/')
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
            'ID': match[0],
            'Equipo Local': match[1],
            'Equipo Visitante': match[2],
            'Nombre Estadio': match[3],
            'Goles Equipo Local': match[4],
            'Goles Equipo Visitante': match[5],
            'Fecha': match[6]
        }
        matches_json.append(match_dict)
    
    return jsonify(matches_json)

@app.route('/matches/<int:id_match>', methods=['DELETE'])
def delete_match(id_match):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar el partido con el ID proporcionado
        cur.execute('DELETE FROM partido WHERE id_partido = %s;', (id_match,))
        conn.commit()

        # Verifica si se eliminó algún partido
        if cur.rowcount == 0:
            # No se encontró ningún partido con el ID proporcionado
            raise Exception(f'No se encontro un partido con el ID {id_match}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Match deleted successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404

@app.route('/matches/', methods=['POST'])
def add_match():
    try:
        # Obtiene los datos del partido del cuerpo de la petición
        match_data = request.get_json()

        # Valida que los datos del partido no estén vacíos
        if not match_data:
            raise Exception('No se proporcionaron datos para el partido')
        
        for field in match_data:
            if not match_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO PARTIDO(id_equipo_local, id_equipo_visitante, id_estadio, goles_local, goles_visitante, fecha)'
                    'VALUES (%s, %s, %s, %s, %s, %s);', 
                    (match_data.get('id_equipo_local'), 
                     match_data.get('id_equipo_visitante'), 
                     match_data.get('id_estadio'), 
                     match_data.get('goles_local'), 
                     match_data.get('goles_visitante'), 
                     match_data.get('fecha')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Match added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400

@app.route('/matches/<int:id_match>', methods=['PUT'])
def update_match(id_match):
    try:
        # Obtiene los datos del partido del cuerpo de la petición
        match_data = request.get_json()

        # Valida que los datos del partido no estén vacíos
        if not match_data:
            raise Exception('No se proporcionaron datos para el partido')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ["id_equipo_local", "id_equipo_visitante", "id_estadio", "goles_local", "goles_visitante", "fecha"]:
            if field in match_data and match_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(match_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del partido al final de los valores a actualizar
        values_to_update.append(id_match)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE PARTIDO SET {", ".join(fields_to_update)} WHERE id_partido = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Match updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400   

@app.route('/trainings/')
def Trainings():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT EN.id_training, EN.fecha,'
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
            'ID': training[0],
            'Fecha': training[1],
            'Nombre Equipo': training[2],
            'Lugar': training[3],
            'Tipo': training[4]
        }
        trainings_json.append(training_dict)
    
    return jsonify(trainings_json)

@app.route('/trainings/<int:id_training>', methods=['DELETE'])
def delete_training(id_training):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar el entrenamiento con el ID proporcionado
        cur.execute('DELETE FROM entrenamiento WHERE id_training = %s;', (id_training,))
        conn.commit()

        # Verifica si se eliminó algún entrenamiento
        if cur.rowcount == 0:
            # No se encontró ningún entrenamiento con el ID proporcionado
            raise Exception(f'No se encontro un entrenamiento con el ID {id_training}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Training deleted successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404

@app.route('/trainings/', methods=['POST'])
def add_training():
    try:
        # Obtiene los datos del entrenamiento del cuerpo de la petición
        training_data = request.get_json()

        # Valida que los datos del entrenamiento no estén vacíos
        if not training_data:
            raise Exception('No se proporcionaron datos para el entrenamiento')
        
        for field in training_data:
            if not training_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO ENTRENAMIENTO(fecha, id_equipo, lugar, tipo)'
                    'VALUES (%s, %s, %s, %s);', 
                    (training_data.get('fecha'), 
                     training_data.get('id_equipo'), 
                     training_data.get('lugar'), 
                     training_data.get('tipo')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Training added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400

@app.route('/trainings/<int:id_training>', methods=['PUT'])
def update_training(id_training):
    try:
        # Obtiene los datos del entrenamiento del cuerpo de la petición
        training_data = request.get_json()

        # Valida que los datos del entrenamiento no estén vacíos
        if not training_data:
            raise Exception('No se proporcionaron datos para el entrenamiento')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ["fecha", "id_equipo", "lugar", "tipo"]:
            if field in training_data and training_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(training_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del entrenamiento al final de los valores a actualizar
        values_to_update.append(id_training)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE ENTRENAMIENTO SET {", ".join(fields_to_update)} WHERE id_training = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Training updated successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400       

@app.route('/special_move_for_player/')
def Special_Move_For_Player():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT J.id_jugador, J.nombre, J.apellidos, ST.id_supertecnica, ST.nombre, ST.elemento, ST.tipo '
                'FROM JUGADOR J '
                'JOIN SUPERTECNICA_JUGADOR STJ ON J.id_jugador = STJ.id_jugador '
                'JOIN SUPERTECNICA ST ON STJ.id_supertecnica = ST.id_supertecnica ')
    special_move_for_player = cur.fetchall()
    cur.close()
    conn.close()
    
    special_move_for_player_json = []
    for special_move in special_move_for_player:
        special_move_dict = {
            'ID Jugador': special_move[0],
            'Nombre': special_move[1],
            'Apellidos': special_move[2],
            'ID Supertecnica': special_move[3],
            'Nombre de Supertecnica': special_move[4],
            'Elemento de Supertecnica': special_move[5],
            'Tipo de Supertecnica': special_move[6]
        }
        special_move_for_player_json.append(special_move_dict)
    
    return jsonify(special_move_for_player_json)

@app.route('/special_move_for_player/<int:id_jugador>/<int:id_supertecnica>', methods=['DELETE'])
def delete_special_move_for_player(id_jugador, id_supertecnica):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Intenta eliminar la supertecnica con el ID proporcionado
        cur.execute('DELETE FROM supertecnica_jugador WHERE id_jugador = %s AND id_supertecnica = %s;', (id_jugador, id_supertecnica))
        conn.commit()

        # Verifica si se eliminó alguna supertecnica
        if cur.rowcount == 0:
            # No se encontró ninguna supertecnica con el ID proporcionado
            raise Exception(f'No se encontro una supertecnica con el ID {id_supertecnica} para el jugador con el ID {id_jugador}')

        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move for Player deleted successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 404

    
@app.route('/special_move_for_player/', methods=['POST'])
def add_special_move_for_player():
    try:
        # Obtiene los datos de la supertécnica del cuerpo de la petición
        special_move_for_player_data = request.get_json()

        # Valida que los datos de la supertécnica no estén vacíos
        if not special_move_for_player_data:
            raise Exception('No se proporcionaron datos para la supertécnica del jugador')
        
        for field in special_move_for_player_data:
            if not special_move_for_player_data.get(field):
                raise Exception(f'El campo {field} no puede estar vacío')

        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Inserta el equipo en la base de datos
        cur.execute('INSERT INTO SUPERTECNICA_JUGADOR(id_jugador, id_supertecnica)'
                    'VALUES (%s, %s);', 
                    (special_move_for_player_data.get('id_jugador'), 
                     special_move_for_player_data.get('id_supertecnica')))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move for Player added successfully'})

    except Exception as e:
        # Captura cualquier excepción y devuelve un objeto JSON con el mensaje de error
        return jsonify({'error': str(e)}), 400
    
@app.route('/special_move_for_player/<int:id_jugador>/<int:id_supertecnica>', methods=['PUT'])
def update_special_move_for_player(id_jugador, id_supertecnica):
    try:
        # Obtiene los datos de la supertécnica del cuerpo de la petición
        special_move_for_player_data = request.get_json()

        # Valida que los datos de la supertécnica no estén vacíos
        if not special_move_for_player_data:
            raise Exception('No se proporcionaron datos para la supertécnica del jugador')
        
        # Obtiene una conexión a la base de datos
        conn = get_db_connection()
        cur = conn.cursor()

        # Construye dinámicamente la consulta SQL
        fields_to_update = []
        values_to_update = []

        for field in ["id_jugador", "id_supertecnica"]:
            if field in special_move_for_player_data and special_move_for_player_data[field] is not None:
                fields_to_update.append(f'{field} = %s')
                values_to_update.append(special_move_for_player_data[field])

        # Valida que al menos un campo se vaya a actualizar
        if not fields_to_update:
            raise Exception('Ningún campo proporcionado para actualizar')

        # Agrega el ID del supertecnica al final de los valores a actualizar
        values_to_update.append(id_jugador)
        values_to_update.append(id_supertecnica)

        # Construye y ejecuta la consulta SQL
        query = f'UPDATE SUPERTECNICA_JUGADOR SET {", ".join(fields_to_update)} WHERE id_jugador = %s AND id_supertecnica = %s;'
        cur.execute(query, tuple(values_to_update))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Special Move for Player updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 400
    
@app.route('/goalkeeper/<int:id_goalkeeper>', methods=['PUT'])
def update_goalkeeper(id_goalkeeper):
    try:
        goalkeeper_data = request.get_json()

        if not goalkeeper_data:
            raise Exception('No se proporcionaron datos para el portero')
        
        conn = get_db_connection()
        cur = conn.cursor()

        check_query = 'SELECT COUNT(*) FROM PORTERO WHERE id_jugador = %s;'
        cur.execute(check_query, (id_goalkeeper,))
        result = cur.fetchone()

        if result[0] == 0:
            raise Exception(f'No se encontró el portero con ID {id_goalkeeper}')


        query = 'UPDATE PORTERO SET paradas = %s WHERE id_jugador = %s;'
        cur.execute(query, (goalkeeper_data.get('paradas'), id_goalkeeper))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'goalKeeper updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/goalkeeper/', methods=['GET'])
def get_goalkeeper():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT J.*, E.nombre, p.paradas AS nombre_equipo '
                    'FROM (JUGADOR J JOIN EQUIPO E ON J.id_equipo = E.id_equipo) INNER JOIN portero P ON J.id_jugador = P.id_jugador')
        players = cur.fetchall()
        cur.close()
        conn.close()

        players_json = []
        for player in players:
            player_dict = {
                'ID': player[0],
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
                },
                'Paradas': player[15]
            }
            players_json.append(player_dict)

        return jsonify(players_json)

    except Exception as e:
        return jsonify({'error': str(e)}), 400
        
@app.route('/defense/<int:id_defense>', methods=['PUT'])
def update_defense(id_defense):
    try:
        defense_data = request.get_json()

        if not defense_data:
            raise Exception('No se proporcionaron datos para el defensa')
        
        conn = get_db_connection()
        cur = conn.cursor()

        check_query = 'SELECT COUNT(*) FROM DEFENSA WHERE id_jugador = %s;'
        cur.execute(check_query, (id_defense,))

        result = cur.fetchone()

        if result[0] == 0:
            raise Exception(f'No se encontró el defensa con ID {id_defense}')

        query = 'UPDATE DEFENSA SET balones_robados = %s WHERE id_jugador = %s;'
        cur.execute(query, (defense_data.get('balones_robados'), id_defense))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Defense updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 400
    
@app.route('/defense/', methods=['GET'])
def get_defense():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT J.*, E.nombre, D.balones_robados AS nombre_equipo '
                    'FROM (JUGADOR J JOIN EQUIPO E ON J.id_equipo = E.id_equipo) INNER JOIN defensa D ON J.id_jugador = D.id_jugador')
        players = cur.fetchall()
        cur.close()
        conn.close()

        players_json = []
        for player in players:
            player_dict = {
                'ID': player[0],
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
                },
                'Balones Robados': player[15]
            }
            players_json.append(player_dict)

        return jsonify(players_json)

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/midfielder/<int:id_midfielder>', methods=['PUT'])
def update_midfielder(id_midfielder):
    try:
        midfielder_data = request.get_json()

        if not midfielder_data:
            raise Exception('No se proporcionaron datos para el mediocampista')
        
        conn = get_db_connection()
        cur = conn.cursor()

        check_query = 'SELECT COUNT(*) FROM centrocampista WHERE id_jugador = %s;'
        cur.execute(check_query, (id_midfielder,))
        result = cur.fetchone()

        if result[0] == 0:
            raise Exception(f'No se encontró el centrocampista con ID {id_midfielder}')

        query = 'UPDATE centrocampista SET regates_realizados = %s WHERE id_jugador = %s;'
        cur.execute(query, (midfielder_data.get('regates_realizados'), id_midfielder))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Midfielder updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 400
  
@app.route('/midfielder/', methods=['GET'])
def get_midfielder():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT J.*, E.nombre, M.regates_realizados AS nombre_equipo '
                    'FROM (JUGADOR J JOIN EQUIPO E ON J.id_equipo = E.id_equipo) INNER JOIN centrocampista M ON J.id_jugador = M.id_jugador')
        players = cur.fetchall()
        cur.close()
        conn.close()

        players_json = []
        for player in players:
            player_dict = {
                'ID': player[0],
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
                },
                'Regates Realizados': player[15]
            }
            players_json.append(player_dict)

        return jsonify(players_json)

    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/forward:id_forward>', methods=['PUT'])
def update_forward(id_forward):
    try:
        forward_data = request.get_json()

        if not forward_data:
            raise Exception('No se proporcionaron datos para el delantero')
        
        conn = get_db_connection()
        cur = conn.cursor()

        check_query = 'SELECT COUNT(*) FROM DELANTERO WHERE id_jugador = %s;'
        cur.execute(check_query, (id_forward,))
        result = cur.fetchone()

        if result[0] == 0:
            raise Exception(f'No se encontró el delantero con ID {id_forward}')

        query = 'UPDATE DELANTERO SET disparos_a_puerta = %s WHERE id_jugador = %s;'
        cur.execute(query, (forward_data.get('disparos_a_puerta'), id_forward))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Forward updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/forward/', methods=['GET'])
def get_forward():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT J.*, E.nombre, F.disparos_a_puerta AS nombre_equipo '
                    'FROM (JUGADOR J JOIN EQUIPO E ON J.id_equipo = E.id_equipo) INNER JOIN delantero F ON J.id_jugador = F.id_jugador')
        players = cur.fetchall()
        cur.close()
        conn.close()

        players_json = []
        for player in players:
            player_dict = {
                'ID': player[0],
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
                },
                'Disparos a Puerta': player[15]
            }
            players_json.append(player_dict)

        return jsonify(players_json)

    except Exception as e:
        return jsonify({'error': str(e)}), 400

