-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: libreria_san_martin
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `apertura_caja`
--

DROP TABLE IF EXISTS `apertura_caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `apertura_caja` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `fecha_apertura` datetime DEFAULT current_timestamp(),
  `fecha_cierre` datetime DEFAULT NULL,
  `monto_inicial` decimal(10,2) NOT NULL DEFAULT 0.00,
  `monto_esperado` decimal(10,2) DEFAULT NULL,
  `monto_final` decimal(10,2) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `apertura_caja_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apertura_caja`
--

LOCK TABLES `apertura_caja` WRITE;
/*!40000 ALTER TABLE `apertura_caja` DISABLE KEYS */;
/*!40000 ALTER TABLE `apertura_caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria`
--

DROP TABLE IF EXISTS `auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,6,'Registró un nuevo usuario: Rous Esmeralda (ID: 13)','2026-06-29 02:09:17'),(2,6,'Reseteó clave del usuario: Rossmery Belen Gonzales (ID: 6)','2026-06-29 02:10:39'),(3,6,'Modificó datos del usuario: Rossmery Belen Gonzales (ID: 6)','2026-06-29 02:10:51'),(4,6,'Modificó datos del usuario: Rossmery Belen Gonzales (ID: 6)','2026-06-29 02:22:27'),(5,6,'Actualizó su perfil y cambió su foto','2026-06-29 02:22:59'),(6,6,'Actualizó su perfil','2026-06-29 02:23:01'),(7,6,'Actualizó su perfil y cambió su foto','2026-06-29 02:30:49'),(8,6,'Actualizó su perfil y cambió su foto','2026-06-29 02:31:25'),(9,6,'Actualizó su perfil','2026-06-29 02:31:27'),(10,6,'Registró un nuevo usuario: Samuel Guillermo  (ID: 14)','2026-06-29 03:01:23');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_categorias`
--

DROP TABLE IF EXISTS `auditoria_categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_categorias` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_categorias`
--

