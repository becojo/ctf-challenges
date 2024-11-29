<?php

include "include/init.php";

$page = new CreatePage();

$page->admin = false;
$page->id = "products";
$page->model = new Products();
$page->t = $page->newTemplate("create");

$page->title = "Create " . "Products";

$page->backUrl = "products.php";

$page->run();
