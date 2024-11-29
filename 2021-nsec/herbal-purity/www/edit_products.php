<?php

include "include/init.php";

$page = new EditPage();

$page->admin = false;
$page->id = "products";
$page->model_id = Utils::param('id');
$page->model = new Products();
$page->t = $page->newTemplate("edit");

$page->title = "Edit " . "Products" . " ({$page->model_id})";

$page->backUrl = "products.php";

$page->run();
