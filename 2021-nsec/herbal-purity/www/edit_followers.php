<?php

include "include/init.php";

$page = new EditPage();

$page->admin = false;
$page->id = "followers";
$page->model_id = Utils::param('id');
$page->model = new Followers();
$page->t = $page->newTemplate("edit");

$page->title = "Edit " . "Followers" . " ({$page->model_id})";

$page->backUrl = "followers.php";

$page->run();
