<?php
session_start();
if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}
header("Location: index.php");
exit();
?>