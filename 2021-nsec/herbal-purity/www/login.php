<?php

include "include/init.php";

$p = new LoginPage;

$p->t = $p->newTemplate("login");
$p->model = new Healers;
$p->title = 'Log In';

$p->run();
