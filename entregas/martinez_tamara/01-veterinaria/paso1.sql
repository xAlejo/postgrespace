
SELECT * FROM tutores;
INSERT INTO tutores (nombre, telefono) VALUES
('Paula Ramirez', '666-1234'),
('Juanito Perez', '777-1234')



SELECT * FROM tutores;
UPDATE tutores
SET telefono = '888-1929'
WHERE nombre = 'Carlos Mendoza';
