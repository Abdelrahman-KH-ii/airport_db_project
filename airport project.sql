SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS airport_db;
SET FOREIGN_KEY_CHECKS = 1;

CREATE DATABASE airport_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airport_db;

CREATE TABLE airlines(
  airline_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  iata_code CHAR(2) NOT NULL UNIQUE,
  country VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

INSERT INTO airlines(name,iata_code,country) VALUES
('EgyptAir','MS','Egypt'),('Air Cairo','SM','Egypt'),('Nile Air','NP','Egypt'),
('Emirates','EK','United Arab Emirates'),('Qatar Airways','QR','Qatar'),
('Saudia','SV','Saudi Arabia'),('Turkish Airlines','TK','Turkey'),
('Etihad Airways','EY','United Arab Emirates');

CREATE TABLE airports(
  airport_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  iata_code CHAR(3) NOT NULL UNIQUE,
  city VARCHAR(80) NOT NULL,
  country VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

INSERT INTO airports(name,iata_code,city,country) VALUES
('Cairo International','CAI','Cairo','Egypt'),
('Borg El Arab','HBE','Alexandria','Egypt'),
('Hurghada International','HRG','Hurghada','Egypt'),
('Sharm El-Sheikh','SSH','Sharm El-Sheikh','Egypt'),
('Luxor International','LXR','Luxor','Egypt'),
('Aswan International','ASW','Aswan','Egypt'),
('Dubai International','DXB','Dubai','United Arab Emirates'),
('Hamad International','DOH','Doha','Qatar'),
('Istanbul Airport','IST','Istanbul','Turkey'),
('King Abdulaziz','JED','Jeddah','Saudi Arabia'),
('King Khalid','RUH','Riyadh','Saudi Arabia'),
('Abu Dhabi International','AUH','Abu Dhabi','United Arab Emirates');

CREATE TABLE terminals(
  terminal_id INT AUTO_INCREMENT PRIMARY KEY,
  airport_id INT NOT NULL,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100),
  UNIQUE(airport_id,code),
  FOREIGN KEY (airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO terminals(airport_id,code,name) VALUES
((SELECT airport_id FROM airports WHERE iata_code='CAI'),'T1','Terminal 1'),
((SELECT airport_id FROM airports WHERE iata_code='CAI'),'T2','Terminal 2'),
((SELECT airport_id FROM airports WHERE iata_code='CAI'),'T3','Terminal 3'),
((SELECT airport_id FROM airports WHERE iata_code='HRG'),'T1','Main Terminal'),
((SELECT airport_id FROM airports WHERE iata_code='HBE'),'T1','Main Terminal'),
((SELECT airport_id FROM airports WHERE iata_code='LXR'),'T1','Main Terminal'),
((SELECT airport_id FROM airports WHERE iata_code='ASW'),'T1','Main Terminal');

CREATE TABLE gates(
  gate_id INT AUTO_INCREMENT PRIMARY KEY,
  terminal_id INT NOT NULL,
  gate_code VARCHAR(10) NOT NULL,
  UNIQUE(terminal_id,gate_code),
  FOREIGN KEY (terminal_id) REFERENCES terminals(terminal_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO gates(terminal_id,gate_code)
SELECT t.terminal_id, gc.gate_code
FROM terminals t
JOIN (SELECT 'A12' gate_code UNION ALL SELECT 'A14' UNION ALL SELECT 'B07' UNION ALL SELECT 'B09' UNION ALL SELECT 'C03' UNION ALL SELECT 'D05') gc ON 1=1
WHERE t.code IN ('T1','T2','T3');

CREATE TABLE aircraft_types(
  type_id INT AUTO_INCREMENT PRIMARY KEY,
  model VARCHAR(40) NOT NULL UNIQUE,
  total_seats INT NOT NULL CHECK (total_seats>0)
) ENGINE=InnoDB;

INSERT INTO aircraft_types(model,total_seats) VALUES
('A320',180),('B737-800',189),('A321',220);

CREATE TABLE aircraft_seats(
  type_id INT NOT NULL,
  seat_code VARCHAR(5) NOT NULL,
  PRIMARY KEY(type_id,seat_code),
  FOREIGN KEY (type_id) REFERENCES aircraft_types(type_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO aircraft_seats(type_id,seat_code)
SELECT t.type_id, CONCAT(rn, letter)
FROM aircraft_types t
JOIN (
  SELECT 1 rn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
  UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
) r
JOIN (SELECT 'A' letter UNION ALL SELECT 'B' UNION ALL SELECT 'C' UNION ALL SELECT 'D' UNION ALL SELECT 'E' UNION ALL SELECT 'F') s;

CREATE TABLE flights(
  flight_id INT AUTO_INCREMENT PRIMARY KEY,
  airline_id INT NOT NULL,
  flight_no VARCHAR(10) NOT NULL,
  origin_id INT NOT NULL,
  destination_id INT NOT NULL,
  sched_dep DATETIME NOT NULL,
  sched_arr DATETIME NOT NULL,
  status ENUM('ON_TIME','DELAYED','CANCELLED') DEFAULT 'ON_TIME',
  terminal_id INT,
  gate_id INT,
  type_id INT,
  CHECK (sched_arr>sched_dep),
  FOREIGN KEY (airline_id) REFERENCES airlines(airline_id) ON DELETE CASCADE,
  FOREIGN KEY (origin_id) REFERENCES airports(airport_id) ON DELETE RESTRICT,
  FOREIGN KEY (destination_id) REFERENCES airports(airport_id) ON DELETE RESTRICT,
  FOREIGN KEY (terminal_id) REFERENCES terminals(terminal_id) ON DELETE SET NULL,
  FOREIGN KEY (gate_id) REFERENCES gates(gate_id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES aircraft_types(type_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_flights_flightno ON flights(flight_no);

CREATE TABLE passengers(
  passenger_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) UNIQUE,
  phone VARCHAR(30),
  nationality VARCHAR(60),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_passengers_name ON passengers(full_name);

INSERT INTO passengers(full_name,email,phone,nationality) VALUES
('Ahmed Mohamed','ahmed.mohamed@example.com','+201001234567','Egyptian'),
('Omar Abdelrahman','omar.abdelrahman@example.com','+201112223334','Egyptian'),
('Youssef Elsayed','youssef.elsayed@example.com','+201223344556','Egyptian'),
('Mariam Hassan','mariam.hassan@example.com','+201334455667','Egyptian'),
('Salma Khaled','salma.khaled@example.com','+201445566778','Egyptian'),
('Mostafa Ali','mostafa.ali@example.com','+201556677889','Egyptian'),
('Aya Tarek','aya.tarek@example.com','+201667788990','Egyptian'),
('Reem Farid','reem.farid@example.com','+201778899001','Egyptian'),
('Farida Nasser','farida.nasser@example.com','+201889900112','Egyptian'),
('Karim Adel','karim.adel@example.com','+201990011223','Egyptian'),
('Mahmoud Elsayed','mahmoud.elsayed@example.com','+201000111222','Egyptian'),
('Hossam Gamal','hossam.gamal@example.com','+201000333444','Egyptian'),
('Nourhan Fathi','nourhan.fathi@example.com','+201000555666','Egyptian'),
('Tamer Mahmoud','tamer.mahmoud@example.com','+201000777888','Egyptian'),
('Ola Ahmed','ola.ahmed@example.com','+201000999000','Egyptian'),
('Rana Magdy','rana.magdy@example.com','+201001111333','Egyptian'),
('Amina Mostafa','amina.mostafa@example.com','+201001313131','Egyptian'),
('Omar Ashraf','omar.ashraf@example.com','+201001515151','Egyptian'),
('Ahmed Samir','ahmed.samir@example.com','+201001717171','Egyptian'),
('Omar Nabil','omar.nabil@example.com','+201001919191','Egyptian');

CREATE TABLE tickets(
  ticket_id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_no VARCHAR(24) NOT NULL UNIQUE,
  flight_id INT NOT NULL,
  passenger_id INT NOT NULL,
  seat VARCHAR(5) NOT NULL,
  class ENUM('ECONOMY','BUSINESS','FIRST') DEFAULT 'ECONOMY',
  price_usd DECIMAL(10,2) NOT NULL CHECK (price_usd>0),
  booked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
  FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id) ON DELETE CASCADE,
  UNIQUE(flight_id,seat)
) ENGINE=InnoDB;

CREATE INDEX idx_tickets_flight ON tickets(flight_id);

CREATE TABLE baggage(
  bag_id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id INT NOT NULL,
  weight_kg DECIMAL(5,2) CHECK (weight_kg>0),
  status ENUM('CHECKED_IN','SCANNED_GATE','LOADED','DELIVERED','LOST') DEFAULT 'CHECKED_IN',
  tag_code VARCHAR(30) UNIQUE,
  FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE baggage_events(
  event_id INT AUTO_INCREMENT PRIMARY KEY,
  bag_id INT NOT NULL,
  event_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  location VARCHAR(80) NOT NULL,
  event_type ENUM('CHECK_IN','X_RAY','AT_GATE','LOADED','UNLOADED','DELIVERED','LOST') NOT NULL,
  note VARCHAR(255),
  FOREIGN KEY (bag_id) REFERENCES baggage(bag_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE departments(
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE employees(
  emp_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) UNIQUE,
  dept_id INT,
  manager_id INT NULL,
  hire_date DATE NOT NULL DEFAULT (CURRENT_DATE()),
  rating TINYINT CHECK (rating BETWEEN 1 AND 5),
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
  FOREIGN KEY (manager_id) REFERENCES employees(emp_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE shifts(
  shift_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  shift_day DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  CHECK (end_time>start_time),
  FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
  UNIQUE(emp_id,shift_day,start_time)
) ENGINE=InnoDB;

INSERT INTO departments(dept_name) VALUES
('Security'),('Customer Service'),('Operations'),('Baggage Handling'),('Flight Crew');

INSERT INTO employees(full_name,email,dept_id,manager_id,rating) VALUES
('Mona Hassan','mona@airport.com',(SELECT dept_id FROM departments WHERE dept_name='Customer Service'),NULL,5),
('Karim Saad','karim@airport.com',(SELECT dept_id FROM departments WHERE dept_name='Customer Service'),1,4),
('Adel Nabil','adel@airport.com',(SELECT dept_id FROM departments WHERE dept_name='Security'),NULL,4),
('Hadeer Mostafa','hadeer@airport.com',(SELECT dept_id FROM departments WHERE dept_name='Baggage Handling'),3,3);

CREATE TABLE crew_members(
  crew_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  role ENUM('CAPTAIN','FIRST_OFFICER','PURSER','CABIN_CREW') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE flight_crews(
  flight_id INT NOT NULL,
  crew_id INT NOT NULL,
  PRIMARY KEY(flight_id,crew_id),
  FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
  FOREIGN KEY (crew_id) REFERENCES crew_members(crew_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO crew_members(full_name,role) VALUES
('Capt. Ahmed Samir','CAPTAIN'),
('FO Omar Ashraf','FIRST_OFFICER'),
('Purser Salma Fathy','PURSER'),
('Crew Mariam Nabil','CABIN_CREW'),
('Crew Karim Hassan','CABIN_CREW');

CREATE TABLE logs(
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  entity VARCHAR(50) NOT NULL,
  action VARCHAR(255) NOT NULL,
  log_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

SET @CAI_T3 := (SELECT terminal_id FROM terminals WHERE code='T3' AND airport_id=(SELECT airport_id FROM airports WHERE iata_code='CAI') LIMIT 1);
SET @CAI_T2 := (SELECT terminal_id FROM terminals WHERE code='T2' AND airport_id=(SELECT airport_id FROM airports WHERE iata_code='CAI') LIMIT 1);
SET @HRG_T1 := (SELECT terminal_id FROM terminals WHERE code='T1' AND airport_id=(SELECT airport_id FROM airports WHERE iata_code='HRG') LIMIT 1);

SET @A12 := (SELECT gate_id FROM gates WHERE gate_code='A12' LIMIT 1);
SET @B07 := (SELECT gate_id FROM gates WHERE gate_code='B07' LIMIT 1);
SET @C03 := (SELECT gate_id FROM gates WHERE gate_code='C03' LIMIT 1);

INSERT INTO flights(airline_id,flight_no,origin_id,destination_id,sched_dep,sched_arr,status,terminal_id,gate_id,type_id) VALUES
((SELECT airline_id FROM airlines WHERE iata_code='MS'),'MS910',(SELECT airport_id FROM airports WHERE iata_code='CAI'),(SELECT airport_id FROM airports WHERE iata_code='DXB'),'2025-09-08 06:15:00','2025-09-08 10:15:00','ON_TIME',@CAI_T3,@A12,(SELECT type_id FROM aircraft_types WHERE model='A320')),
((SELECT airline_id FROM airlines WHERE iata_code='SM'),'SM402',(SELECT airport_id FROM airports WHERE iata_code='CAI'),(SELECT airport_id FROM airports WHERE iata_code='DOH'),'2025-09-08 09:45:00','2025-09-08 12:15:00','ON_TIME',@CAI_T2,@B07,(SELECT type_id FROM aircraft_types WHERE model='B737-800')),
((SELECT airline_id FROM airlines WHERE iata_code='TK'),'TK691',(SELECT airport_id FROM airports WHERE iata_code='CAI'),(SELECT airport_id FROM airports WHERE iata_code='IST'),'2025-09-08 13:00:00','2025-09-08 16:30:00','ON_TIME',@CAI_T3,@A12,(SELECT type_id FROM aircraft_types WHERE model='A321'));

INSERT INTO flight_crews(flight_id,crew_id)
SELECT (SELECT flight_id FROM flights WHERE flight_no='MS910'), crew_id FROM crew_members ORDER BY crew_id LIMIT 4;

INSERT INTO tickets(ticket_no,flight_id,passenger_id,seat,class,price_usd) VALUES
('MS910-0001',(SELECT flight_id FROM flights WHERE flight_no='MS910'),(SELECT passenger_id FROM passengers WHERE full_name='Ahmed Mohamed'),'12A','ECONOMY',245.00),
('MS910-0002',(SELECT flight_id FROM flights WHERE flight_no='MS910'),(SELECT passenger_id FROM passengers WHERE full_name='Mariam Hassan'),'12B','ECONOMY',245.00),
('SM402-0003',(SELECT flight_id FROM flights WHERE flight_no='SM402'),(SELECT passenger_id FROM passengers WHERE full_name='Omar Abdelrahman'),'3C','BUSINESS',520.00);

INSERT INTO baggage(ticket_id,weight_kg,status,tag_code) VALUES
((SELECT ticket_id FROM tickets WHERE ticket_no='MS910-0001'),18.5,'CHECKED_IN','BG-CAI-10001');

INSERT INTO baggage_events(bag_id,location,event_type,note) VALUES
((SELECT bag_id FROM baggage WHERE tag_code='BG-CAI-10001'),'CAI T3','CHECK_IN','Counter C12');

CREATE OR REPLACE VIEW today_departures_cai AS
SELECT f.flight_no,a.name AS airline,ap_to.iata_code AS destination,f.sched_dep,t.code AS terminal,g.gate_code AS gate,f.status
FROM flights f
JOIN airlines a ON a.airline_id=f.airline_id
JOIN airports ap_from ON ap_from.airport_id=f.origin_id
JOIN airports ap_to ON ap_to.airport_id=f.destination_id
LEFT JOIN terminals t ON t.terminal_id=f.terminal_id
LEFT JOIN gates g ON g.gate_id=f.gate_id
WHERE ap_from.iata_code='CAI' AND DATE(f.sched_dep)=CURRENT_DATE();

CREATE OR REPLACE VIEW sales_per_airline AS
SELECT a.name AS airline, SUM(t.price_usd) AS total_sales
FROM tickets t
JOIN flights f ON f.flight_id=t.flight_id
JOIN airlines a ON a.airline_id=f.airline_id
GROUP BY a.name;

DELIMITER //
CREATE TRIGGER trg_flight_status_update
AFTER UPDATE ON flights
FOR EACH ROW
BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO logs(entity,action)
    VALUES('flight', CONCAT('Status changed for ', NEW.flight_no, ' from ', OLD.status, ' to ', NEW.status));
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE BookTicketReal(
  IN p_flight_no VARCHAR(10),
  IN p_passenger VARCHAR(120),
  IN p_seat VARCHAR(5),
  IN p_class VARCHAR(10),
  IN p_price DECIMAL(10,2)
)
BEGIN
  DECLARE v_flight_id INT;
  DECLARE v_passenger_id INT;
  DECLARE v_type_id INT;
  DECLARE v_taken INT DEFAULT 0;
  DECLARE v_exists INT DEFAULT 0;

  SELECT flight_id,type_id INTO v_flight_id,v_type_id FROM flights WHERE flight_no=p_flight_no LIMIT 1;
  SELECT passenger_id INTO v_passenger_id FROM passengers WHERE full_name=p_passenger LIMIT 1;

  IF v_flight_id IS NULL OR v_passenger_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid flight or passenger';
  END IF;

  IF v_type_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_exists FROM aircraft_seats WHERE type_id=v_type_id AND seat_code=p_seat;
    IF v_exists=0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Seat code not valid for aircraft type';
    END IF;
  END IF;

  START TRANSACTION;
  SELECT COUNT(*) INTO v_taken FROM tickets WHERE flight_id=v_flight_id AND seat=p_seat FOR UPDATE;
  IF v_taken>0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Seat already taken';
  ELSE
    INSERT INTO tickets(ticket_no,flight_id,passenger_id,seat,class,price_usd)
    VALUES (CONCAT(p_flight_no,'-',LPAD(FLOOR(RAND()*9999)+1,4,'0')),v_flight_id,v_passenger_id,p_seat,UPPER(p_class),p_price);
    COMMIT;
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CheckInBag(
  IN p_ticket_no VARCHAR(24),
  IN p_weight DECIMAL(5,2)
)
BEGIN
  DECLARE v_ticket_id INT;
  SELECT ticket_id INTO v_ticket_id FROM tickets WHERE ticket_no=p_ticket_no LIMIT 1;
  IF v_ticket_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid ticket number';
  END IF;
  INSERT INTO baggage(ticket_id,weight_kg,status,tag_code)
  VALUES (v_ticket_id,p_weight,'CHECKED_IN',CONCAT('BG-',REPLACE(p_ticket_no,'-',''),'-',UNIX_TIMESTAMP()));
END //
DELIMITER ;
