<?php

include "include/init.php";

$page = new ListPage();

$page->admin = true;
$page->id = "healers";
$page->t = $page->newTemplate("index");
$page->title = "Healers";
$page->model = new Healers();

$page->run();
