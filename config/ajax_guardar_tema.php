<?php
session_start();
include("../config/conexion.php");

header('Content-Type: application/json');

if(!isset($_SESSION['id']) || !isset($_POST['tema'])){
    echo json_encode(['success' => false]);
    exit();
}

$tema_validos = ['light', 'sepia', 'dark'];
$tema = in_array($_POST['tema'], $tema_validos) ? $_POST['tema'] : 'light';
$id = intval($_SESSION['id']);

mysqli_query($conexion, "UPDATE usuarios SET tema='$tema' WHERE id=$id");
$_SESSION['tema'] = $tema;

echo json_encode(['success' => true]);
