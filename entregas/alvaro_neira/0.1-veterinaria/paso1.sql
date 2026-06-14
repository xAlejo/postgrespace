INSERT INTO tutores (nombre, telefono) VALUES
('juanito', '2334324'),
('tamara', '2237812');
SELECT * FROM tutores;
UPDATE tutores
SET telefono = '444-4444'
WHERE nombre = 'Carlos Mendoza';
SELECT * FROM tutores WHERE nombre = 'Carlos Mendoza';
