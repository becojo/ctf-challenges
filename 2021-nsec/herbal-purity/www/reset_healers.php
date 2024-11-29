<?php
include "include/init.php";

$page = new ResetPage();

$page->admin = true;
$page->id = "healers";
$page->t = $page->newTemplate("reset");
$page->title = "Healers";
$page->model = new Healers();
$page->model_id = Utils::param('id');
$page->username = Utils::param('name');
$page->backUrl = "healers.php";

$page->run();
