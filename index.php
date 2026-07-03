<?php
session_start();
if(isset($_SESSION['id'])){
    header("Location: dashboard/index.php");
} else {
    header("Location: tienda/index.php");
}
exit();
?>