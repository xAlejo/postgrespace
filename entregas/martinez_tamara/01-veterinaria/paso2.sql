SELECT * FROM tutores;
UPDATE tutores
SET telefono = '888-1929'
WHERE nombre = 'Carlos Mendoza';
SELECT * FROM tutores;
SELECT * FROM tutores WHERE nombre = 'Carlos Mendoza';
SELECT * FROM tutores;

CREATE TABLE mascotas (
    id_mascota SERIAL PRIMARY KEY,
    nombre     VARCHAR(50) NOT NULL,
    especie    VARCHAR(30),      
    edad_meses INT,
    tutor_id   INT,
CONSTRAINT fk_tutor
        FOREIGN KEY (tutor_id)
        REFERENCES tutores(id_tutor)
        ON DELETE CASCADE
);




INSERT INTO mascotas (nombre, especie, edad_meses, tutor_id) VALUES
('Toby', 'perro', 16, 1),
('Blanca', 'gato', 36, 2);
select * from mascotas;
