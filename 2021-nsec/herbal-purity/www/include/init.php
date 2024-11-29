<?php

spl_autoload_register(function($class_name) {
  include "include/$class_name.php";
});

Utils::include_file('functions.php');

session_set_cookie_params([
  'lifetime' => 3600,
  'secure' => false,
  'httponly' => true,
  'samesite' => 'Strict'
]);

session_start();

error_reporting(0);
