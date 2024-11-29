<?php

include "include/init.php";

$page = new CreatePage();

$page->admin = true;
$page->id = "healers";
$page->model = new Healers();
$page->t = $page->newTemplate("create");

$page->title = "Create " . "Healers";

$page->backUrl = "healers.php";

$page->run();
