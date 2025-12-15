CREATE TABLE IF NOT EXISTS medidor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cuenta TEXT UNIQUE CHECK(LENGTH(TRIM(cuenta)) > 0),
    serie TEXT NOT NULL UNIQUE CHECK(LENGTH(TRIM(serie)) > 0),
    ubicacion TEXT, 
    estado TEXT, 
    comentario TEXT,
    posicion INTEGER CHECK(posicion IN (0, 1)), 
    porcion INTEGER CHECK(porcion BETWEEN 1 AND 18), 
    foto TEXT,
    cliente TEXT,
    telefono TEXT,
    direccion TEXT,
    latitud REAL CHECK(latitud BETWEEN -90 AND 90),
    longitud REAL CHECK(longitud BETWEEN -180 AND 180),
    mapa TEXT GENERATED ALWAYS AS ('https://maps.google.com/?q=' || latitud || ',' || longitud) STORED, 
    lectura_anterior REAL,
    lectura_actual REAL,
    lectura_minima REAL,
    lectura_maxima REAL,
    consumo_promedio REAL,
    consumo_anterior REAL,
    consumo_actual REAL GENERATED ALWAYS AS (lectura_actual - lectura_anterior) STORED,
    fecha_creacion TEXT DEFAULT (datetime('now', 'localtime')),
    fecha_actualizacion TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_cuenta ON medidor(cuenta);
CREATE INDEX IF NOT EXISTS idx_serie ON medidor(serie);
CREATE INDEX IF NOT EXISTS idx_estado ON medidor(estado);
CREATE INDEX IF NOT EXISTS idx_porcion ON medidor(porcion);

CREATE TRIGGER IF NOT EXISTS proteger_fecha_creacion
BEFORE UPDATE ON medidor
FOR EACH ROW
WHEN NEW.fecha_creacion IS NOT OLD.fecha_creacion
BEGIN
    SELECT RAISE(ROLLBACK, 'No se puede modificar fecha_creacion');
END;

CREATE TRIGGER IF NOT EXISTS actualizar_fecha_actualizacion
BEFORE UPDATE ON medidor
FOR EACH ROW
WHEN (
    NEW.cuenta IS NOT OLD.cuenta OR
    NEW.serie IS NOT OLD.serie OR
    NEW.ubicacion IS NOT OLD.ubicacion OR
    NEW.estado IS NOT OLD.estado OR
    NEW.comentario IS NOT OLD.comentario OR
    NEW.posicion IS NOT OLD.posicion OR
    NEW.porcion IS NOT OLD.porcion OR
    NEW.foto IS NOT OLD.foto OR
    NEW.cliente IS NOT OLD.cliente OR
    NEW.telefono IS NOT OLD.telefono OR
    NEW.direccion IS NOT OLD.direccion OR
    NEW.latitud IS NOT OLD.latitud OR
    NEW.longitud IS NOT OLD.longitud OR
    NEW.lectura_anterior IS NOT OLD.lectura_anterior OR
    NEW.lectura_actual IS NOT OLD.lectura_actual OR
    NEW.lectura_minima IS NOT OLD.lectura_minima OR
    NEW.lectura_maxima IS NOT OLD.lectura_maxima OR
    NEW.consumo_promedio IS NOT OLD.consumo_promedio OR
    NEW.consumo_anterior IS NOT OLD.consumo_anterior
)
BEGIN
    UPDATE medidor
    SET fecha_actualizacion = datetime('now','localtime')
    WHERE id = NEW.id;
END;
