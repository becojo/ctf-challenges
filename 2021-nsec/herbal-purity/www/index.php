<?php

include "include/init.php";

$p = new IndexPage();

$p->public = true;
$p->title = 'Herbal Purity';
$p->t = new Template("home", $p);

$p->run();
