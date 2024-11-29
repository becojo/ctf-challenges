<?php

include "include/init.php";

$page = new CreatePage();

$page->admin = false;
$page->id = "appointments";
$page->model = new Appointments();
$page->t = $page->newTemplate("create");

$page->title = "Create " . "Appointments";

$page->backUrl = "appointments.php";

$page->run();
