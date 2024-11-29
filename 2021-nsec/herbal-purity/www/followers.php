<?php

include "include/init.php";

$page = new ListPage();

$page->admin = false;
$page->id = "followers";
$page->t = $page->newTemplate("index");
$page->title = "Followers";
$page->model = new Followers();

$page->run();
