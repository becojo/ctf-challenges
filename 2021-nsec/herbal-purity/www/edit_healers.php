<?php

include "include/init.php";

$page = new EditPage();

$page->admin = true;
$page->id = "healers";
$page->model_id = Utils::param('id');
$page->model = new Healers();
$page->t = $page->newTemplate("edit");

$page->title = "Edit " . "Healers" . " ({$page->model_id})";

$page->backUrl = "healers.php";

$page->run();
