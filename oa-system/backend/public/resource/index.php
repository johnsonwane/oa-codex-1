<?php
$name=$_GET['name'] ?? '';
$id=$_GET['id'] ?? '';
$_SERVER['REQUEST_URI']='/resource/'.$name.($id!==''?('/'.$id):'');
require __DIR__.'/../index.php';
