<?php

include "include/init.php";

$page = new CreatePage();

$page->admin = false;
$page->id = "followers";
$page->model = new Followers();
$page->t = $page->newTemplate("create");

$page->title = "Create " . "Followers";

$page->backUrl = "followers.php";

$page->run();
