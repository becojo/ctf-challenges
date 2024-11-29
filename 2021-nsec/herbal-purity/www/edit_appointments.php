<?php

include "include/init.php";

$page = new EditPage();

$page->admin = false;
$page->id = "appointments";
$page->model_id = Utils::param('id');
$page->model = new Appointments();
$page->t = $page->newTemplate("edit");

$page->title = "Edit " . "Appointments" . " ({$page->model_id})";

$page->backUrl = "appointments.php";

$page->run();
