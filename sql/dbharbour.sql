-- phpMyAdmin SQL Dump
-- version 4.7.9
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 01-08-2019 a las 11:09:22
-- Versión del servidor: 10.1.31-MariaDB
-- Versión de PHP: 7.2.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dbharbour`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menus`
--

CREATE TABLE `menus` (
  `GLYPH` varchar(20) DEFAULT NULL,
  `PROMPT` varchar(30) DEFAULT NULL,
  `ACTION` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sellers`
--

CREATE TABLE `sellers` (
  `code` varchar(9) NOT NULL DEFAULT '',
  `first` varchar(20) DEFAULT NULL,
  `last` varchar(20) DEFAULT NULL,
  `address1` varchar(30) DEFAULT NULL,
  `address2` varchar(30) DEFAULT NULL,
  `city` varchar(20) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `phone` int(10) DEFAULT NULL,
  `email` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `sellers`
--

INSERT INTO `sellers` (`code`, `first`, `last`, `address1`, `address2`, `city`, `zipcode`, `phone`, `email`) VALUES
('200', 'Cristina', 'Mar de Sal', 'Rambla Nova, 1', '(Balcon del Mediterràneo)', 'Tarragona', '43003', 696857412, 'cris@gmail.com'),
('ALI', 'Ali', 'Halverson', '10614 No. Sheridan Way', 'No. Sheridan Way', 'Fort Collins', '99748-6645', 546684799, 'ali@gmail.com'),
('ARNALDO', 'Arnaldo', 'Waldrop', '27185 Terri-Lyn', 'Terri-Lyn', 'Devon Park', '32428-6555', 555682423, 'arnaldo@hotmail.com'),
('CECI', 'Ceci', 'Gibbard', '9540 Raynes Park Road', 'Raynes Park Road', 'Miami', '55774-2304', 403247755, 'ceci@hotmail.com'),
('CHESTER', 'Chester....', 'Padilla', '32385 Federal Street', 'Federal Street', 'Ashby', '82882-2447', 744228828, 'chester@hotmail.com'),
('CORKEY', 'Corkey', 'Young', '9069 Avon Place', 'Avon Place', 'Lund', '36199-1793', 397199163, 'corkey@gmail.com'),
('DAVID', 'David', 'Jochum', '8211 Carnegie Center', 'Carnegie Center', 'Hingham', '71947-5114', 411574917, 'david@yahoo.com'),
('FRANK', 'Frank', 'Fonseca', '18712 Sherman Way', 'Sherman Way', 'Ashby', '08218-8409', 904881280, 'frank@gmail.com'),
('GARY', 'Gary', 'Brock', '3893 Canandaigua Road', 'Canandaigua Road', 'Senford', '94177-5329', 923577149, 'gary@gmail.com'),
('HERBERT', 'Herbert', 'Fuller', '4057 Parkside Avenue', 'Parkside Avenue', 'Canning Vale', '03556-9645', 546965530, 'herbert@yahoo.com'),
('HOMER', 'Homer', 'Simpson', '32179 Maiden Lane', 'Maiden Lane', 'Springfield', '20503-8202', 202830502, 'homer@gmail.com'),
('HUGH', 'Hugh', 'Lupton', '16472 S. LaSalle Street', 'S. LaSalle Street', 'Tarzana', '79021-0643', 346012097, 'hugh@yahoo.com'),
('JOHNNY', 'Johnny', 'Fischer', '30621 Inridge Drive', 'Inridge Drive', 'McLean', '86275-8035', 530857268, 'johnny@yahoo.com'),
('OSKAR', 'Oskar', 'Farley', '19123 Washington Street', 'Washington Street', 'Boston', '25885-0851', 158058852, 'oskar@gmail.com'),
('PHYLLIS', 'Phyllis', 'Lechuga', '1457 Indianapolis Ave', 'Indianapolis Ave', 'Council Bluffs', '73036-5749', 947563037, 'phyllis@gmail.com'),
('REG', 'Reg', 'Kaczocha', '30522 Park Ten Place', 'Park Ten Place', 'Scottsdale', '09226-1483', 384162290, 'reg@yahoo.com'),
('RENEE', 'Renee', 'Chism', '136 West Markham', 'West Markham', 'Catawba', '58492-3691', 196329485, 'renee@gmail.com'),
('RICK', 'Rick', 'Sencovici', '13802 South University', 'South University', 'Arcadia', '82063-8091', 190836028, 'rick@gmail.com'),
('SIMPSON', 'Simpson', 'Cafee', '32736 Meadowbrook Drive', 'Meadowbrook Drive', 'Nedlands', '38179-3789', 987397183, 'simpson@hotmail.com'),
('TOM', 'Tom', 'Logan', '6180 Roselle Street', 'Roselle Street', 'West Covina', '82378-0904', 409087328, 'tom@hotmail.com'),
('VINCENT', 'Vincent', 'Woiska', '13093 4th Street', '4th Street', 'Jackson', '28063-0466', 664036082, 'vincent@hotmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `name` varchar(30) NOT NULL DEFAULT '',
  `age` int(2) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`name`, `age`) VALUES
('Homer Simpson', 47),
('Peter Pan', 52);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `sellers`
--
ALTER TABLE `sellers`
  ADD PRIMARY KEY (`code`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
