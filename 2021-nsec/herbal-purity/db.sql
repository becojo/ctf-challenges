DROP TABLE IF EXISTS healers;
CREATE TABLE healers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT,
  updated_at TEXT,
  name TEXT,password_hash TEXT);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT,
  updated_at TEXT,
  name TEXT,gp INTEGER);

DROP TABLE IF EXISTS followers;
CREATE TABLE followers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT,
  updated_at TEXT,
  name TEXT,age INTEGER);

DROP TABLE IF EXISTS appointments;
CREATE TABLE appointments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT,
  updated_at TEXT,
  date TEXT,time TEXT,healer TEXT);

INSERT INTO healers (id, created_at, updated_at, name, password_hash)
VALUES (10001, 0, 0, 'admin', 'FLAG-8b8e9af1ebc8a8f65d5c4f502c29f15a'),
        (13, 0, 0, 'margrave.humfridus', 'f69c1a8c6470dc2e22e1d2f941a4220747968567');

INSERT INTO products (id, created_at, updated_at, name, gp)
VALUES (1, 0, 0, 'Salvia officinalis', 5),
        (2, 0, 0, 'Ruta graveolens', 4),
        (3, 0, 0, 'Chamaemelum nobile', 9),
        (4, 0, 0, 'Anethum graveolens', 10),
        (5, 0, 0, 'Cuminum cyminum', 11);

INSERT INTO followers (id,created_at,updated_at,name,age) values (1,0,0,"Melany Hansen",36),(2,0,0,"Eldridge Mitchell DDS",43),(3,0,0,"Gaynelle Schultz",52),(4,0,0,"Setsuko McDermott",31),(5,0,0,"Theo Lindgren",27),(6,0,0,"Saul Nienow",26),(7,0,0,"Shakia Dooley",38),(8,0,0,"Miles Fritsch",49),(9,0,0,"Emerita Windler",45),(10,0,0,"Perry Hahn",26),(11,0,0,"Duane Marvin",28),(12,0,0," Veola McCullough",44),(13,0,0,"Fernanda Trantow",49),(14,0,0,"Weldon Pollich",47),(15,0,0,"Sana Mertz",39),(16,0,0,"Latrisha Schneider",36),(17,0,0,"Ian Weissnat",39),(18,0,0,"Laurel Becker",50),(19,0,0,"Malcom Schroeder",28),(20,0,0,"Parthenia Goyette",45),(21,0,0,"Will Hansen",35),(22,0,0,"China Runolfsdottir LLD",39),(23,0,0,"Latoyia Smith",46),(24,0,0,"Danyel Schamberger DDS",41),(25,0,0,"Renate Schumm",44),(26,0,0,"Stanley Herman",37),(27,0,0,"Laurinda Conn I",33),(28,0,0,"Buster Conn PhD",42),(29,0,0,"Christi Quigley",52),(30,0,0,"Annalee Jacobs",20),(31,0,0,"Rowena Conroy",27),(32,0,0," Hong Grant",24);
