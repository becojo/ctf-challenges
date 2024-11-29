<?php

include "include/init.php";

$page = new ListPage();

$page->admin = false;
$page->id = "products";
$page->t = $page->newTemplate("index");
$page->title = "Products";
$page->model = new Products();

$page->run();
