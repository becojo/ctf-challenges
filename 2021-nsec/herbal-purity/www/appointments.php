<?php

include "include/init.php";

$page = new ListPage();

$page->admin = false;
$page->id = "appointments";
$page->t = $page->newTemplate("index");
$page->title = "Appointments";
$page->model = new Appointments();

$page->run();