LOCK TABLES `auditoria_categorias` WRITE;
/*!40000 ALTER TABLE `auditoria_categorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_clientes`
--

DROP TABLE IF EXISTS `auditoria_clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_clientes` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `accion` varchar(255) DEFAULT NULL,
  `fecha_hora` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_clientes`
--

LOCK TABLES `auditoria_clientes` WRITE;
/*!40000 ALTER TABLE `auditoria_clientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_compras`
--

DROP TABLE IF EXISTS `auditoria_compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_compras` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_compras`
--

LOCK TABLES `auditoria_compras` WRITE;
/*!40000 ALTER TABLE `auditoria_compras` DISABLE KEYS */;
INSERT INTO `auditoria_compras` VALUES (1,6,'Modificó compra ID: 8, proveedor ID: 3, total: 300','2026-06-29 16:15:01');
/*!40000 ALTER TABLE `auditoria_compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_inventario`
--

DROP TABLE IF EXISTS `auditoria_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_inventario` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_inventario`
--

LOCK TABLES `auditoria_inventario` WRITE;
/*!40000 ALTER TABLE `auditoria_inventario` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_productos`
--

DROP TABLE IF EXISTS `auditoria_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_productos` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_productos`
--

LOCK TABLES `auditoria_productos` WRITE;
/*!40000 ALTER TABLE `auditoria_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_proveedores`
--

DROP TABLE IF EXISTS `auditoria_proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_proveedores` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_proveedores`
--

LOCK TABLES `auditoria_proveedores` WRITE;
/*!40000 ALTER TABLE `auditoria_proveedores` DISABLE KEYS */;
INSERT INTO `auditoria_proveedores` VALUES (1,6,'Modificó proveedor: Distribuidora Escolar (ID: 2)','2026-06-29 15:44:31'),(2,6,'Modificó proveedor: Isabela Catolica (ID: 4)','2026-06-29 15:44:35'),(3,6,'Modificó proveedor: Papelería Central (ID: 3)','2026-06-29 15:44:40');
/*!40000 ALTER TABLE `auditoria_proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_usuarios`
--

DROP TABLE IF EXISTS `auditoria_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_usuarios` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_usuarios`
--

LOCK TABLES `auditoria_usuarios` WRITE;
/*!40000 ALTER TABLE `auditoria_usuarios` DISABLE KEYS */;
INSERT INTO `auditoria_usuarios` VALUES (1,6,'Modificó datos del usuario: Rossmery Belen Gonzales (ID: 6)','2026-06-29 05:20:45'),(2,6,'Reseteó clave del usuario: Rossmery Belen Gonzales (ID: 6)','2026-06-29 05:20:50'),(3,6,'Actualizó su perfil','2026-06-29 05:22:34'),(4,6,'Desactivó al usuario: Ricardo Bartolomeo (ID: 11)','2026-06-29 05:22:47'),(5,6,'Actualizó su perfil y cambió su foto','2026-06-29 14:54:54'),(6,6,'Actualizó su perfil','2026-06-29 14:55:53'),(7,6,'Desactivó al usuario: Rous Esmeralda (ID: 13)','2026-06-29 15:19:11'),(8,6,'Modificó datos del usuario: Samuel Guillermo  (ID: 14)','2026-06-29 19:05:45'),(9,6,'Modificó datos del usuario: Yeremy Gutierrez  (ID: 7)','2026-06-29 19:05:54');
/*!40000 ALTER TABLE `auditoria_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_ventas`
--

DROP TABLE IF EXISTS `auditoria_ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria_ventas` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` text NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_ventas`
--

LOCK TABLES `auditoria_ventas` WRITE;
/*!40000 ALTER TABLE `auditoria_ventas` DISABLE KEYS */;
INSERT INTO `auditoria_ventas` VALUES (1,14,'Registró venta ID: 16, total: 19.5','2026-07-01 19:13:28'),(2,14,'Registró venta ID: 17, total: 3','2026-07-01 19:36:27');
/*!40000 ALTER TABLE `auditoria_ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_flujo`
--

DROP TABLE IF EXISTS `caja_flujo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_flujo` (
  `id_caja` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `monto_apertura` decimal(10,2) NOT NULL,
  `monto_cierre` decimal(10,2) DEFAULT NULL,
  `fecha_apertura` datetime DEFAULT current_timestamp(),
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` enum('ABIERTA','CERRADA') DEFAULT 'ABIERTA',
  PRIMARY KEY (`id_caja`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_flujo`
--

LOCK TABLES `caja_flujo` WRITE;
/*!40000 ALTER TABLE `caja_flujo` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_flujo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(100) DEFAULT NULL,
  `codigo_categoria` varchar(20) DEFAULT NULL,
  `icono` varchar(50) DEFAULT 'bi-tags-fill',
  `categoria_padre` int(11) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `visible_tienda` tinyint(1) DEFAULT 1,
  `descripcion` text DEFAULT NULL,
  `orden` int(11) DEFAULT 0,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Libros ',NULL,'bi-tags-fill',NULL,1,1,'Libros educativos y de lectura',0),(2,'Cuadernos',NULL,'bi-tags-fill',NULL,1,1,'Cuadernos escolares',0),(7,'Literatura',NULL,'bi-tags-fill',NULL,1,1,'Novelas, cuentos, poesía y obras literarias nacionales e internacionales.',0),(9,'Útiles Escolares',NULL,'bi-tags-fill',NULL,1,1,'Artículos utilizados por estudiantes para sus actividades académicas.',0),(10,'Papelería',NULL,'bi-tags-fill',NULL,1,1,'Hojas, cartulinas, sobres y materiales de papel.',0),(11,'Arte y Dibujo',NULL,'bi-tags-fill',NULL,1,1,'Materiales para dibujo, pintura y actividades artísticas.',0),(12,'Tecnología Educativa',NULL,'bi-tags-fill',NULL,1,1,'Calculadora Científica Casio',0);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `ci_nit` varchar(20) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `nombre_cliente` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'3888103',NULL,'Gustavo Gabriel Guachalla Rocha','73612583',NULL,'2026-07-01 15:13:28',1);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras`
--

DROP TABLE IF EXISTS `compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compras` (
  `id_compra` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor_id` int(11) DEFAULT NULL,
  `nro_factura` varchar(50) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_compra`),
  KEY `proveedor_id` (`proveedor_id`),
  CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras`
--

LOCK TABLES `compras` WRITE;
/*!40000 ALTER TABLE `compras` DISABLE KEYS */;
INSERT INTO `compras` VALUES (1,3,NULL,'2026-06-14',400.00),(2,4,NULL,'2026-06-19',350.00),(3,3,NULL,'2026-06-10',180.00),(4,1,NULL,'2026-06-12',240.00),(5,2,NULL,'2026-06-14',115.00),(6,4,NULL,'2026-06-02',160.00),(7,1,NULL,'2026-06-19',120.00),(8,3,'0023','2026-06-29',300.00);
/*!40000 ALTER TABLE `compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_impresora`
--

DROP TABLE IF EXISTS `config_impresora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_impresora` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `tipo` varchar(20) DEFAULT 'ticket',
  `ancho` int(11) DEFAULT 80,
  `charset` varchar(20) DEFAULT 'UTF-8',
  PRIMARY KEY (`id`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `config_impresora_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_impresora`
--

LOCK TABLES `config_impresora` WRITE;
/*!40000 ALTER TABLE `config_impresora` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_impresora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_compras`
--

DROP TABLE IF EXISTS `detalle_compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_compras` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `compra_id` int(11) DEFAULT NULL,
  `producto_id` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `compra_id` (`compra_id`),
  KEY `producto_id` (`producto_id`),
  CONSTRAINT `detalle_compras_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id_compra`),
  CONSTRAINT `detalle_compras_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_compras`
--

LOCK TABLES `detalle_compras` WRITE;
/*!40000 ALTER TABLE `detalle_compras` DISABLE KEYS */;
INSERT INTO `detalle_compras` VALUES (1,1,1,10,40.00),(2,8,9,20,15.00);
/*!40000 ALTER TABLE `detalle_compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_devoluciones`
--

DROP TABLE IF EXISTS `detalle_devoluciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_devoluciones` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `id_devolucion` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_devolucion` (`id_devolucion`),
  KEY `id_producto` (`id_producto`),
  CONSTRAINT `detalle_devoluciones_ibfk_1` FOREIGN KEY (`id_devolucion`) REFERENCES `devoluciones` (`id_devolucion`),
  CONSTRAINT `detalle_devoluciones_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_devoluciones`
--

LOCK TABLES `detalle_devoluciones` WRITE;
/*!40000 ALTER TABLE `detalle_devoluciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalle_devoluciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_pedidos`
--

DROP TABLE IF EXISTS `detalle_pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_pedidos` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `pedido_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `pedido_id` (`pedido_id`),
  KEY `producto_id` (`producto_id`),
  CONSTRAINT `detalle_pedidos_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `detalle_pedidos_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_pedidos`
--

LOCK TABLES `detalle_pedidos` WRITE;
/*!40000 ALTER TABLE `detalle_pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalle_pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_ventas`
--

DROP TABLE IF EXISTS `detalle_ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_ventas` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `venta_id` int(11) DEFAULT NULL,
  `producto_id` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `venta_id` (`venta_id`),
  KEY `producto_id` (`producto_id`),
  CONSTRAINT `detalle_ventas_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id_venta`),
  CONSTRAINT `detalle_ventas_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_ventas`
--

LOCK TABLES `detalle_ventas` WRITE;
/*!40000 ALTER TABLE `detalle_ventas` DISABLE KEYS */;
INSERT INTO `detalle_ventas` VALUES (1,1,1,5,45.00),(2,3,20,1,85.00),(3,4,15,3,2.00),(4,5,5,2,1.50),(5,6,14,1,8.50),(6,7,9,4,18.00),(7,8,2,2,12.00),(8,9,13,1,22.00),(9,10,8,1,60.00),(10,11,17,2,10.00),(11,12,22,3,15.00),(12,13,5,3,1.50),(13,14,6,2,12.00),(14,15,20,2,85.00),(15,16,5,3,1.50),(16,16,22,1,15.00),(17,17,5,2,1.50);
/*!40000 ALTER TABLE `detalle_ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devoluciones`
--

DROP TABLE IF EXISTS `devoluciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devoluciones` (
  `id_devolucion` int(11) NOT NULL AUTO_INCREMENT,
  `id_venta` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `fecha` datetime DEFAULT current_timestamp(),
  `motivo` text DEFAULT NULL,
  `total_devuelto` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_devolucion`),
  KEY `id_venta` (`id_venta`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `devoluciones_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`),
  CONSTRAINT `devoluciones_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devoluciones`
--

LOCK TABLES `devoluciones` WRITE;
/*!40000 ALTER TABLE `devoluciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `devoluciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gastos`
--

DROP TABLE IF EXISTS `gastos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gastos` (
  `id_gasto` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha` datetime DEFAULT current_timestamp(),
  `id_usuario` int(11) NOT NULL,
  PRIMARY KEY (`id_gasto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gastos`
--

LOCK TABLES `gastos` WRITE;
/*!40000 ALTER TABLE `gastos` DISABLE KEYS */;
/*!40000 ALTER TABLE `gastos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historial_precios`
--

DROP TABLE IF EXISTS `historial_precios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `historial_precios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_producto` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `tipo` varchar(20) NOT NULL DEFAULT 'venta',
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_hora` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_producto` (`id_producto`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `historial_precios_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `historial_precios_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial_precios`
--

LOCK TABLES `historial_precios` WRITE;
/*!40000 ALTER TABLE `historial_precios` DISABLE KEYS */;
/*!40000 ALTER TABLE `historial_precios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `intentos_login`
--

DROP TABLE IF EXISTS `intentos_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intentos_login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(100) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `intentos` int(11) DEFAULT 0,
  `ultimo_intento` datetime DEFAULT current_timestamp(),
  `bloqueado_hasta` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `intentos_login`
--

LOCK TABLES `intentos_login` WRITE;
/*!40000 ALTER TABLE `intentos_login` DISABLE KEYS */;
/*!40000 ALTER TABLE `intentos_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mensajes_chat`
--

DROP TABLE IF EXISTS `mensajes_chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mensajes_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_remitente` int(11) NOT NULL,
  `id_destinatario` int(11) DEFAULT NULL,
  `mensaje` text NOT NULL,
  `leido` tinyint(1) DEFAULT 0,
  `fecha_hora` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_remitente` (`id_remitente`),
  KEY `id_destinatario` (`id_destinatario`),
  CONSTRAINT `mensajes_chat_ibfk_1` FOREIGN KEY (`id_remitente`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `mensajes_chat_ibfk_2` FOREIGN KEY (`id_destinatario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mensajes_chat`
--

LOCK TABLES `mensajes_chat` WRITE;
/*!40000 ALTER TABLE `mensajes_chat` DISABLE KEYS */;
/*!40000 ALTER TABLE `mensajes_chat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientos_inventario`
--

DROP TABLE IF EXISTS `movimientos_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movimientos_inventario` (
  `id_movimiento` int(11) NOT NULL AUTO_INCREMENT,
  `id_producto` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_movimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos_inventario`
--

LOCK TABLES `movimientos_inventario` WRITE;
/*!40000 ALTER TABLE `movimientos_inventario` DISABLE KEYS */;
/*!40000 ALTER TABLE `movimientos_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedidos` (
  `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` datetime DEFAULT current_timestamp(),
  `cliente_nombre` varchar(150) NOT NULL,
  `cliente_telefono` varchar(20) DEFAULT NULL,
  `sucursal_id` int(11) DEFAULT NULL,
  `metodo_pago` varchar(50) DEFAULT 'Efectivo',
  `estado` varchar(30) DEFAULT 'Pendiente',
  `total` decimal(10,2) NOT NULL,
  `codigo_seguimiento` varchar(20) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id_pedido`),
  UNIQUE KEY `codigo_seguimiento` (`codigo_seguimiento`),
  KEY `sucursal_id` (`sucursal_id`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`id_sucursal`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) NOT NULL,
  `codigo_barras` varchar(50) DEFAULT NULL,
  `nombre_producto` varchar(150) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `precio_compra` decimal(10,2) DEFAULT 0.00,
  `impuesto` decimal(5,2) DEFAULT 0.00,
  `talla` varchar(20) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `categoria_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_producto`),
  KEY `categoria_id` (`categoria_id`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'PROD-0001',NULL,'Matemática Baldor','Libro escolar',45.00,0.00,0.00,NULL,NULL,25,NULL,1,1),(2,'PROD-0002',NULL,'Cuaderno Espiral','100 hojas',12.00,0.00,0.00,NULL,NULL,48,NULL,1,2),(5,'PROD-0005',NULL,'Lapiz','Para Escritura',1.50,0.00,0.00,NULL,NULL,57,NULL,1,9),(6,'PROD-0006',NULL,'Acuarela','Para pintar',12.00,0.00,0.00,NULL,NULL,33,NULL,1,11),(7,'PROD-0007',NULL,'Diccionario Escolar Larousse','Edición actualizada con tapa blanda e ilustraciones.',35.00,0.00,0.00,NULL,NULL,15,NULL,1,1),(8,'PROD-0008',NULL,'Texto de Ciencias Naturales 6°','Libro oficial de primaria con actividades prácticas.',60.00,0.00,0.00,NULL,NULL,19,NULL,1,1),(9,'PROD-0009',NULL,'Cuaderno Anillado De 100 hojas','Cuadriculado de tapa dura, hojas de 75g.',18.00,0.00,0.00,NULL,NULL,61,NULL,1,2),(10,'PROD-0010',NULL,'Cuaderno de Dibujo Croquis','Hojas blancas lisas sin líneas, tamaño carta.',15.00,0.00,0.00,NULL,NULL,30,NULL,1,2),(11,'PROD-0011',NULL,'Sangre de Campeones','Novela juvenil de superación personal, tapa blanda.',40.00,0.00,0.00,NULL,NULL,12,NULL,1,7),(12,'PROD-0012',NULL,'Don Quijote de la Mancha','Edición escolar adaptada con notas explicativas.',30.00,0.00,0.00,NULL,NULL,10,NULL,1,7),(13,'PROD-0013',NULL,'Caja de Colores Faber-Castell x12','Colores largos de madera, alta resistencia a roturas.',22.00,0.00,0.00,NULL,NULL,54,NULL,1,9),(14,'PROD-0014',NULL,'Bolígrafo Pilot G2 Negro','Tinta gel de escritura fluida, punta fina 0.7mm.',8.50,0.00,0.00,NULL,NULL,119,NULL,1,9),(15,'PROD-0015',NULL,'Goma de Borrar Factis S20','Borrador de miga de pan blanco para lápiz.',2.00,0.00,0.00,NULL,NULL,77,NULL,1,9),(16,'PROD-0016',NULL,'Resma de Papel Bond A4 Chamex','Paquete de 500 hojas blancas de 75g de alta nitidez.',38.00,0.00,0.00,NULL,NULL,40,NULL,1,10),(17,'PROD-0017',NULL,'Block de Cartulinas de Color','20 hojas de cartulina escolar de colores variados.',10.00,0.00,0.00,NULL,NULL,23,NULL,1,10),(18,'PROD-0018',NULL,'Set de Pinceles de Nylon x6','Tamaños variados (planos y redondos) para acrílico y óleo.',16.00,0.00,0.00,NULL,NULL,18,NULL,1,11),(19,'PROD-0019',NULL,'Estuche de Témperas Artesco x12','Frascos de 20ml con colores vivos no tóxicos.',14.50,0.00,0.00,NULL,NULL,32,NULL,1,11),(20,'PROD-0020',NULL,'Calculadora Científica Casio fx-82MS','240 funciones integradas, pantalla de 2 líneas.',85.00,0.00,0.00,NULL,NULL,12,NULL,1,12),(21,'PROD-0021',NULL,'Flash Drive Kingston 64GB','Memoria USB 3.2 para almacenamiento de tareas.',45.00,0.00,0.00,NULL,NULL,28,NULL,1,12),(22,'PROD-0022',NULL,'Juego Geométrico Maped de 4 Piezas','Estuche escolar plástico que incluye regla de 30 cm, escuadra de 45°, escuadra de 60° y transportador de 180°.',15.00,0.00,0.00,NULL,NULL,36,NULL,1,9);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) DEFAULT NULL,
  `telefono` varchar(30) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'Editorial Alfa','70242614','Santa Cruz',1),(2,'Distribuidora Escolar','78022132','Santa Cruz',1),(3,'Papelería Central','72031383','Santa Cruz',1),(4,'Isabela Catolica','72519374','Santa Cruz',1);
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recibos`
--

DROP TABLE IF EXISTS `recibos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recibos` (
  `id_recibo` int(11) NOT NULL AUTO_INCREMENT,
  `venta_id` int(11) NOT NULL,
  `numero_recibo` varchar(20) NOT NULL,
  `fecha_emision` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id_recibo`),
  UNIQUE KEY `numero_recibo` (`numero_recibo`),
  KEY `venta_id` (`venta_id`),
  CONSTRAINT `recibos_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recibos`
--

LOCK TABLES `recibos` WRITE;
/*!40000 ALTER TABLE `recibos` DISABLE KEYS */;
INSERT INTO `recibos` VALUES (1,17,'REC-5F0F39-0017','2026-07-01 15:36:27');
/*!40000 ALTER TABLE `recibos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursales`
--

DROP TABLE IF EXISTS `sucursales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursales` (
  `id_sucursal` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `direccion` text DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id_sucursal`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursales`
--

LOCK TABLES `sucursales` WRITE;
/*!40000 ALTER TABLE `sucursales` DISABLE KEYS */;
INSERT INTO `sucursales` VALUES (1,'Sucursal Centro','Calle BolÝvar #123','2-1234567',1),(2,'Sucursal Norte','Av. Libertador #456','2-7654321',1);
/*!40000 ALTER TABLE `sucursales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `usuario` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `rol` varchar(30) DEFAULT NULL,
  `estado` varchar(20) DEFAULT 'Activo',
  `forzar_cambio` tinyint(1) DEFAULT 0,
  `imagen` varchar(255) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `firma` text DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime DEFAULT NULL,
  `tema` varchar(10) DEFAULT 'light',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador ','admin','$2y$10$VUQiA18bqTN9FKZ2vviFR.cfzLYTsBWBxOjI.6y6FVjcYF9tnJble','$2y$10$VUQiA18bqTN9FKZ2vviFR.cfzLYTsBWBxOjI.6y6FVjcYF9tnJble','Administrador','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02','2026-07-06 12:49:10','light'),(6,'Rossmery Belen Gonzales','Belen','$2y$10$bd1epHB.NQbsZwVyR9N.Lu.upWAyfbYGzRkUb.lLrcvHxkagOQsRG',NULL,'Administrador','Activo',0,'user_6_1782744894.jpg',NULL,NULL,'2026-06-29 05:19:02','2026-06-29 15:05:32','light'),(7,'Yeremy Gutierrez ','Yeremy','$2y$10$S7QaOnBb8xZCTGSK3RosC.bEyFYNffXii2Av6m5PdW5p0Jr9lY.k2',NULL,'Empleado','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(8,'Gustavo Guachalla','Gustavo','12345',NULL,'Empleado','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(9,'Juan Perez','Juan','12345',NULL,'Empleado','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(10,'Luis Miguel','Luis','12345',NULL,'Empleado','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(11,'Ricardo Bartolomeo','Ricardo','12345',NULL,'Empleado','Inactivo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(12,'Camila Zurita','Camila','12345',NULL,'Empleado','Activo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(13,'Rous Esmeralda','Rous','12345',NULL,'Empleado','Inactivo',0,NULL,NULL,NULL,'2026-06-29 05:19:02',NULL,'light'),(14,'Samuel Guillermo ','Samuel','$2y$10$cG6P7ec5Kz0q.6SZuBm3KuEvZUEhVAlDw/Mt3oX6UbfgZB/BCg.7G',NULL,'Administrador','Activo',0,'user_14_1782702083.jpg',NULL,NULL,'2026-06-29 05:19:02','2026-06-29 15:06:01','light');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ventas` (
  `id_venta` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` date DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `metodo_pago` varchar(50) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `estado` varchar(20) DEFAULT 'Completado',
  PRIMARY KEY (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
INSERT INTO `ventas` VALUES (1,'2026-06-14',225.00,NULL,NULL,NULL,'Completado'),(2,'2026-06-19',25.00,NULL,NULL,NULL,'Completado'),(3,'2026-06-18',85.00,NULL,NULL,NULL,'Completado'),(4,'2026-06-18',6.00,NULL,NULL,NULL,'Completado'),(5,'2026-06-18',3.00,NULL,NULL,NULL,'Completado'),(6,'2026-06-18',8.50,NULL,NULL,NULL,'Completado'),(7,'2026-06-18',72.00,NULL,NULL,NULL,'Completado'),(8,'2026-06-18',24.00,NULL,NULL,NULL,'Completado'),(9,'2026-06-18',22.00,NULL,NULL,NULL,'Completado'),(10,'2026-06-18',60.00,NULL,NULL,NULL,'Completado'),(11,'2026-06-18',20.00,NULL,NULL,NULL,'Completado'),(12,'2026-06-19',45.00,NULL,NULL,NULL,'Completado'),(13,'2026-06-20',4.50,NULL,NULL,NULL,'Completado'),(14,'2026-06-25',24.00,NULL,NULL,NULL,'Completado'),(15,'2026-06-25',170.00,NULL,NULL,NULL,'Completado'),(16,'2026-07-01',19.50,'Efectivo',NULL,1,'Completado'),(17,'2026-07-01',3.00,'Transferencia QR',NULL,1,'Pendiente');
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'libreria_san_martin'
--

--
-- Dumping routines for database 'libreria_san_martin'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-03 21:38:36
